import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class AuthInterceptor {
  static Future<bool> executeAction(BuildContext context, VoidCallback action) async {
    if (FirebaseAuth.instance.currentUser != null) {
      action();
      return true;
    }

    final bool? loggedIn = await context.push('/login');

    if (loggedIn == true) {
      action();
      return true;
    }

    return false;
  }
}


