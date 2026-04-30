import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget _h(double height) => SizedBox(height: height);
Widget _w(double width) => SizedBox(width: width);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Starter')),
      body: [
        const Text(
          'Tech Stack Demos',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        _h(8),
        const Text(
          'Each demo showcases one or more of the core libraries integrated into this project.',
          style: TextStyle(color: Colors.grey),
        ),
        _h(24),
        _DemoCard(
          icon: Icons.wifi_tethering,
          title: 'Signals Demo',
          description:
              'Reactive state management with auto-tracking dependencies. See how signals automatically update the UI when values change.',
          onTap: () => context.push('/signals'),
        ),
        _h(12),
        _DemoCard(
          icon: Icons.handyman,
          title: 'Flutter Hooks Demo',
          description:
              'Elegant widget state and lifecycle management. Reduce boilerplate with useReducer, useEffect, useMemoized, and more.',
          onTap: () => context.push('/hooks'),
        ),
        _h(12),
        _DemoCard(
          icon: Icons.cloud_done,
          title: 'FQuery Demo',
          description:
              'Async data fetching with caching, retries, and auto-refresh. Fetches real data from JSONPlaceholder public API.',
          onTap: () => context.push('/fquery'),
        ),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch).padding(all: 16),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _DemoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: [
        Container(
          padding: 12.paddingAll(),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        _w(16),
        [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          _h(4),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).expanded(),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ].toRow().padding(all: 16).inkWell(onTap: onTap, borderRadius: 12),
    );
  }
}
