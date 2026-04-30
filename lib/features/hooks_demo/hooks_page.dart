import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

Widget _h(double height) => SizedBox(height: height);
Widget _w(double width) => SizedBox(width: width);

/// Flutter Hooks Demo Page
///
/// Demonstrates:
/// - `useState` — simple state without StatefulWidget
/// - `useReducer` — complex state transitions
/// - `useEffect` — lifecycle and cleanup
/// - `useMemoized` — memoize expensive computations
/// - `useAnimationController` — animation without TickerProviderMixin
/// - `useTextEditingController` — text input management
/// - `useCallback` — memoized callbacks
class HooksDemoPage extends StatelessWidget {
  const HooksDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Hooks Demo')),
      body: const _HooksDemoContent(),
    );
  }
}

class _HooksDemoContent extends HookWidget {
  const _HooksDemoContent();

  @override
  Widget build(BuildContext context) {
    return [
      _sectionTitle('1. useState — Simple State'),
      const Text('State managed without StatefulWidget.'),
      _h(12),
      const _UseStateDemo(),

      _h(32),
      _sectionTitle('2. useReducer — Complex State Transitions'),
      const Text('Manage multi-field state with actions, like a mini Redux.'),
      _h(12),
      const _UseReducerDemo(),

      _h(32),
      _sectionTitle('3. useEffect — Lifecycle & Cleanup'),
      const Text(
        'Run side-effects and clean up when widget unmounts. Check the debug console.',
      ),
      _h(12),
      const _UseEffectDemo(),

      _h(32),
      _sectionTitle(
        '4. useAnimationController — Animation without TickerProvider',
      ),
      const Text(
        'Create and control animations without mixing in SingleTickerProviderStateMixin.',
      ),
      _h(12),
      const _UseAnimationDemo(),

      _h(32),
      _sectionTitle('5. useTextEditingController — Text Input'),
      const Text('Manage text input with automatic controller lifecycle.'),
      _h(12),
      const _UseTextEditingControllerDemo(),

      _h(32),
      _sectionTitle('6. useMemoized — Expensive Computation Cache'),
      const Text(
        'Memoize expensive calculations so they only run when dependencies change.',
      ),
      _h(12),
      const _UseMemoizedDemo(),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).padding(all: 16).scrollable();
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ).padding(bottom: 8);
  }
}

// --- useState Demo ---
class _UseStateDemo extends HookWidget {
  const _UseStateDemo();

  @override
  Widget build(BuildContext context) {
    final counter = useState(0);

    return [
      [
        IconButton.filled(
          onPressed: () => counter.value--,
          icon: const Icon(Icons.remove),
        ),
        _w(24),
        Text(
          '${counter.value}',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        _w(24),
        IconButton.filled(
          onPressed: () => counter.value++,
          icon: const Icon(Icons.add),
        ),
      ].toRow(mainAxisAlignment: MainAxisAlignment.center),
      _h(8),
      ValueListenableBuilder(
        valueListenable: counter,
        builder: (_, value, _) {
          final emoji = switch (value) {
            < 0 => '😢',
            0 => '😐',
            < 5 => '🙂',
            < 10 => '😄',
            _ => '🤩',
          };
          return Text(emoji, style: const TextStyle(fontSize: 32));
        },
      ),
    ].toColumn();
  }
}

// --- useReducer Demo ---
class _FormState {
  final String name;
  final String email;
  final bool isSubmitting;

  const _FormState({
    this.name = '',
    this.email = '',
    this.isSubmitting = false,
  });

  _FormState copyWith({String? name, String? email, bool? isSubmitting}) {
    return _FormState(
      name: name ?? this.name,
      email: email ?? this.email,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

sealed class _FormAction {}

class _UpdateName extends _FormAction {
  final String name;
  _UpdateName(this.name);
}

class _UpdateEmail extends _FormAction {
  final String email;
  _UpdateEmail(this.email);
}

class _ToggleSubmit extends _FormAction {}

_FormState _formReducer(_FormState state, _FormAction action) {
  return switch (action) {
    _UpdateName(name: final n) => state.copyWith(name: n),
    _UpdateEmail(email: final e) => state.copyWith(email: e),
    _ToggleSubmit() => state.copyWith(isSubmitting: !state.isSubmitting),
  };
}

class _UseReducerDemo extends HookWidget {
  const _UseReducerDemo();

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final form = useReducer<_FormState, _FormAction>(
      _formReducer,
      initialState: const _FormState(),
      initialAction: _UpdateName(''),
    );

    return [
      TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: 'Name'),
        onChanged: (value) => form.dispatch(_UpdateName(value)),
      ),
      _h(8),
      TextField(
        controller: emailController,
        decoration: const InputDecoration(labelText: 'Email'),
        onChanged: (value) => form.dispatch(_UpdateEmail(value)),
      ),
      _h(12),
      ElevatedButton.icon(
        onPressed: () => form.dispatch(_ToggleSubmit()),
        icon: const Icon(Icons.send),
        label: const Text('Toggle Submit State'),
      ),
      _h(8),
      Text(
        'State → name: "${form.state.name}", '
        'email: "${form.state.email}", '
        'submitting: ${form.state.isSubmitting}',
        style: const TextStyle(fontFamily: 'monospace'),
      ),
    ].toColumn();
  }
}

// --- useEffect Demo ---
class _UseEffectDemo extends HookWidget {
  const _UseEffectDemo();

  @override
  Widget build(BuildContext context) {
    final ticks = useState(0);

    useEffect(() {
      // ignore: avoid_print
      print('[useEffect] Timer started');
      return () {
        // ignore: avoid_print
        print('[useEffect] Cleanup: widget unmounting or re-running');
      };
    }, []);

    useEffect(() {
      // ignore: avoid_print
      print('[useEffect] Ticks changed to: ${ticks.value}');
      return () {
        // ignore: avoid_print
        print('[useEffect] Previous tick effect cleaned up');
      };
    }, [ticks.value]);

    return [
      ElevatedButton.icon(
        onPressed: () => ticks.value++,
        icon: const Icon(Icons.update),
        label: Text('Tick: ${ticks.value}'),
      ),
      _h(8),
      const Text(
        'Each click re-runs the effect. Check the console for logs.',
        textAlign: TextAlign.center,
      ),
    ].toColumn();
  }
}

// --- useAnimationController Demo ---
class _UseAnimationDemo extends HookWidget {
  const _UseAnimationDemo();

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 2),
    );
    final animation = useAnimation(
      CurvedAnimation(parent: controller, curve: Curves.elasticInOut),
    );

    return [
      SizedBox(
        height: 80,
        child: Center(
          child: AnimatedBuilder(
            animation: controller,
            builder: (_, _) {
              return Transform.scale(
                scale: 0.5 + animation * 0.5,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(animation * 30),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      [
        ElevatedButton.icon(
          onPressed: () => controller.forward(from: 0),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Animate'),
        ),
        _w(8),
        OutlinedButton.icon(
          onPressed: controller.reset,
          icon: const Icon(Icons.stop),
          label: const Text('Reset'),
        ),
      ].toRow(mainAxisAlignment: MainAxisAlignment.center),
    ].toColumn();
  }
}

// --- useTextEditingController Demo ---
class _UseTextEditingControllerDemo extends HookWidget {
  const _UseTextEditingControllerDemo();

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final charCount = useMemoized(() => controller.text.length, [
      controller.text,
    ]);

    return [
      TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Type something',
          suffixText: '$charCount chars',
        ),
        maxLines: 2,
      ),
      _h(8),
      [
        ElevatedButton.icon(
          onPressed: () => controller.text = 'Hello, Flutter Hooks!',
          icon: const Icon(Icons.auto_fix_high),
          label: const Text('Fill'),
        ),
        _w(8),
        OutlinedButton.icon(
          onPressed: controller.clear,
          icon: const Icon(Icons.clear),
          label: const Text('Clear'),
        ),
      ].toRow(),
    ].toColumn();
  }
}

// --- useMemoized Demo ---
class _UseMemoizedDemo extends HookWidget {
  const _UseMemoizedDemo();

  int _expensiveCalculation(int n) {
    var result = 0;
    for (var i = 0; i < n * 1000; i++) {
      result += i;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final number = useState(100);
    final callCount = useState(0);

    final result = useMemoized(() {
      callCount.value++;
      return _expensiveCalculation(number.value);
    }, [number.value]);

    return [
      Text('Input: ${number.value}'),
      Slider(
        value: number.value.toDouble(),
        min: 10,
        max: 500,
        divisions: 49,
        onChanged: (v) => number.value = v.round(),
      ),
      _h(8),
      Text(
        'Cached result: $result\n'
        'Recalculation count: ${callCount.value}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'monospace'),
      ),
      const Text(
        'Slide to change. Result is only recalculated when the value changes, not on every rebuild.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ].toColumn();
  }
}
