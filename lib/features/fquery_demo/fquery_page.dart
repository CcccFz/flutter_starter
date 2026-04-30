import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:fquery_core/fquery_core.dart';
import 'package:signals/signals_flutter.dart';

import '../../core/query_cache.dart';
import '../../models/user.dart';
import '../../models/post.dart';
import '../../services/api_service.dart';

Widget _h(double height) => SizedBox(height: height);
Widget _w(double width) => SizedBox(width: width);

/// FQuery Demo Page
///
/// Demonstrates:
/// - `useQuery` — fetch & cache async data with loading/error states
/// - `useMutation` — create data with cache invalidation
/// - `QueryCache.invalidateQueries` — manual cache refresh
/// - Conditional/dependent queries (posts only fetch when user expanded)
///
/// Uses DummyJSON (https://dummyjson.com) as the public, no-auth API source.
class FQueryDemoPage extends StatelessWidget {
  const FQueryDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FQuery Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.article), text: 'Posts'),
              Tab(icon: Icon(Icons.swap_horiz), text: 'Mutation'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_UsersTab(), _PostsTab(), _MutationTab()],
        ),
      ),
    );
  }
}

// ==================== Users Tab ====================

class _UsersTab extends HookWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    final api = ApiService();

    final usersQuery = useQuery<List<User>, Exception>(
      ['users'],
      () => api.getUsers(),
      context: context,
      staleDuration: const Duration(minutes: 1),
    );

    return RefreshIndicator(
      onRefresh: () async => usersQuery.refetch(),
      child: CustomScrollView(
        slivers: [
          [
                _statusBar(
                  isLoading: usersQuery.isLoading,
                  isFetching: usersQuery.isFetching,
                  hasData: usersQuery.data != null,
                ),
                _h(8),
                [
                  ElevatedButton.icon(
                    onPressed: () => usersQuery.refetch(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refetch'),
                  ),
                  _w(8),
                  OutlinedButton.icon(
                    onPressed: () => queryCache.invalidateQueries(['users']),
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Invalidate'),
                  ),
                ].toRow(),
              ]
              .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
              .padding(all: 16)
              .sliverToBoxAdapter(),
          SliverToBoxAdapter(
            child: usersQuery.isLoading && usersQuery.data == null
                ? const _LoadingIndicator()
                : usersQuery.isError && usersQuery.data == null
                ? _ErrorWidget(
                    error: usersQuery.error.toString(),
                    onRetry: () => usersQuery.refetch(),
                  )
                : const SizedBox.shrink(),
          ),
          if (usersQuery.data != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((_, index) {
                  final user = usersQuery.data![index];
                  return _UserCard(user: user);
                }, childCount: usersQuery.data!.length),
              ),
            ),
          if (usersQuery.isFetching && usersQuery.data != null)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: _LoadingIndicator(),
              ),
            ),
          SliverToBoxAdapter(child: _h(16)),
        ],
      ),
    );
  }
}

class _UserCard extends HookWidget {
  final User user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);

    // Dependent query: only enabled when user is expanded
    final postsQuery = useQuery<List<Post>, Exception>(
      ['posts', 'user', user.id],
      () => ApiService().getPostsByUser(user.id),
      context: context,
      enabled: expanded.value,
      staleDuration: const Duration(minutes: 5),
    );

    final fullName = '${user.firstName} ${user.lastName}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              user.firstName[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          title: Text(fullName),
          subtitle: Text(user.email),
          trailing: Icon(
            expanded.value ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () => expanded.value = !expanded.value,
        ),
        if (expanded.value)
          [
                Text(
                  '${user.address.city}, ${user.address.state} · ${user.address.country}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                _h(4),
                Text(
                  user.phone,
                  style: const TextStyle(fontSize: 12),
                ),
                const Divider(height: 24),
                if (postsQuery.isLoading)
                  const _LoadingIndicator()
                else if (postsQuery.isError)
                  Text(
                    'Failed to load posts: ${postsQuery.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  )
                else if (postsQuery.data != null)
                  Text(
                    'Posts by this user: ${postsQuery.data!.length}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ]
              .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
              .padding(top: 0, left: 16, right: 16, bottom: 16),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
    );
  }
}

// ==================== Posts Tab ====================

class _PostsTab extends HookWidget {
  const _PostsTab();

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    final searchSignal = signal('');

    final postsQuery = useQuery<List<Post>, Exception>(
      ['posts'],
      () => api.getPosts(),
      context: context,
      staleDuration: const Duration(minutes: 2),
    );

    return [
      [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search posts by title',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => searchSignal.value = value.toLowerCase(),
        ),
        _h(8),
        _statusBar(
          isLoading: postsQuery.isLoading,
          isFetching: postsQuery.isFetching,
          hasData: postsQuery.data != null,
        ),
      ].toColumn().padding(all: 16),
      postsQuery.isLoading && postsQuery.data == null
          ? const _LoadingIndicator()
          : postsQuery.isError && postsQuery.data == null
          ? _ErrorWidget(
              error: postsQuery.error.toString(),
              onRetry: () => postsQuery.refetch(),
            ).center()
          : Watch((_) {
              final search = searchSignal.value;
              final allPosts = postsQuery.data ?? [];
              final filtered = search.isEmpty
                  ? allPosts
                  : allPosts
                        .where((p) => p.title.toLowerCase().contains(search))
                        .toList();

              if (filtered.isEmpty && search.isNotEmpty) {
                return const Center(child: Text('No posts match your search.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final post = filtered[index];
                  return _PostCard(post: post);
                },
              );
            }).expanded(),
    ].toColumn();
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          post.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(post.body, maxLines: 3, overflow: TextOverflow.ellipsis),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            '${post.id}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (post.tags.isNotEmpty)
              Text(
                post.tags.take(2).join(', '),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            _h(2),
            Text(
              '${post.reactions?.likes ?? 0} 👍',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

// ==================== Mutation Tab ====================

class _MutationTab extends HookWidget {
  const _MutationTab();

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController();
    final bodyController = useTextEditingController();
    final resultMessage = useState('');

    // Mutation for creating a post
    final createMutation =
        useMutation<Post, Exception, Map<String, String>, void>(
          (vars) => ApiService().createPost(vars),
          onMutate: (_) => null,
          onSuccess: (data, _, _) {
            resultMessage.value =
                'Created! ID: ${data.id}, Title: ${data.title}';
            titleController.clear();
            bodyController.clear();
            // Invalidate the posts cache so the Posts tab shows fresh data
            queryCache.invalidateQueries(['posts']);
          },
          onError: (error, _, _) {
            resultMessage.value = 'Error: $error';
          },
        );

    final isMutating = createMutation.status == MutationStatus.pending;

    return [
          const Text(
            'Create a new post via POST request to DummyJSON.\n'
            '(Note: DummyJSON simulates creation — returns a fake ID)',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          _h(16),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          _h(12),
          TextField(
            controller: bodyController,
            decoration: const InputDecoration(
              labelText: 'Body',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          _h(16),
          ElevatedButton.icon(
            onPressed: isMutating
                ? null
                : () {
                    if (titleController.text.isEmpty ||
                        bodyController.text.isEmpty) {
                      resultMessage.value = 'Please fill in both fields.';
                      return;
                    }
                    createMutation.mutate({
                      'title': titleController.text,
                      'body': bodyController.text,
                      'userId': '1',
                    });
                  },
            icon: isMutating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(isMutating ? 'Creating...' : 'Create Post'),
          ),
          _h(16),
          if (resultMessage.value.isNotEmpty)
            Card(
              color: createMutation.status == MutationStatus.error
                  ? Colors.red.shade50
                  : Colors.green.shade50,
              child: Text(resultMessage.value).padding(all: 12),
            ),
        ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
        .padding(all: 16)
        .scrollable();
  }
}

// ==================== Shared Widgets ====================

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: 16.paddingAll(),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return [
      const Icon(Icons.error_outline, size: 48, color: Colors.red),
      _h(8),
      Text('Error: $error', textAlign: TextAlign.center),
      _h(12),
      ElevatedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Retry'),
      ),
    ].toColumn(mainAxisSize: MainAxisSize.min).padding(all: 16).center();
  }
}

Widget _statusBar({
  required bool isLoading,
  required bool isFetching,
  required bool hasData,
}) {
  return [
        Icon(
          isLoading ? Icons.sync : Icons.check_circle,
          size: 16,
          color: isLoading ? Colors.orange : Colors.green,
        ),
        _w(6),
        Text(
          isLoading
              ? 'Loading...'
              : isFetching
              ? 'Refetching...'
              : 'Data: ${hasData ? "loaded" : "none"}',
          style: const TextStyle(fontSize: 12),
        ),
      ]
      .toRow()
      .padding(horizontal: 12, vertical: 6)
      .decorated(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      );
}
