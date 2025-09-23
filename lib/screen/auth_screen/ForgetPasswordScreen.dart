import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../API/auth_api.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  TextStyle _titleStyle() => TextStyle(
    fontWeight: FontWeight.w600,
    color: Colors.brown[900],
    fontSize: 15,
  );

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _BottomNavBarStyled(),
      body: Column(
        children: [
          // HEADER
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD54F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Set New Password",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // WHITE CARD AREA
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -50),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Please set your new password below.",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 32),

                      // New Password
                      Text("New Password", style: _titleStyle()),
                      const SizedBox(height: 7),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter new password",
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Confirm Password
                      Text("Confirm Password", style: _titleStyle()),
                      const SizedBox(height: 7),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Re-enter new password",
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Error message
                      if (authProvider.errorMessage != null) ...[
                        Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // SUBMIT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          onPressed: authProvider.isLoading
                              ? null
                              : () async {
                            // perform password update here
                            String pass = _passwordController.text.trim();
                            String confirm = _confirmPasswordController.text.trim();

                            if (pass.isEmpty || confirm.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please fill all fields")),
                              );
                              return;
                            }
                            if (pass != confirm) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Passwords do not match")),
                              );
                              return;
                            }

                            // Call API or AuthProvider method to update password
                            // await context.read<AuthProvider>().updatePassword(pass);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Password updated successfully")),
                            );
                            Navigator.pop(context);
                          },
                          child: authProvider.isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            "Update Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Back to Log In",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom Nav reused
class _BottomNavBarStyled extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.restaurant, color: Colors.white),
          Icon(Icons.favorite_border, color: Colors.white),
          Icon(Icons.list_alt, color: Colors.white),
          Icon(Icons.headset_mic, color: Colors.white),
        ],
      ),
    );
  }
}
