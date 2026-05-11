import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/delivery_address.dart';

const _addressBoxName = 'fasalx_addresses';
const _addressListKey = 'addresses';
const _activeAddressKey = 'active_address_id';
const _googleApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

class AddressRepository {
  Box<dynamic>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_addressBoxName);
  }

  List<DeliveryAddress> loadAddresses() {
    final saved = _box?.get(_addressListKey);
    if (saved is! List) return _seedAddresses;
    return saved
        .map((item) => DeliveryAddress.fromJson(Map<dynamic, dynamic>.from(item as Map)))
        .toList();
  }

  String? loadActiveAddressId() => _box?.get(_activeAddressKey) as String?;

  Future<void> saveAddresses(List<DeliveryAddress> addresses, String? activeId) async {
    await _box?.put(_addressListKey, addresses.map((address) => address.toJson()).toList());
    if (activeId == null) {
      await _box?.delete(_activeAddressKey);
    } else {
      await _box?.put(_activeAddressKey, activeId);
    }
  }

  Future<AddressDraft> getCurrentLocationAddress() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationException('Please turn on location services.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw const LocationException('Location permission is needed to detect your address.');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return reverseGeocode(position.latitude, position.longitude);
  }

  Future<AddressDraft> reverseGeocode(double latitude, double longitude) async {
    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) {
      return AddressDraft(latitude: latitude, longitude: longitude);
    }
    final place = placemarks.first;
    return AddressDraft(
      house: [place.name, place.street].where((part) => (part ?? '').trim().isNotEmpty).join(', '),
      area: [
        place.subLocality,
        place.locality == place.subLocality ? null : place.locality,
      ].where((part) => (part ?? '').trim().isNotEmpty).join(', '),
      landmark: place.subAdministrativeArea ?? '',
      city: place.locality?.isNotEmpty == true ? place.locality! : (place.subAdministrativeArea ?? ''),
      state: place.administrativeArea ?? '',
      pincode: place.postalCode ?? '',
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    if (_googleApiKey.isEmpty || query.trim().length < 3) return const [];
    final uri = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
      'input': query.trim(),
      'components': 'country:in',
      'types': 'geocode',
      'key': _googleApiKey,
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) return const [];
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final predictions = data['predictions'] as List<dynamic>? ?? const [];
    return predictions.map((item) {
      final map = item as Map<String, dynamic>;
      final formatting = map['structured_formatting'] as Map<String, dynamic>? ?? const {};
      return PlaceSuggestion(
        placeId: map['place_id'] as String? ?? '',
        title: formatting['main_text'] as String? ?? map['description'] as String? ?? '',
        subtitle: formatting['secondary_text'] as String? ?? '',
      );
    }).where((item) => item.placeId.isNotEmpty).toList();
  }

  Future<AddressDraft?> getPlaceAddress(String placeId) async {
    if (_googleApiKey.isEmpty || placeId.isEmpty) return null;
    final uri = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
      'place_id': placeId,
      'fields': 'geometry,address_components,formatted_address',
      'key': _googleApiKey,
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final result = data['result'] as Map<String, dynamic>?;
    if (result == null) return null;

    final location =
        ((result['geometry'] as Map<String, dynamic>?)?['location'] as Map<String, dynamic>?) ??
            <String, dynamic>{};
    final components = (result['address_components'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    String component(List<String> types) {
      for (final item in components) {
        final itemTypes = (item['types'] as List<dynamic>? ?? const []).cast<String>();
        if (types.any(itemTypes.contains)) return item['long_name'] as String? ?? '';
      }
      return '';
    }

    final area = [
      component(['sublocality_level_1', 'sublocality']),
      component(['route']),
    ].where((part) => part.trim().isNotEmpty).join(', ');

    return AddressDraft(
      house: result['formatted_address'] as String? ?? '',
      area: area,
      city: component(['locality', 'administrative_area_level_3']),
      state: component(['administrative_area_level_1']),
      pincode: component(['postal_code']),
      latitude: (location['lat'] as num?)?.toDouble(),
      longitude: (location['lng'] as num?)?.toDouble(),
    );
  }
}

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;

  @override
  String toString() => message;
}

final _seedAddresses = [
  const DeliveryAddress(
    id: 'seed-home',
    fullName: 'Ramesh Patel',
    mobileNumber: '+91 98765 43210',
    house: 'House 24, Near mandi road',
    area: 'Bhopal',
    landmark: 'Krishi Bazaar',
    city: 'Bhopal',
    state: 'Madhya Pradesh',
    pincode: '462042',
    type: AddressType.home,
    isDefault: true,
    latitude: 23.2599,
    longitude: 77.4126,
  ),
  const DeliveryAddress(
    id: 'seed-farm',
    fullName: 'Ramesh Patel',
    mobileNumber: '+91 98765 43210',
    house: 'Patel Farm',
    area: 'Sehore Road',
    landmark: 'Near tubewell',
    city: 'Sehore',
    state: 'Madhya Pradesh',
    pincode: '466001',
    type: AddressType.farm,
    isDefault: false,
    latitude: 23.2032,
    longitude: 77.0844,
  ),
];
