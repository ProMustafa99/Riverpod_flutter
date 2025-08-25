import 'package:dio/dio.dart';
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
  final Map<String, dynamic> _cache = {};

  @override
  Future<Map<String, dynamic>> build() async {
    return {}; // initial state
  }

  Future<void> searchGitHub(String query, int page) async {
    final cacheKey = '${query.trim().toLowerCase()}_$page';

    if (_cache.containsKey(cacheKey)) {
      state = AsyncData(_cache[cacheKey]!);
      return;
    } else {
      state = const AsyncLoading();

      if (page == 1) {
        state = const AsyncLoading();
      } else {
        // _isLoadingMore = true;
      }
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

        final perPage = 10;
        final totalCount = response.data['total_count'] as int;
        final totalPages = (totalCount / perPage).ceil();

        final result = {
          'items': List<Map<String, dynamic>>.from(response.data['items']),
          'totalCount': totalCount,
          'currentPage': page,
          'totalPages': totalPages,
          'hasMore': page < totalPages,
        };

        // Save result to cache
        if (_cache.length >= 2) {
          // Clear only the first item (oldest cache entry)
          final keys = _cache.keys.toList();
          if (keys.isNotEmpty) {
            _cache.remove(keys.first);
          }
        }
        _cache[cacheKey] = result;
        state = AsyncData(result);
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    }
  }
}

final searchGitHubProvider =
    AsyncNotifierProvider<SearchGitHubNotifier, Map<String, dynamic>>(
      SearchGitHubNotifier.new, 
    );
