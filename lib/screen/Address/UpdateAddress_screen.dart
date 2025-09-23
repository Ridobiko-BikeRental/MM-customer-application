import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_colors.dart';
import '../../API/address_api.dart';

class UpdateAddressScreen extends StatefulWidget {
  const UpdateAddressScreen({super.key});

  @override
  State<UpdateAddressScreen> createState() => _UpdateAddressScreenState();
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressLineController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  

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
        title: Text('Add New Address', style: TextStyle(color: AppColors.buttonText)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.buttonText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
          child: Column(
            children: [
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffFFF6C5),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.all(24),
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
                          final success = await provider.addAddress(
                            label: nameController.text.trim(),
                            addressLine: addressLineController.text.trim(),
                            city: cityController.text.trim(),
                            state: stateController.text.trim(),
                            pincode: pinController.text.trim(),
                          );
                          if (success) {
                            Navigator.pop(context); // pop back to address screen
                          } else {
                            // Optionally show error with a snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.errorMessage ?? 'Failed to add address!')),
                            );
                          }
                        },
                  child: provider.isLoading
                      ? CircularProgressIndicator(color: AppColors.buttonText)
                      : Text('Apply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
        Text(label, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
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
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
