import 'package:firebase_auth/firebase_auth.dart' show AuthCredential;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

final List<AuthProvider<AuthListener, AuthCredential>> providers = [
      EmailAuthProvider(),
      PhoneAuthProvider(),
    ];