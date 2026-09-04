import 'package:sultan_app/data/dummy/dummy_data.dart';
import 'package:sultan_app/models/address_model.dart';
import 'package:sultan_app/models/delivery_zone_model.dart';
import 'package:sultan_app/models/requests/create_address_request.dart';
import 'package:sultan_app/models/requests/update_address_request.dart';

abstract interface class AddressRepository {
  Future<List<AddressModel>> getAddresses();
  Future<List<DeliveryZoneModel>> getDeliveryZones();
  Future<AddressModel> createAddress(CreateAddressRequest request);
  Future<AddressModel> updateAddress(
    int addressId,
    UpdateAddressRequest request,
  );
  Future<void> deleteAddress(int addressId);
}

class DummyAddressRepository implements AddressRepository {
  DummyAddressRepository({List<AddressModel>? initialAddresses})
    : _addresses = [...initialAddresses ?? DummyData.addresses];

  final List<AddressModel> _addresses;

  @override
  Future<List<DeliveryZoneModel>> getDeliveryZones() async =>
      DummyData.deliveryZones;

  @override
  Future<List<AddressModel>> getAddresses() async =>
      List.unmodifiable(_addresses);

  @override
  Future<AddressModel> createAddress(CreateAddressRequest request) async {
    _validate(request);
    final zone = _zone(request.deliveryZoneId);
    final address = AddressModel(
      id: _nextId,
      title: request.title,
      phone: request.phone,
      addressLine: request.addressLine,
      landmark: request.landmark,
      deliveryNotes: request.deliveryNotes,
      deliveryZoneId: zone.id,
      deliveryZoneName: zone.name,
    );
    _addresses.add(address);
    return address;
  }

  @override
  Future<AddressModel> updateAddress(
    int addressId,
    UpdateAddressRequest request,
  ) async {
    _validate(request);
    final index = _addresses.indexWhere((item) => item.id == addressId);
    if (index == -1) throw StateError('Address not found');
    final current = _addresses[index];
    final zone = _zone(request.deliveryZoneId);
    final updated = AddressModel(
      id: current.id,
      title: request.title,
      phone: request.phone,
      addressLine: request.addressLine,
      landmark: request.landmark,
      deliveryNotes: request.deliveryNotes,
      isDefault: current.isDefault,
      deliveryZoneId: zone.id,
      deliveryZoneName: zone.name,
    );
    _addresses[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteAddress(int addressId) async {
    final index = _addresses.indexWhere((item) => item.id == addressId);
    if (index == -1) throw StateError('Address not found');
    _addresses.removeAt(index);
  }

  void _validate(Object request) {
    final (title, phone, addressLine) = switch (request) {
      CreateAddressRequest value => (
        value.title,
        value.phone,
        value.addressLine,
      ),
      UpdateAddressRequest value => (
        value.title,
        value.phone,
        value.addressLine,
      ),
      _ => throw ArgumentError.value(request),
    };
    if (title.trim().isEmpty ||
        phone.trim().isEmpty ||
        addressLine.trim().isEmpty) {
      throw StateError('Incomplete address');
    }
  }

  int get _nextId =>
      _addresses.fold<int>(0, (max, item) => item.id > max ? item.id : max) + 1;

  DeliveryZoneModel _zone(int id) =>
      DummyData.deliveryZones.firstWhere((zone) => zone.id == id);
}
