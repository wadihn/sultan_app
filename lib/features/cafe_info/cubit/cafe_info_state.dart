import 'package:sultan_app/models/cafe_info_model.dart';

enum CafeInfoStatus { initial, loading, success, failure }

class CafeInfoState {
  const CafeInfoState({
    this.status = CafeInfoStatus.initial,
    this.info,
    this.errorMessage,
  });
  final CafeInfoStatus status;
  final CafeInfoModel? info;
  final String? errorMessage;
}
