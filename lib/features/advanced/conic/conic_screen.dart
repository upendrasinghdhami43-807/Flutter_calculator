import 'package:flutter/material.dart';

import 'conic_workspace.dart';

class ConicScreen extends StatelessWidget {
  const ConicScreen({super.key});

  @override
  Widget build(BuildContext context) => const ConicWorkspace(
    title: 'Conic Value Finder',
    subtitle: 'Pick a shape or enter a general equation to calculate its defining geometric values.',
  );
}
