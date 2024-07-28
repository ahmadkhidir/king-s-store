import 'package:flutter/cupertino.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as auth_ui;
import 'package:go_router/go_router.dart';
import 'package:sales_ai_examples/src/auth/screens/auth_screen.dart';

import '../utils/helpers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = "profile_screen";

  @override
  Widget build(BuildContext context) {
    return auth_ui.ProfileScreen(
      providers: providers,
      actions: [
        auth_ui.SignedOutAction(
          (context) {
            context.goNamed(AuthScreen.routeName);
          },
        ),
      ],
    );
  }
}
