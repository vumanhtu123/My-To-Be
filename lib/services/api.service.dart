import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get_connect/connect.dart';

import '../common/base.url.dart';

class ApiService extends GetConnect {

  ApiService() {
    httpClient.baseUrl = ApiConst.test;
    httpClient.defaultContentType = "application/json";
    httpClient.timeout = const Duration(minutes: 1);
  }

  Future<Map<String, dynamic>> getM(String url, Map<String, dynamic> params,
      {bool hasHeaders = true}) async {
    Map<String, String> mapHeaders = {};
    if (hasHeaders) {
      // mapHeaders["authorization"] =
      // "Bearer ${StorageData.instance.getAppToken()}";
    }
    // mapHeaders["imei"] = await MerUtils.getDeviceId();
    Response response = await get(url, query: params, headers: mapHeaders);
    _apiDebug(
      url: "GET: ${httpClient.baseUrl}$url",
      headers: mapHeaders,
      formData: null,
      params: params,
      response: response,
    );
    return _apiMap(response);
  }

  Future<Map<String, dynamic>> postM(String url, Map<String, dynamic> params,
      {bool hasHeaders = true, FormData? formData, String? appToken}) async {
    Map<String, String> mapHeaders = {};
    // final token = appToken ?? StorageData.instance.getAppToken();
    // if (hasHeaders && token != null) {
    //   mapHeaders["authorization"] = "Bearer $token";
    // }
    // mapHeaders["imei"] = await MerUtils.getDeviceId();
    Response response =
    await post(url, formData ?? params, headers: mapHeaders);
    _apiDebug(
      url: "POST: ${httpClient.baseUrl}$url",
      headers: mapHeaders,
      formData: formData,
      params: params,
      response: response,
    );
    return _apiMap(response);
  }

  Future<Map<String, dynamic>> putM(String url, Map<String, dynamic> params,
      {bool hasHeaders = true, FormData? formData}) async {
    Map<String, String> mapHeaders = {};
    // if (hasHeaders) {
    //   mapHeaders["authorization"] =
    //   "Bearer ${StorageData.instance.getAppToken()}";
    // }
    // mapHeaders["imei"] = await MerUtils.getDeviceId();
    Response response = await put(url, formData ?? params, headers: mapHeaders);
    _apiDebug(
      url: "PUT: ${httpClient.baseUrl}$url",
      headers: mapHeaders,
      formData: formData,
      params: params,
      response: response,
    );
    return _apiMap(response);
  }

  Map<String, dynamic> _apiMap(Response response) {
    if (response.statusCode == 401) {
      // final token = StorageData.instance.getAppToken();
      // if (token != null) {
      //   final refreshToken = StorageData.instance.getRefreshToken();
      //   StorageData.instance.setAppToken(null);
      //   Get.offAll(() => const RefreshTokenPage(),
      //       arguments: {'token': refreshToken});
      // }
    }
    // try {
      // if (response.body == null) {
      //   return response;
        // return BaseModel.toMap(response.statusCode, errorHttp(response));
      // }
      Map<String, dynamic> map = Map.from(response.body);
      map["status"] = response.statusCode;
      return map;
    // } catch (error) {
    //   return
    // }
  }

  String errorHttp(Response response) {
    if(response.status.connectionError) {
      return 'Network Error';
    }
    return response.statusText ?? '';
  }

  _apiDebug({
    required String url,
    required Map<String, String> headers,
    required FormData? formData,
    Map<String, dynamic>? params,
    required Response response,
  }) {
    debugPrint("-----------------------------------");
    debugPrint(url);
    debugPrint('Headers: ${headers.toString()}');
    debugPrint('Params: ${formData ?? params.toString()}');
    debugPrint("${response.statusCode}, ${response.statusText}");
    log(response.body.toString());
    debugPrint("-----------------------------------");
  }
}

final apiService = ApiService();