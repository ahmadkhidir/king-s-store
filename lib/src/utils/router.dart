import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ai_examples/src/auth/screens/auth_screen.dart';
import 'package:sales_ai_examples/src/auth/screens/profile_screen.dart';
import 'package:sales_ai_examples/src/auth/screens/welcome_screen.dart';
import 'package:sales_ai_examples/src/paystack/screens/verify_screen.dart';
import 'package:sales_ai_examples/src/products/screens/cart_screen.dart';
import 'package:sales_ai_examples/src/products/screens/checkout_screen.dart';
import 'package:sales_ai_examples/src/products/screens/home_screen.dart';
import 'package:sales_ai_examples/src/paystack/screens/payment_screen.dart';
import 'package:sales_ai_examples/src/products/screens/product_details_screen.dart';
import 'package:sales_ai_examples/src/products/screens/search_screen.dart';

GoRouter appRouter = GoRouter(
  initialLocation: FirebaseAuth.instance.currentUser == null ? '/welcome' : '/',
  routes: [
    GoRoute(
      name: HomeScreen.routeName,
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          name: SearchScreen.routeName,
          path: 'search/:query',
          builder: (context, state) => SearchScreen(
            query: state.pathParameters['query']!,
          ),
        ),
        GoRoute(
          name: ProductDetailsScreen.routeName,
          path: 'product/:id',
          builder: (context, state) => ProductDetailsScreen(
            productId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          name: ProfileScreen.routeName,
          path: "profile",
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
            name: CartScreen.routeName,
            path: "cart",
            builder: (context, state) => const CartScreen(),
            routes: [
              GoRoute(
                  name: CheckoutScreen.routeName,
                  path: "checkout",
                  builder: (context, state) => const CheckoutScreen(),
                  routes: [
                    GoRoute(
                        name: PaystackScreen.routeName,
                        path: "paystack",
                        builder: (context, state) => const PaystackScreen(),
                        routes: [
                          GoRoute(
                            name: VerifyScreen.routeName,
                            path: "verify",
                            builder: (context, state) => const VerifyScreen(),
                          ),
                        ]),
                  ]),
            ]),
      ],
    ),
    GoRoute(
      name: WelcomeScreen.routeName,
      path: "/welcome",
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      name: AuthScreen.routeName,
      path: "/auth",
      builder: (context, state) => const AuthScreen(),
    ),
  ],
);
