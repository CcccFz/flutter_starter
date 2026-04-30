import 'package:fquery_core/fquery_core.dart';

/// Global FQuery cache instance.
///
/// All queries and mutations share this cache for data management,
/// caching, invalidation, and garbage collection.
final queryCache = QueryCache();
