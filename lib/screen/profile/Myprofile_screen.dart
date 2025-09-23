import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_colors.dart';
import '../../API/auth_api.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class Myprofile_screen extends StatefulWidget {
  const Myprofile_screen({super.key});

  @override
  State<Myprofile_screen> createState() => _Myprofile_screenState();
}

class _Myprofile_screenState extends State<Myprofile_screen> {
  bool _didRequest = false; // To avoid multiple fetches
  String? _savedImagePath;
  File? _savedImageFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!_didRequest && (auth.userFullName == null || auth.userEmail == null)) {
      auth.getUserData(); // Fetch user data if missing
      _didRequest = true;
    }
  }
  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profileImagePath');
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        _savedImagePath = imagePath;
        _savedImageFile = File(imagePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('My profile', style: TextStyle(color: AppColors.buttonText)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.buttonText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : authProvider.errorMessage != null
              ? Center(
                  child: Text(
                    authProvider.errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 32),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          _savedImageFile != null && _savedImageFile!.existsSync()
  ? Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.accent, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          _savedImageFile!,
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

                         
                        ],
                      ),
                      SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            _profileField('Full Name', authProvider.userFullName ?? '...'),
                            SizedBox(height: 16),
                            _profileField('Email', authProvider.userEmail ?? '...'),
                            SizedBox(height: 16),
                            _profileField('Phone Number', authProvider.userMobile ?? '...'),
                            SizedBox(height: 16,),
                            _profileField('City', authProvider.userCity ?? '...'),
                            SizedBox(height: 16,),
                            _profileField('State', authProvider.userState ?? '...'),
                            SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.buttonText,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context,
                                    '/updateprofile',
                                    arguments: {
                                      'fullName': authProvider.userFullName ?? '',
                                      'email': authProvider.userEmail ?? '',
                                      'mobile': authProvider.userMobile ?? '',
                                      'city': authProvider.userCity ?? '',
                                      'state': authProvider.userState ?? '',
                                    },
                                  );
                                },
                                child: Text('Update Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                            SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _profileField(String label, String value) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(value, style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
