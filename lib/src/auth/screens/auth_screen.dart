import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/helpers.dart';
import 'package:sales_ai_examples/src/products/screens/home_screen.dart';
import 'package:sales_ai_examples/src/utils/helpers.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static const routeName = "auth_screen";

  @override
  Widget build(BuildContext context) {
    
    setSystemUIOverlayColor(Theme.of(context).colorScheme.primary);
    return SignInScreen(
      providers: providers,
      headerBuilder: (context, constraints, shrinkOffset) {
        return Container(
          constraints: constraints,
          height: double.infinity,
          color: Theme.of(context).colorScheme.primary,
          alignment: Alignment.center,
          child: Text(
            "King's Store",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
        );
      },
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          context.goNamed(HomeScreen.routeName);
        }),
      ],
    );
  }
}
