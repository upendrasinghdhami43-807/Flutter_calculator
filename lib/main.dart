import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: SuperCalcApp()));
}

class SuperCalcApp extends StatelessWidget {
  const SuperCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SuperCalc',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: AppRouter.router,
    );
  }
}