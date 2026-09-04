import 'package:dio/dio.dart';

/// Shared API boundary for a future remote product repository.
/// No network calls are implemented while DummyData is active.
class CatalogService {
  const CatalogService(this._dio);
  final Dio _dio;

  Dio get client => _dio;
}
