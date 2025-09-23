import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../API/auth_api.dart'; // Adjust the import if needed
// So you can navigate back

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
final TextEditingController _fullNameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _mobileController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  TextStyle _titleStyle() => TextStyle(
    fontWeight: FontWeight.w600,
    color: Colors.brown[900],
    fontSize: 15,
  );

  Widget _socialIcon(IconData icon, double size) {
    return CircleAvatar(
      radius: 21,
      backgroundColor: const Color(0xFFFFF3CD),
      child: Icon(icon, color: Colors.deepOrange, size: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // If just registered/logged in, go home
    if (authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home_screen');
      });
    }

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
                      "New Account",
                      style: TextStyle(
                        fontSize: 30,
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
          // WHITE CARD
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
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      Text("Full name", style: _titleStyle()),
                      const SizedBox(height: 7),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Full name",
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),

                      // Email
                      Text("Email", style: _titleStyle()),
                      const SizedBox(height: 7),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 13),

                      // Password
                      Text("Password", style: _titleStyle()),
                      const SizedBox(height: 7),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscure = !_obscure;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),

                      // Mobile Number
                      Text("Mobile number", style: _titleStyle()),
                      const SizedBox(height: 7),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _mobileController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Mobile number",
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(height: 13),


                      // Terms
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: "By continuing, you agree to the\n",
                            style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                            children: [
                              TextSpan(
                                text: "Terms of Use",
                                style: TextStyle(
                                  color: Colors.red,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy.",
                                style: TextStyle(
                                  color: Colors.red,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Error
                      if (authProvider.errorMessage != null) ...[
                        Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // SIGN UP button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
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
                                   final fullName = _fullNameController.text.trim();
                                   final email = _emailController.text.trim();
                                   final mobile = _mobileController.text.trim();
                                   final password = _passwordController.text.trim();

                                   if (fullName.isEmpty || email.isEmpty || mobile.isEmpty || password.isEmpty) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                   const SnackBar(content: Text("Please fill all fields")),
                                   );
                                   return;
                                   }

                                   await context.read<AuthProvider>().signup(email, password, fullName, mobile);

                                   if(context.read<AuthProvider>().signupSuccess){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Signup successful! Please log in."))
                                    );
                                    Navigator.pushNamed(context, '/login');
                                   }
                              },

                            
                          child: authProvider.isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Social signup
                      const Center(
                        child: Text(
                          "or sign up with",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialIcon(Icons.g_mobiledata, 27),
                          const SizedBox(width: 15),
                          _socialIcon(Icons.facebook, 22),
                          const SizedBox(width: 15),
                          _socialIcon(Icons.fingerprint, 22),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Already have account? Log In
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // go back to login
                            },
                            child: const Text(
                              "Log in",
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
