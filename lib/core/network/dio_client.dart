import 'package:dio/dio.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/network/api_endpoints.dart';
import 'package:sultan_app/core/network/api_interceptor.dart';

class DioClient {
  DioClient(ApiInterceptor interceptor)
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: AppConstants.connectTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
          sendTimeout: AppConstants.sendTimeout,
          contentType: Headers.jsonContentType,
        ),
      )..interceptors.add(interceptor);

  final Dio dio;
}
