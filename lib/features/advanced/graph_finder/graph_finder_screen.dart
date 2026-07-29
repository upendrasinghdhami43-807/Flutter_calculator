import 'package:flutter/material.dart';

import '../conic/conic_workspace.dart';

class GraphFinderScreen extends StatelessWidget {
  const GraphFinderScreen({super.key});

  @override
  Widget build(BuildContext context) => const ConicWorkspace(
    title: 'Graph Finder',
    subtitle: 'Choose a shape template and parameters, or enter another canonical second-degree equation.',
  );
}
