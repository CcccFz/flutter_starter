import 'package:go_router/go_router.dart';

import '../../features/home/home_page.dart';
import '../../features/signals_demo/signals_page.dart';
import '../../features/hooks_demo/hooks_page.dart';
import '../../features/fquery_demo/fquery_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const HomePage(),
    ),
    GoRoute(
      path: '/signals',
      builder: (_, _) => const SignalsDemoPage(),
    ),
    GoRoute(
      path: '/hooks',
      builder: (_, _) => const HooksDemoPage(),
    ),
    GoRoute(
      path: '/fquery',
      builder: (_, _) => const FQueryDemoPage(),
    ),
  ],
);
