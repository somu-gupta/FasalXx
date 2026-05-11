import 'package:flutter/foundation.dart';

import '../models/delivery_address.dart';
import 'address_repository.dart';

class AddressController extends ChangeNotifier {
  AddressController(this._repository);

  final AddressRepository _repository;
  final List<DeliveryAddress> _addresses = [];
  String? _activeAddressId;
  bool _loadingLocation = false;
  List<PlaceSuggestion> _suggestions = const [];

  List<DeliveryAddress> get addresses => List.unmodifiable(_addresses);
  bool get loadingLocation => _loadingLocation;
  List<PlaceSuggestion> get suggestions => _suggestions;

  DeliveryAddress? get activeAddress {
    if (_addresses.isEmpty) return null;
    return _firstWhereOrNull((address) => address.id == _activeAddressId) ??
        _firstWhereOrNull((address) => address.isDefault) ??
        _addresses.first;
  }

  Future<void> load() async {
    await _repository.init();
    _addresses
      ..clear()
      ..addAll(_repository.loadAddresses());
    _activeAddressId = _repository.loadActiveAddressId() ?? activeAddress?.id;
    await _persist();
    notifyListeners();
  }

  Future<AddressDraft> detectCurrentLocation() async {
    _loadingLocation = true;
    notifyListeners();
    try {
      return await _repository.getCurrentLocationAddress();
    } finally {
      _loadingLocation = false;
      notifyListeners();
    }
  }

  Future<AddressDraft> reverseGeocode(double latitude, double longitude) {
    return _repository.reverseGeocode(latitude, longitude);
  }

  Future<void> searchPlaces(String query) async {
    _suggestions = await _repository.searchPlaces(query);
    notifyListeners();
  }

  void clearSuggestions() {
    _suggestions = const [];
    notifyListeners();
  }

  Future<AddressDraft?> selectSuggestion(PlaceSuggestion suggestion) async {
    final draft = await _repository.getPlaceAddress(suggestion.placeId);
    clearSuggestions();
    return draft;
  }

  Future<void> upsertAddress(DeliveryAddress address) async {
    final existingIndex = _addresses.indexWhere((item) => item.id == address.id);
    var nextAddress = address;
    if (_addresses.isEmpty) nextAddress = nextAddress.copyWith(isDefault: true);
    if (nextAddress.isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    if (existingIndex == -1) {
      _addresses.add(nextAddress);
    } else {
      _addresses[existingIndex] = nextAddress;
    }
    _activeAddressId ??= nextAddress.id;
    await _persist();
    notifyListeners();
  }

  Future<void> deleteAddress(String id) async {
    _addresses.removeWhere((address) => address.id == id);
    if (_activeAddressId == id) _activeAddressId = activeAddress?.id;
    if (_addresses.isNotEmpty && !_addresses.any((address) => address.isDefault)) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> selectDeliveryAddress(String id) async {
    _activeAddressId = id;
    await _persist();
    notifyListeners();
  }

  Future<void> makeDefault(String id) async {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == id);
    }
    _activeAddressId = id;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() {
    return _repository.saveAddresses(_addresses, _activeAddressId);
  }

  DeliveryAddress? _firstWhereOrNull(bool Function(DeliveryAddress address) test) {
    for (final address in _addresses) {
      if (test(address)) return address;
    }
    return null;
  }
}
