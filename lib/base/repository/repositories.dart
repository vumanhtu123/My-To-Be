import 'package:flutter/cupertino.dart';
import 'package:my_to_be/base/networking/api.service.dart';

import '../../common/base.url.dart';

class Repositories {
  Future<dynamic> fetchPopularVideos() async {
    final result = await apiService.getInvidious(
      ApiConst.endPointTrending,
      params: {
        'region': 'VN',
        'type': 'all',
      },
      debug: true,
    );
    if (result['status'] == 200) {
      final videos = result['data'];
      return videos;
    } else {
      print('Lỗi: ${result['error']}');
      return result['error'];
    }
  }

  Future<dynamic> fetchSearchVideos({
    String query = 'video trend',
    String type = 'video', // video | channel | playlist | all
    String sort = 'relevance', // relevance | rating | upload_date | view_count
    String region = 'VN',
    int page = 1,
    int? durationMin,
    int? durationMax,
    bool debug = false,
  }) async {
    final Map<String, dynamic> params = {
      'q': query,
      'type': type,
      'sort': sort,
      'region': region,
      'page': page.toString(),
    };

    // Nếu có lọc thời lượng
    if (durationMin != null) params['duration_min'] = durationMin.toString();
    if (durationMax != null) params['duration_max'] = durationMax.toString();

    final result = await apiService.getInvidious(
      ApiConst.endPointSearch,
      params: params,
      debug: debug,
    );

    if (result['status'] == 200 && result['data'] is List) {
      return result['data'];
    } else {
      debugPrint('Lỗi: ${result['error']}');
      return result['error'];
    }
  }

  Future<dynamic> getInvidious({
    String id = '',
    bool debug = false,
  }) async {
    final Map<String, dynamic> params = {
      'id': id,
    };

    final result = await apiService.getInvidious(
      ApiConst.endPointVideos,
      params: params,
      debug: debug,
    );

    if (result['status'] == 200 && result['data'] is List) {
      return result['data'];
    } else {
      debugPrint('Lỗi: ${result['error']}');
      return result['error'];
    }
  }
}
