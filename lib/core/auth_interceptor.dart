import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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

    final bool? loggedIn = await context.push('/login');

    if (loggedIn == true) {
      action();
      return true;
    }

    return false;
  }
}