import 'package:flutter/material.dart';
import 'package:fquery/fquery.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/query_cache.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // CacheProvider provides the fquery cache to all descendants.
    return CacheProvider(
      cache: queryCache,
      child: MaterialApp.router(
        title: 'Flutter Starter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
