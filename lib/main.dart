import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'services/database_service.dart';
import 'router/app_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    final dbService = DatabaseService();
    await dbService.seedInitialData();
  } catch (_) {}

  runApp(const HarvestHubApp());
}

class HarvestHubApp extends StatelessWidget {
  const HarvestHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const HarvestHubAppRouter(),
    );
  }
}

class HarvestHubAppRouter extends StatefulWidget {
  const HarvestHubAppRouter({super.key});

  @override
  State<HarvestHubAppRouter> createState() => _HarvestHubAppRouterState();
}

class _HarvestHubAppRouterState extends State<HarvestHubAppRouter> {
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    router = AppRouter.createRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
            title: 'HarvestHub',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
            builder: (context, child) => ResponsiveBreakpoints.builder(
              child: Builder(
                builder: (context) {
                  return MaxWidthBox(
                    maxWidth: 1200,
                    backgroundColor: const Color(0xFFF7FAF3),
                    child: ResponsiveScaledBox(
                      width: ResponsiveValue<double>(context, defaultValue: 390, conditionalValues: [
                        Condition.equals(name: MOBILE, value: 390),
                        Condition.between(start: 451, end: 800, value: 600),
                        Condition.between(start: 801, end: 1920, value: 800),
                      ]).value,
                      child: child!,
                    ),
                  );
                },
              ),
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            ),
          );
  }
}






