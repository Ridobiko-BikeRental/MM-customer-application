import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../API/auth_api.dart';
import '../../API/favorite_api.dart';
import '../../app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
  void initState() {
    super.initState();

    // If user already logged in, fetch favorites immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final favProvider = Provider.of<FavoriteProvider>(context, listen: false);

      if (authProvider.isLoggedIn) {
        favProvider.fetchFavorites().catchError((e) {
          // Handle fetch error if needed
        });
      }
    });
  } 

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home_screen');
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      //bottomNavigationBar: _BottomNavBarStyled(),
      body: Column(
        children: [
          // HEADER
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Log In",
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
                      onPressed: () {
                        Navigator.pushNamed(context, '/onboarding');
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),

          // WHITE CARD - FILLS REMAINING AREA
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -50), // overlap effect
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Welcome to YumQuick",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 24),

                      // EMAIL FIELD
                      Text("Email or Mobile Number", style: _titleStyle()),
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // PASSWORD FIELD
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
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

                      // FORGET PASSWORD
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/forget-password',
                            );
                          },
                          child: const Text(
                            "Forget Password",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ERROR MESSAGE
                      if (authProvider.errorMessage != null) ...[
                        Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          onPressed: authProvider.isLoading
                              ? null
                              : () async {
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text
                                      .trim();
                                  try {
                                    await authProvider.login(email, password);
                                    if (authProvider.isLoggedIn) {
                                      // Fetch favorites after successful login
                                      final favProvider =
                                          Provider.of<FavoriteProvider>(
                                            context,
                                            listen: false,
                                          );
                                      await favProvider.fetchFavorites();

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Login Successful"),
                                        ),
                                      );

                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/home_screen',
                                      ); // Navigate to home
                                    }
                                  } catch (e) {
                                    // Handle login error and show snackbar if needed
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Login failed: ${e.toString()}",
                                        ),
                                      ),
                                    );
                                  }
                                },

                          child: authProvider.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Log In",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: .5,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // SOCIAL LOGIN
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

                      // SIGN UP LINK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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

/* class _BottomNavBarStyled extends StatelessWidget {
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
}*/
