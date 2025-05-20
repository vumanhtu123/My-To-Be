import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect.dart';
import 'package:my_to_be/common/base.url.dart';
import 'package:my_to_be/utils/network.utils.dart';

class ApiService extends GetConnect {
  ApiService() {
    httpClient.baseUrl = ApiConst.baseUrl;
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 30);
  }

  /// Generic GET for Invidious
  Future<Map<String, dynamic>> getInvidious(
      String endpoint, {
        Map<String, dynamic>? params,
        bool debug = false,
      }) async {
    // bool isOnline = await NetworkUtils.hasInternetConnection();
    //
    // if (!isOnline) {
    //   return {
    //     'status': 0,
    //     'error': 'Không có kết nối Internet.',
    //     'raw': null,
    //   };
    // }

    final response = await get(endpoint, query: params, headers: {
      'Accept': 'application/json',
    });

    if (debug) {
      _debugLog(
        method: 'GET',
        url: '${httpClient.baseUrl}$endpoint',
        params: params ?? {},
        response: response,
      );
    }

    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(Response response) {
    final status = response.statusCode ?? 0;
    final success = status >= 200 && status < 300;

    return {
      'status': status,
      if (success) 'data': response.body else 'error': _handleError(response),
      'raw': response.body,
    };
  }

  String _handleError(Response response) {
    if (response.status.connectionError) {
      return 'Mất kết nối.';
    } else if (response.statusText != null && response.statusText!.isNotEmpty) {
      return response.statusText!;
    } else {
      return 'Đã xảy ra lỗi không xác định.';
    }
  }

  /// Debug Log
  void _debugLog({
    required String method,
    required String url,
    required Map<String, dynamic> params,
    required Response response,
  }) {
    debugPrint('========== INVIDIOUS API DEBUG ==========');
    debugPrint('$method $url');
    debugPrint('Params: $params');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('=========================================');

    if (kDebugMode) {
      log('[$method] $url');
      log('Params: $params');
      log('Response: ${response.body}');
    }
  }
}

final apiService = ApiService();
