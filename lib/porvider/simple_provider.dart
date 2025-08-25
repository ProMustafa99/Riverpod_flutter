import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final simpleProvider = Provider<String>((ref) {
  return 'Hello World';
});

// Change state of provider
class PagetionNotifier extends Notifier<int> {
  @override
  int build() {
    return 1;
  }

  void nextPage() {
    state++;
  }

  void previousPage() {
    if (state > 1) {
      state--;
    }
  }
}

final pageNotifier = NotifierProvider<PagetionNotifier, int>(
  () => PagetionNotifier(),
);

// AsyncNotifier for GitHub Search

class SearchGitHubNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    return {}; // initial state
  }

  Future<void> searchGitHub(String query, int page) async {
    state = const AsyncLoading();

    debugPrint('Search GitHub: $query, $page');

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.github.com/search/repositories',
        queryParameters: {'q': query, 'per_page': 10, 'page': page},
        options: Options(
          headers: {
            'Accept': 'application/vnd.github+json',
            'User-Agent': 'FlutterApp',
          },
        ),
      );

      final result = {
        'items': List<Map<String, dynamic>>.from(response.data['items']),
        'totalCount': response.data['total_count'],
        'currentPage': page,
        'totalPages': response.data['total_pages'],
      };
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final searchGitHubProvider =
    AsyncNotifierProvider<SearchGitHubNotifier, Map<String, dynamic>>(
      SearchGitHubNotifier.new,
    );
