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
      if (page == 1) {
        state = const AsyncLoading();
      } else {
        // Keep current data while loading more
        final currentState = state.value;
        if (currentState != null) {
          state = AsyncData({
            ...currentState,
            'isLoadingMore': true,
          });
        }
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
        final newItems = List<Map<String, dynamic>>.from(response.data['items']);

        Map<String, dynamic> result;
        
        if (page == 1) {
          // First page - replace all items
          result = {
            'items': newItems,
            'totalCount': totalCount,
            'currentPage': page,
            'totalPages': totalPages,
            'hasMore': page < totalPages,
            'isLoadingMore': false,
          };
        } else {
          // Subsequent pages - append to existing items
          final currentState = state.value;
          final existingItems = currentState?['items'] as List<Map<String, dynamic>>? ?? [];
          result = {
            'items': [...existingItems, ...newItems],
            'totalCount': totalCount,
            'currentPage': page,
            'totalPages': totalPages,
            'hasMore': page < totalPages,
            'isLoadingMore': false,
          };
        }

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

  void clearCache() {
    _cache.clear();
    state = const AsyncData({});
  }
}

final searchGitHubProvider =
    AsyncNotifierProvider<SearchGitHubNotifier, Map<String, dynamic>>(
      SearchGitHubNotifier.new, 
    );
