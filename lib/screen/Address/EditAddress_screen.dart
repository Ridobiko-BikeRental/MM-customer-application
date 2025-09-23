import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_colors.dart';
import '../../API/address_api.dart';

class EditAddressScreen extends StatefulWidget {
  final String addressId;

  const EditAddressScreen({super.key, required this.addressId});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressLineController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  bool _isLoading = true; // show loading when fetching details

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final provider = Provider.of<AddressProvider>(context, listen: false);
    final address = await provider.getAddressById(widget.addressId);
    if (address != null) {
      nameController.text = address.label;
      addressLineController.text = address.addressLine;
      cityController.text = address.city;
      stateController.text = address.state;
      pinController.text = address.pincode;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    addressLineController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddressProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Edit Address', style: TextStyle(color: AppColors.buttonText)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.buttonText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffFFF6C5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Icon(Icons.home, color: AppColors.primary, size: 60),
                      ),
                    ),
                    SizedBox(height: 32),
                    _addressField('Label (e.g. Home)', nameController),
                    SizedBox(height: 14),
                    _addressField('Address Line', addressLineController, maxLines: 2),
                    SizedBox(height: 14),
                    _addressField('City', cityController),
                    SizedBox(height: 14),
                    _addressField('State', stateController),
                    SizedBox(height: 14),
                    _addressField('Pincode', pinController),
                    SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.buttonText,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                final success = await provider.updateAddress(
                                  AddressModel(
                                    id: widget.addressId,
                                    label: nameController.text.trim(),
                                    addressLine: addressLineController.text.trim(),
                                    city: cityController.text.trim(),
                                    state: stateController.text.trim(),
                                    pincode: pinController.text.trim(),
                                  ),
                                );
                                if (success) {
                                  Navigator.pop(context, true); // Return true on success
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(provider.errorMessage ?? 'Failed to update address!')),
                                  );
                                }
                              },
                        child: provider.isLoading
                            ? CircularProgressIndicator(color: AppColors.buttonText)
                            : Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    if (provider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _addressField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffFFF6C5),
            borderRadius: BorderRadius.circular(12),
          ),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: const InputDecoration(border: InputBorder.none),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
