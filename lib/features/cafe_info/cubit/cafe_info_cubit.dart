import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/features/cafe_info/cubit/cafe_info_state.dart';

class CafeInfoCubit extends Cubit<CafeInfoState> {
  CafeInfoCubit(this._repository) : super(const CafeInfoState());
  final HomeRepository _repository;

  Future<void> loadCafeInfo() async {
    emit(const CafeInfoState(status: CafeInfoStatus.loading));
    try {
      final info = await _repository.getCafeInfo();
      if (!isClosed) {
        emit(CafeInfoState(status: CafeInfoStatus.success, info: info));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          const CafeInfoState(
            status: CafeInfoStatus.failure,
            errorMessage: 'تعذر تحميل معلومات الكافيه',
          ),
        );
      }
    }
  }
}
