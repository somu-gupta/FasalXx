import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _authBoxName = 'fasalx_auth';
const _usersKey = 'users';
const _sessionEmailKey = 'session_email';
const _languageKey = 'language';

class FarmProfile {
  const FarmProfile({
    required this.name,
    required this.size,
    required this.unit,
    required this.location,
    required this.crops,
    required this.isSetupComplete,
  });

  const FarmProfile.empty()
    : name = '',
      size = '',
      unit = 'Acre',
      location = '',
      crops = const [],
      isSetupComplete = false;

  final String name;
  final String size;
  final String unit;
  final String location;
  final List<String> crops;
  final bool isSetupComplete;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'size': size,
      'unit': unit,
      'location': location,
      'crops': crops,
      'isSetupComplete': isSetupComplete,
    };
  }

  factory FarmProfile.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return const FarmProfile.empty();
    final rawCrops = json['crops'];
    return FarmProfile(
      name: json['name'] as String? ?? '',
      size: json['size'] as String? ?? '',
      unit: json['unit'] as String? ?? 'Acre',
      location: json['location'] as String? ?? '',
      crops: rawCrops is List ? rawCrops.cast<String>() : const [],
      isSetupComplete: json['isSetupComplete'] as bool? ?? false,
    );
  }

  FarmProfile copyWith({
    String? name,
    String? size,
    String? unit,
    String? location,
    List<String>? crops,
    bool? isSetupComplete,
  }) {
    return FarmProfile(
      name: name ?? this.name,
      size: size ?? this.size,
      unit: unit ?? this.unit,
      location: location ?? this.location,
      crops: crops ?? this.crops,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
    );
  }
}

class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    required this.city,
    required this.state,
    this.farm = const FarmProfile.empty(),
  });

  final String name;
  final String email;
  final String city;
  final String state;
  final FarmProfile farm;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'city': city,
      'state': state,
      'farm': farm.toJson(),
    };
  }

  factory AppUser.fromJson(Map<dynamic, dynamic> json) {
    return AppUser(
      name: json['name'] as String? ?? 'FasalX Farmer',
      email: json['email'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      farm: FarmProfile.fromJson(
        json['farm'] is Map ? json['farm'] as Map : null,
      ),
    );
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? city,
    String? state,
    FarmProfile? farm,
  }) {
    return AppUser(
      name: name ?? this.name,
      email: email ?? this.email,
      city: city ?? this.city,
      state: state ?? this.state,
      farm: farm ?? this.farm,
    );
  }
}

class AuthResult {
  const AuthResult.success() : message = null;
  const AuthResult.failure(this.message);

  final String? message;
  bool get isSuccess => message == null;
}

class AuthController extends ChangeNotifier {
  AuthController._();

  static final AuthController instance = AuthController._();

  Box<dynamic>? _box;
  AppUser? _currentUser;
  String? _selectedLanguage;

  AppUser? get currentUser => _currentUser;
  String? get selectedLanguage => _selectedLanguage;
  bool get isAuthenticated => _currentUser != null;
  bool get hasSelectedLanguage => _selectedLanguage != null;
  bool get hasCompletedFarmSetup => _currentUser?.farm.isSetupComplete ?? false;

  Future<void> load() async {
    _box = await Hive.openBox<dynamic>(_authBoxName);
    _selectedLanguage = _box?.get(_languageKey) as String?;
    final email = _box?.get(_sessionEmailKey) as String?;
    if (email != null) {
      final saved = _savedUsers[email.toLowerCase()];
      if (saved != null) {
        _currentUser = AppUser.fromJson(
          Map<dynamic, dynamic>.from(saved['profile'] as Map),
        );
      }
    }
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    await _box?.put(_languageKey, language);
    notifyListeners();
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    final normalizedEmail = email.trim().toLowerCase();
    if (!_isValidEmail(normalizedEmail)) {
      return const AuthResult.failure('Enter a valid email address.');
    }

    final saved = _savedUsers[normalizedEmail];
    if (saved == null) {
      return const AuthResult.failure('User not found. Please sign up first.');
    }
    if (saved['password'] != password) {
      return const AuthResult.failure('Wrong password. Please try again.');
    }

    _currentUser = AppUser.fromJson(
      Map<dynamic, dynamic>.from(saved['profile'] as Map),
    );
    await _box?.put(_sessionEmailKey, normalizedEmail);
    notifyListeners();
    return const AuthResult.success();
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String city,
    required String state,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 950));
    final normalizedEmail = email.trim().toLowerCase();
    if (!_isValidEmail(normalizedEmail)) {
      return const AuthResult.failure('Enter a valid email address.');
    }
    if (_savedUsers.containsKey(normalizedEmail)) {
      return const AuthResult.failure(
        'Email already registered. Please login.',
      );
    }

    final user = AppUser(
      name: name.trim(),
      email: normalizedEmail,
      city: city.trim(),
      state: state.trim(),
    );
    final users = _savedUsers;
    users[normalizedEmail] = {'password': password, 'profile': user.toJson()};
    await _box?.put(_usersKey, users);
    await _box?.put(_sessionEmailKey, normalizedEmail);
    _currentUser = user;
    notifyListeners();
    return const AuthResult.success();
  }

  Future<void> updateProfile(AppUser user) async {
    _currentUser = user;
    final users = _savedUsers;
    final saved = users[user.email.toLowerCase()];
    if (saved != null) {
      saved['profile'] = user.toJson();
      await _box?.put(_usersKey, users);
    }
    notifyListeners();
  }

  Future<void> updateFarmProfile(FarmProfile farm) async {
    final user = _currentUser;
    if (user == null) return;
    await updateProfile(user.copyWith(farm: farm));
  }

  Future<void> logout() async {
    _currentUser = null;
    await _box?.delete(_sessionEmailKey);
    notifyListeners();
  }

  Map<dynamic, dynamic> get _savedUsers {
    final saved = _box?.get(_usersKey);
    if (saved is Map) return Map<dynamic, dynamic>.from(saved);
    return {};
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}
