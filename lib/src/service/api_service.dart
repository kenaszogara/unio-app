import 'package:Unio/src/utilities/global.dart';
import 'package:dio/dio.dart';

Dio apiClient() {
  Dio api = Dio();
  api.interceptors.clear();
  api.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    dynamic token = Global.instance.apiToken;
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }, onResponse: (response, handler) {
    print(response.data);
    handler.next(response);
  }, onError: (DioError err, ErrorInterceptorHandler handler) {
    print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    handler.next(err);
  }));
  api.options.baseUrl = SERVER_DOMAIN;
  return api;
}
