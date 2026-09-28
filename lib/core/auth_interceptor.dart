import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/sign_in_screen.dart';

class AuthInterceptor {
  static Future<bool> executeAction(
    BuildContext context,
    VoidCallback action,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      action();
      return true;
    }

    final bool? loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const SignInScreen(isModal: true),
      ),
    );

    if (loggedIn == true || authProvider.isAuthenticated) {
      action();
      return true;
    }

    return false;
  }
}