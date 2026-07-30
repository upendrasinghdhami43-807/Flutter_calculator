import 'package:go_router/go_router.dart';

import '../../features/advanced/advanced_home_screen.dart';
import '../../features/advanced/calculus/calculus_screen.dart';
import '../../features/advanced/conic/conic_screen.dart';
import '../../features/advanced/equation/equation_screen.dart';
import '../../features/advanced/graph_3d/graph_3d_screen.dart';
import '../../features/advanced/graph_finder/graph_finder_screen.dart';
import '../../features/advanced/lpp/lpp_screen.dart';
import '../../features/advanced/matrix/matrix_screen.dart';
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
      GoRoute(path: '/advanced/matrix', builder: (_, _) => const MatrixScreen()),
      GoRoute(path: '/advanced/equation', builder: (_, _) => const EquationScreen()),
      GoRoute(path: '/advanced/graph-finder', builder: (_, _) => const GraphFinderScreen()),
      GoRoute(path: '/advanced/conic', builder: (_, _) => const ConicScreen()),
      GoRoute(path: '/advanced/calculus', builder: (_, _) => const CalculusScreen()),
      GoRoute(path: '/advanced/lpp', builder: (_, _) => const LppScreen()),
      GoRoute(path: '/advanced/graph-3d', builder: (_, _) => const Graph3DScreen()),
    ],
  );
}
