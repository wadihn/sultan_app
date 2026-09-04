import 'package:dio/dio.dart';
import 'package:sultan_app/core/network/api_endpoints.dart';
import 'package:sultan_app/models/address_model.dart';
import 'package:sultan_app/models/requests/create_address_request.dart';
import 'package:sultan_app/models/requests/update_address_request.dart';

class AddressService {
  const AddressService(this.client);

  final Dio client;

  Future<List<AddressModel>> getAddresses() => throw UnsupportedError(
    'Laravel is not connected yet. Future endpoint: GET ${ApiEndpoints.addresses}',
  );

  Future<AddressModel> createAddress(
    CreateAddressRequest request,
  ) => throw UnsupportedError(
    'Laravel is not connected yet. Future endpoint: POST ${ApiEndpoints.addresses}',
  );

  Future<AddressModel> updateAddress(
    int addressId,
    UpdateAddressRequest request,
  ) => throw UnsupportedError(
    'Laravel is not connected yet. Future endpoint: PUT ${ApiEndpoints.address(addressId)}',
  );

  Future<void> deleteAddress(int addressId) => throw UnsupportedError(
    'Laravel is not connected yet. Future endpoint: DELETE ${ApiEndpoints.address(addressId)}',
  );
}
