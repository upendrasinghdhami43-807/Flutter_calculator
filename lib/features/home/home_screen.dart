import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SuperCalc')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose your depth', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('One calculator app, three depths.', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 28),
              Expanded(
                child: ListView(
                  children: [
                    _ModeTile(
                      icon: Icons.calculate_outlined,
                      title: 'Basic',
                      subtitle: 'Everyday arithmetic with an expandable scientific layer.',
                      onTap: () => context.go('/basic'),
                    ),
                    _ModeTile(
                      icon: Icons.science_outlined,
                      title: 'Pro',
                      subtitle: 'Scientific tools, matrices, vectors, and statistics.',
                      onTap: () => context.go('/scientific'),
                    ),
                    _ModeTile(
                      icon: Icons.architecture_outlined,
                      title: 'Advanced',
                      subtitle: 'Engineering workbench for equations, graphs, conics, and more.',
                      onTap: () => context.go('/advanced'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          leading: Icon(icon, size: 30),
          title: Text(title, style: Theme.of(context).textTheme.titleLarge),
          subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle)),
          trailing: const Icon(Icons.arrow_forward),
          onTap: onTap,
        ),
      ),
    );
  }
}
