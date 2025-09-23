import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yumquick/API/auth_api.dart';
import '../../API/updateprofile_api.dart';
import 'package:yumquick/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';


class UpdateProfileScreen extends StatefulWidget {
  final String initialFullName;
  final String initialEmail;
  final String initialMobile;
  final String initialCity;
  final String initialState;

  const UpdateProfileScreen({
    super.key,
    required this.initialFullName,
    required this.initialEmail,
    required this.initialMobile,
    required this.initialCity,
    required this.initialState,
  });

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late final TextEditingController fullNameController;
  late final TextEditingController emailController;
  late final TextEditingController mobileController;
  late final TextEditingController cityController;
  late final TextEditingController stateController;
  late final TextEditingController companyController;

  File? _image; // Store photo here
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', pickedFile.path); // Save path
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', pickedFile.path); // Save path
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Photo'),
                onTap: () {
                  _pickFromCamera();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Upload from Gallery'),
                onTap: () {
                  _pickFromGallery();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.initialFullName);
    emailController = TextEditingController(text: widget.initialEmail);
    mobileController = TextEditingController(text: widget.initialMobile);
    cityController = TextEditingController(text: widget.initialCity);
    stateController = TextEditingController(text: widget.initialState);
    companyController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    cityController.dispose();
    stateController.dispose();
    companyController.dispose();
    super.dispose();
  }

  // Helper widget for text fields
  Widget _profileField(String label, TextEditingController controller) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(border: InputBorder.none),
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdateProfileProvider(),
      child: Consumer<UpdateProfileProvider>(builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: Text('Update Profile', style: TextStyle(color: AppColors.buttonText)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.buttonText),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Image picker UI
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _image != null
                          ? Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.accent, width: 3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  _image!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.grey[700],
                              ),
                            ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: GestureDetector(
                          onTap: () {
                            _showPickerOptions(context);
                          },
                          child: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            radius: 18,
                            child: Icon(Icons.camera_alt, size: 18, color: AppColors.buttonText),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                _profileField('Full Name', fullNameController),
                SizedBox(height: 16),
                _profileField('Email', emailController),
                SizedBox(height: 16),
                _profileField('Mobile', mobileController),
                SizedBox(height: 16),
                _profileField('City', cityController),
                SizedBox(height: 16),
                _profileField('State', stateController),
                SizedBox(height: 16),
                _profileField('Company', companyController),
                SizedBox(height: 28),

                ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          // You must upload the _image and obtain a URL here before calling updateProfile
                          // For example, you can upload to your backend or cloud storage and get the URL.
                          // For now, assuming image URL remains unchanged or empty if no upload functionality yet.
                          String imageUrl = '';
                          if (_image != null) {
                            // TODO: Implement image upload and get URL
                            // imageUrl = await uploadImage(_image);
                          }
                          await provider.updateProfile(
                            fullName: fullNameController.text.trim(),
                            email: emailController.text.trim(),
                            mobile: mobileController.text.trim(),
                            city: cityController.text.trim(),
                            state: stateController.text.trim(),
                            company: companyController.text.trim(),
                            image: imageUrl,
                          );

                          if (provider.updateSuccess) {
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            authProvider.setUserData(
                              fullName: fullNameController.text.trim(),
                              email: emailController.text.trim(),
                              mobile: mobileController.text.trim(),
                              city: cityController.text.trim(),
                              state: stateController.text.trim(),
                              // possibly update the image URL as well if uploaded
                            );

                            Navigator.pop(context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.buttonText,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: provider.isLoading
                      ? CircularProgressIndicator(color: AppColors.buttonText)
                      : Text('Update Profile', style: TextStyle(fontSize: 16)),
                ),
                if (provider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      provider.errorMessage!,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (provider.updateSuccess)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Profile updated successfully!',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
