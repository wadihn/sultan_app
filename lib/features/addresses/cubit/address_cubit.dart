import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/data/repositories/address_repository.dart';
import 'package:sultan_app/features/addresses/cubit/address_state.dart';
import 'package:sultan_app/models/address_model.dart';
import 'package:sultan_app/models/requests/create_address_request.dart';
import 'package:sultan_app/models/requests/update_address_request.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit(this._repository) : super(const AddressState());

  final AddressRepository _repository;

  Future<void> loadAddresses() async {
    emit(state.copyWith(status: AddressStatus.loading, clearError: true));
    try {
      final addresses = await _repository.getAddresses();
      final deliveryZones = await _repository.getDeliveryZones();
      emit(
        state.copyWith(
          status: AddressStatus.success,
          addresses: addresses,
          deliveryZones: deliveryZones,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AddressStatus.failure,
          errorMessage: 'تعذر تحميل العناوين المحفوظة',
        ),
      );
    }
  }

  Future<bool> addAddress(CreateAddressRequest request) =>
      _save(() => _repository.createAddress(request));

  Future<bool> updateAddress(int addressId, UpdateAddressRequest request) =>
      _save(() => _repository.updateAddress(addressId, request));

  Future<bool> _save(Future<AddressModel> Function() operation) async {
    if (state.isSaving) return false;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await operation();
      final addresses = await _repository.getAddresses();
      emit(
        state.copyWith(
          status: AddressStatus.success,
          addresses: addresses,
          isSaving: false,
          clearError: true,
        ),
      );
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'تعذر حفظ العنوان، حاول مرة أخرى',
        ),
      );
      return false;
    }
  }

  Future<void> deleteAddress(int addressId) async {
    try {
      await _repository.deleteAddress(addressId);
      final addresses = await _repository.getAddresses();
      emit(
        state.copyWith(
          status: AddressStatus.success,
          addresses: addresses,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(state.copyWith(errorMessage: 'تعذر حذف العنوان'));
    }
  }
}
