import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/core/utils/opening_hours_validator.dart';
import 'package:sultan_app/data/repositories/home_repository.dart';
import 'package:sultan_app/features/home/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState());
  final HomeRepository _repository;

  Future<void> loadHome() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final cafeInfo = await _repository.getCafeInfo();
      final categories = await _repository.getCategories();
      final offers = await _repository.getOffers();
      final popularProducts = await _repository.getPopularProducts();
      emit(
        HomeState(
          status: HomeStatus.success,
          cafeInfo: cafeInfo,
          isCafeOpen: OpeningHoursValidator.isOpenAt(
            cafeInfo.openingHours,
            DateTime.now(),
          ),
          categories: categories,
          offers: offers,
          popularProducts: popularProducts,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: 'تعذر تحميل بيانات الرئيسية',
        ),
      );
    }
  }
}
