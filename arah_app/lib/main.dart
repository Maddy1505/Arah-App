import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/theme/app_theme.dart';
import 'screens/onboarding/role_selection_screen.dart';

import 'package:provider/provider.dart';
import 'provider/user_provider.dart';
import 'provider/home_provider.dart';
import 'provider/order_provider.dart';
import 'provider/request_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
      ],
      child: const ArahApp(),
    ),
  );
}

class ArahApp extends StatelessWidget {
  const ArahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        // Enforce No Scrollbars globally
        return ScrollConfiguration(
          behavior: const NoScrollbarBehavior(),
          child: child!,
        );
      },
      home: const RoleSelectionScreen(),
    );
  }
}

// Custom behavior to hide scrollbars
class NoScrollbarBehavior extends ScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
