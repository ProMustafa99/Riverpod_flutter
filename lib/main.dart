import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_flutter/porvider/simple_provider.dart';
import 'google_map /google_map.dart';

void main() {
  // ProviderScope is a widget that stores all provider states globally
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SearchGitHub(),
      // home: const GoogleMapScreen(),
    );
  }
}

class SimpleProvderData extends ConsumerWidget {
  const SimpleProvderData({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simpleData = ref.watch(simpleProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Provider Data')),
      body: Center(child: Text(simpleData)),
    );
  }
}

class SearchGitHub extends ConsumerStatefulWidget {
  const SearchGitHub({super.key});

  @override
  ConsumerState<SearchGitHub> createState() => _SearchGitHubState();
}

class _SearchGitHubState extends ConsumerState<SearchGitHub> {
  final textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final githubData = ref.watch(searchGitHubProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Repository Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              ref.read(searchGitHubProvider.notifier).clearCache();
              textController.clear();
            },
            tooltip: 'Clear Cache',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Search for a repository',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    textController.clear();
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  ref
                      .read(searchGitHubProvider.notifier)
                      .searchGitHub(value, 1);
                }
              },
            ),
          ),

          if (textController.text.isEmpty)
            Expanded(child: message())
          else
            githubData.when(
              data: (githubData) => Expanded(
                child: Column(
                  children: [
                    // Results count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text(
                            '${githubData['items'].length} of ${githubData['totalCount']} results',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          if (githubData['hasMore'] == true)
                            const Text(
                              'Scroll to load more',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Repository list
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            (githubData['items'] as List).length +
                            (githubData['isLoadingMore'] == true ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == (githubData['items'] as List).length) {
                            // Loading indicator at the bottom
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final item = (githubData['items'] as List)[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: ListTile(
                              title: Text(
                                item['full_name']?.toString() ?? 'No title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item['description'] != null)
                                    Text(
                                      item['description'].toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['stargazers_count']?.toString() ??
                                            '0',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(
                                        Icons.call_split,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['forks_count']?.toString() ?? '0',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(
                                        Icons.language,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['language']?.toString() ?? 'N/A',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Could open repository URL here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Selected: ${item['full_name']}',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  void _loadMore() {
    final currentData = ref.read(searchGitHubProvider);
    final hasMore = currentData.value?['hasMore'] as bool? ?? false;
    final isLoadingMore = currentData.value?['isLoadingMore'] as bool? ?? false;
    final currentPage = currentData.value?['currentPage'] as int? ?? 1;

    if (hasMore && textController.text.isNotEmpty && !isLoadingMore) {
      ref
          .read(searchGitHubProvider.notifier)
          .searchGitHub(textController.text, currentPage + 1);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    textController.dispose();
    super.dispose();
  }
}

Widget message() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'Please enter a search term',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Search for GitHub repositories',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    ),
  );
}

Widget paginationNumber(
  int maxNumberOfPages,
  WidgetRef ref,
  String searchQuery,
) {
  final currentPage = ref.watch(pageNotifier);
  const visibleCount = 5; // show max 5 buttons

  debugPrint('Current Page: $currentPage');
  debugPrint('Max Number of Pages: $maxNumberOfPages');
  debugPrint('Visible Count: $visibleCount');
  debugPrint('Visible Count Call: ${visibleCount ~/ 2}');
  debugPrint('Start: ${currentPage - (visibleCount ~/ 2)}');
  debugPrint('End: ${currentPage + (visibleCount ~/ 2)}');

  // clamp (lowerlimit, upperlimit)
  // Determine start & end window
  int start = (currentPage - (visibleCount ~/ 2)).clamp(
    1,
    maxNumberOfPages - visibleCount + 1,
  );
  debugPrint('StartClamp: $start');
  int end = (start + visibleCount - 1).clamp(1, maxNumberOfPages);
  debugPrint('EndClamp: $end');

  return Wrap(
    spacing: 6,
    children: List.generate(end - start + 1, (index) {
      final page = start + index;
      final isActive = page == currentPage;

      return TextButton(
        onPressed: () {
          ref.read(pageNotifier.notifier).state = page;
          // Trigger new search with updated page
          if (searchQuery.isNotEmpty) {
            ref
                .read(searchGitHubProvider.notifier)
                .searchGitHub(searchQuery, page);
          }
        },
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.white,
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }),
  );
}
