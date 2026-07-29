import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdvancedHomeScreen extends StatelessWidget {
  const AdvancedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tools = [
      _AdvancedTool('Matrix', 'Determinant, inverse, rank, eigenvalues, and matrix arithmetic.', Icons.grid_on, '/advanced/matrix'),
      _AdvancedTool('Equation', 'Polynomial roots and linear systems up to 4 variables.', Icons.functions, '/advanced/equation'),
      _AdvancedTool('Graph Finder', 'Build and inspect circles, ellipses, parabolas, and hyperbolas.', Icons.show_chart, '/advanced/graph-finder'),
      _AdvancedTool('Conic Value Finder', 'Extract vertices, foci, directrices, asymptotes, and eccentricity.', Icons.architecture_outlined, '/advanced/conic'),
      _AdvancedTool('Calculus', 'Symbolic and numerical calculus workspace.', Icons.area_chart_outlined, '/advanced/calculus'),
      _AdvancedTool('LPP', 'Linear programming and constraints workspace.', Icons.account_tree_outlined, '/advanced/lpp'),
      _AdvancedTool('Graph 3D', 'Three-dimensional graphing workspace.', Icons.view_in_ar_outlined, '/advanced/graph-3d'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tools.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('Engineering workbench', style: Theme.of(context).textTheme.headlineSmall),
              );
            }
            final tool = tools[index - 1];
            return ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Icon(tool.icon, size: 30),
              title: Text(tool.title, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(tool.subtitle)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(tool.route),
            );
          },
        ),
      ),
    );
  }
}

class _AdvancedTool {
  const _AdvancedTool(this.title, this.subtitle, this.icon, this.route);

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}