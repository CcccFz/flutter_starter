import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

Widget _h(double height) => SizedBox(height: height);
Widget _w(double width) => SizedBox(width: width);

/// Signals Demo Page
///
/// Demonstrates:
/// - `signal()` — reactive primitive that auto-tracks dependencies
/// - `computed()` — derived values that auto-update
/// - `effect()` — side-effects on signal changes
/// - `Watch` — widget that rebuilds when signals change
class SignalsDemoPage extends StatelessWidget {
  const SignalsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signals Demo')),
      body: const _SignalsDemoContent(),
    );
  }
}

class _SignalsDemoContent extends StatelessWidget {
  const _SignalsDemoContent();

  @override
  Widget build(BuildContext context) {
    // Signals are global reactive primitives — they don't need BuildContext.
    final count = signal(0);
    final multiplier = signal(2);
    final items = signal(<String>['Flutter', 'Signals']);

    // Computed: automatically recalculates when count or multiplier changes.
    final doubled = computed(() => count.value * multiplier.value);

    // Effect: runs a side-effect whenever its dependencies change.
    effect(() {
      // ignore: avoid_print
      print('[Effect] Count changed to: ${count.value}');
    });

    return [
          _sectionTitle('1. Basic Signal — Counter'),
          const Text('A simple reactive counter. Click +/− to change it.'),
          _h(12),
          Watch((_) {
            return [
              IconButton.filled(
                onPressed: () => count.value--,
                icon: const Icon(Icons.remove),
              ),
              _w(24),
              Text(
                '${count.value}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              _w(24),
              IconButton.filled(
                onPressed: () => count.value++,
                icon: const Icon(Icons.add),
              ),
            ].toRow(mainAxisAlignment: MainAxisAlignment.center);
          }),

          _h(32),
          _sectionTitle('2. Computed — Derived Value'),
          const Text(
            'Change the multiplier. The "Result" updates automatically '
            'because computed() tracks both count and multiplier.',
          ),
          _h(12),
          Watch((_) {
            final mult = multiplier.value;
            final cnt = count.value;
            final result = doubled.value;
            return [
              [
                const Text('Multiplier: '),
                IconButton.filledTonal(
                  onPressed: () => multiplier.value = (mult - 1).clamp(1, 10),
                  icon: const Icon(Icons.remove),
                ),
                _w(12),
                Text(
                  '$mult',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _w(12),
                IconButton.filledTonal(
                  onPressed: () => multiplier.value = (mult + 1).clamp(1, 10),
                  icon: const Icon(Icons.add),
                ),
              ].toRow(mainAxisAlignment: MainAxisAlignment.center),
              _h(12),
              Text(
                'Result = count ($cnt) × multiplier ($mult) = $result',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple,
                ),
              ),
            ].toColumn();
          }),

          _h(32),
          _sectionTitle('3. Signal List — Dynamic Array'),
          const Text('Add and remove items from a reactive list.'),
          _h(12),
          [
            ElevatedButton.icon(
              onPressed: () => items.value = [
                ...items.value,
                'Item ${items.value.length + 1}',
              ],
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
            _w(8),
            ElevatedButton.icon(
              onPressed: () {
                if (items.value.isNotEmpty) {
                  items.value = items.value.sublist(0, items.value.length - 1);
                }
              },
              icon: const Icon(Icons.remove),
              label: const Text('Remove'),
            ),
          ].toRow(),
          _h(12),
          Watch((_) {
            final list = items.value;
            if (list.isEmpty) {
              return const Text('No items. Tap "Add Item" to create one.');
            }
            return list
                .map((item) => Chip(label: Text(item)))
                .toList()
                .toWrap(spacing: 8, runSpacing: 8);
          }),

          _h(32),
          _sectionTitle('4. Effect — Side Effect on Signal Change'),
          const Text(
            'The effect() callback runs when signals change. '
            'Open the debug console to see output.',
          ),
        ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
        .padding(all: 16)
        .scrollable();
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ).padding(bottom: 8);
  }
}
