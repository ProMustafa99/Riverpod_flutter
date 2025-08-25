import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_flutter/porvider/simple_provider.dart';

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

class SearchGitHub extends ConsumerWidget {
  SearchGitHub({super.key});
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final githubData = ref.watch(searchGitHubProvider);
    final page = ref.watch(pageNotifier);

    return Scaffold(
      appBar: AppBar(title: const Text('User Data')),
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
              ),
              onSubmitted: (value) {
                ref
                    .read(searchGitHubProvider.notifier)
                    .searchGitHub(value, page);
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: (githubData['items'] as List).length,
                        itemBuilder: (context, index) {
                          final item = (githubData['items'] as List)[index];
                          return ListTile(
                            title: Text(
                              item['full_name']?.toString() ?? 'No title',
                            ),
                            subtitle: Text(
                              '⭐ ${item['stargazers_count']?.toString() ?? '0'} stars',
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          pagination(
                            githubData['totalCount'] as int,
                            ref,
                            textController.text,
                          ),
                        ],
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

Widget pagination(int maxNumberOfPages, WidgetRef ref, String searchQuery) {
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
