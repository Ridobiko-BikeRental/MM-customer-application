import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_colors.dart';
import '../../API/address_api.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddressProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Delivery Address',
          style: TextStyle(color: AppColors.buttonText),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.buttonText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: provider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : provider.addresses == null
                      ? Center(child: Text("No addresses found."))
                      : provider.addresses!.isEmpty
                          ? Center(child: Text("No addresses yet."))
                          : ListView.separated(
                              itemCount: provider.addresses!.length,
                              separatorBuilder: (context, index) =>
                                  Divider(height: 16, color: Colors.transparent),
                              itemBuilder: (context, index) {
                                final address = provider.addresses![index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.accent,
                                      width: 2,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                    leading: Icon(
                                      Icons.home,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                    title: Text(
                                      address.label,
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text(
                                        "${address.addressLine}\n${address.city}, ${address.state} ${address.pincode}",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: AppColors.primary,
                                      ),
                                      onSelected: (String value) async {
                                        if (value == 'edit') {
                                          final edited = await Navigator.pushNamed(
                                            context,
                                            '/editaddress',
                                            arguments: address.id,
                                          );
                                          if (edited == true) {
                                            await provider.fetchAddresses();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Address updated."),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                size: 18,
                                                color: AppColors.primary,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.buttonText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/updateaddress',
                  );
                  if (result == true) {
                    provider.fetchAddresses();
                  }
                },
                child: Text(
                  'Add New Address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
