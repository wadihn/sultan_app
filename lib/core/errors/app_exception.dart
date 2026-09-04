sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'تعذر الاتصال بالإنترنت']);
}

final class ServerException extends AppException {
  const ServerException([super.message = 'تعذر إكمال الطلب']);
}

final class StorageException extends AppException {
  const StorageException([super.message = 'تعذر الوصول إلى البيانات المحلية']);
}
