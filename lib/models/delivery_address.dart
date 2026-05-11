enum AddressType { home, farm, office }

class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.house,
    required this.area,
    required this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.type,
    required this.isDefault,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String fullName;
  final String mobileNumber;
  final String house;
  final String area;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
  final AddressType type;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  String get typeLabel {
    switch (type) {
      case AddressType.home:
        return 'Home';
      case AddressType.farm:
        return 'Farm';
      case AddressType.office:
        return 'Office';
    }
  }

  String get shortLine => [city, state, pincode].where((part) => part.trim().isNotEmpty).join(', ');

  String get fullAddress {
    return [
      house,
      area,
      if (landmark.trim().isNotEmpty) landmark,
      city,
      state,
      pincode,
    ].where((part) => part.trim().isNotEmpty).join(', ');
  }

  DeliveryAddress copyWith({
    String? id,
    String? fullName,
    String? mobileNumber,
    String? house,
    String? area,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    AddressType? type,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      house: house ?? this.house,
      area: area ?? this.area,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'house': house,
      'area': area,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'type': type.name,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory DeliveryAddress.fromJson(Map<dynamic, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      house: json['house'] as String? ?? '',
      area: json['area'] as String? ?? '',
      landmark: json['landmark'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      type: AddressType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => AddressType.home,
      ),
      isDefault: json['isDefault'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class AddressDraft {
  const AddressDraft({
    this.house = '',
    this.area = '',
    this.landmark = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.latitude,
    this.longitude,
  });

  final String house;
  final String area;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
  final double? latitude;
  final double? longitude;

  AddressDraft copyWith({
    String? house,
    String? area,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
  }) {
    return AddressDraft(
      house: house ?? this.house,
      area: area ?? this.area,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.title,
    required this.subtitle,
  });

  final String placeId;
  final String title;
  final String subtitle;
}
