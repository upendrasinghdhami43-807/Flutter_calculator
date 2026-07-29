import 'package:go_router/go_router.dart';

import '../../features/advanced/advanced_home_screen.dart';
import '../../features/basic_calculator/basic_calculator_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/scientific/scientific_screen.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/basic', builder: (_, _) => const BasicCalculatorScreen()),
      GoRoute(path: '/scientific', builder: (_, _) => const ScientificScreen()),
      GoRoute(path: '/advanced', builder: (_, _) => const AdvancedHomeScreen()),
    ],
  );
}
