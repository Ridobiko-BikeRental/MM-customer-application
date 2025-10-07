import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yumquick/API/address_api.dart';
import 'package:yumquick/API/auth_api.dart';
import 'package:yumquick/API/favorite_api.dart';
import 'package:yumquick/providers/MealBox_provider.dart';
import 'package:yumquick/screen/Filter_screen.dart';
import 'package:yumquick/screen/Order/Tracking_screen.dart';
import 'package:yumquick/screen/SeeReviews_screen.dart';
import 'package:yumquick/screen/auth_screen/login_screen.dart';
import 'package:yumquick/screen/auth_screen/signup_screen.dart';
import 'package:yumquick/providers/cart_provider.dart';
import 'package:yumquick/screen/Order/CancelOrder_screen.dart';
import 'package:yumquick/screen/Home_screen.dart';
import 'package:yumquick/screen/Order/MyOrder_screen.dart';
import 'package:yumquick/screen/Address/UpdateAddress_screen.dart';
import 'package:yumquick/screen/cart/cart_screen.dart';
import 'package:yumquick/screen/cart/slotBooking_screen.dart';
import 'package:yumquick/screen/profile/Updateprofile_screen.dart';
import 'package:yumquick/screen/Address/address_screen.dart';
import 'package:yumquick/screen/cart/checkout_screen.dart';
import 'package:yumquick/screen/favorite_screen.dart';
import 'package:yumquick/screen/history_screen.dart';
import 'package:yumquick/screen/Order/order_confirmed_screen.dart';
import 'package:yumquick/screen/Meal%20Box/MealBox_SubCat_screen.dart';
import 'package:yumquick/screen/onboarding_screen.dart';
import 'package:yumquick/screen/splash_screen.dart';
import 'screen/Meal Box/MealBox_screen.dart';
import 'package:yumquick/providers/category_provider.dart';
import 'package:yumquick/screen/profile/Myprofile_screen.dart';
import 'screen/Meal Box/MealBox_details_screen.dart';
import 'screen/Address/EditAddress_screen.dart';


void main() {
  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (_) => CategoryProvider()..loadCategoriesWithSubcategories()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => MealboxProvider()),
        ChangeNotifierProvider(create: (_) => SelectedAddressProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/updateprofile') {
          // Expecting arguments as Map<String, dynamic>
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (context) => UpdateProfileScreen(
              initialFullName: args['fullName'] ?? '',
              initialEmail: args['email'] ?? '',
              initialMobile: args['mobile'] ?? '',
              initialCity: args['city'] ?? '',
              initialState: args['state'] ?? '',
            ),
          );
        }
        if (settings.name == '/CancelOrder') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => CancelOrderScreen(orderId: args['orderId']),
      );
    }

    if (settings.name == '/editaddress') {
    final id = settings.arguments as String?;
    if (id != null) {
      return MaterialPageRoute(
        builder: (context) => EditAddressScreen(addressId: id),
      );
    }
    // Handle missing or invalid argument here if you want
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(child: Text('Address ID is required for editing.')),
      ),
    );
  }
  /* if (settings.name == '/orderConfirm') {
  // Expecting arguments as String orderId
  final orderId = settings.arguments as String?;
  if (orderId == null) {
    return MaterialPageRoute(builder: (_) => Scaffold(
      body: Center(child: Text('Order ID is required')),
    ));
  }
  return MaterialPageRoute(
    builder: (_) => OrderConfirmedScreen(orderId: orderId),
  );
} */
 if (settings.name == '/slot_booking') {
    final args = settings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(
      builder: (_) => SlotBookingScreen(cartItems: args?['cartItems'] ?? []),
    );
  }
if (settings.name == '/tracking') {
  final orderId = settings.arguments as String?;
  if (orderId == null) {
  return MaterialPageRoute(
    builder: (_) => Scaffold(
      body: Center(child: Text('Order ID is required to track the order.')),
    ),
  );
}
  return MaterialPageRoute(
    builder: (_) => TrackingScreen(orderId: orderId),
  );
}

        // Handle other routes or default
        return null; // Or MaterialPageRoute for your home/other screens
      },
      routes: {
        '/splash' : (context) => SplashScreen(),
        '/onboarding' : (context) => OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home_screen': (context) => Home_screen(),
        '/mealbox_screen' : (context) => MealBoxScreen(),
        '/mealbox_detail' : (context) => MealBoxDetailsScreen(),
        '/profile_screen' : (context) => Myprofile_screen(),
        '/address_screen': (context) => AddressScreen(),
        '/updateaddress' : (context) => UpdateAddressScreen(),
        '/orders_screen' : (context) => MyOrderScreen(),
        '/checkout' : (context) => CheckoutScreen(),
        //'/cart' : (context) => CartScreen(),
        '/favourite': (context) => FavoritesScreen(),
        '/history' : (context) => HistoryScreen(),
        '/mealbox_SubCat' : (context) => SubCategoriesScreen(),
        //'/SeeReviews' : (context) => SeeReview_screen(),
        '/filter_screen': (context) => const FilterScreen(),
        '/orderConfirm' : (context) => const OrderPlacedScreen(orderId: '', customerOrderId: ''),
      },
    );
  }
} 

