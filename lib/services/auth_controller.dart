import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/network/api_failure.dart';
import 'backend_repositories.dart';

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
    this.phoneNumber = '',
    this.farm = const FarmProfile.empty(),
  });

  final String name;
  final String email;
  final String city;
  final String state;
  final String phoneNumber;
  final FarmProfile farm;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'city': city,
      'state': state,
      'phoneNumber': phoneNumber,
      'farm': farm.toJson(),
    };
  }

  factory AppUser.fromJson(Map<dynamic, dynamic> json) {
    return AppUser(
      name: json['name'] as String? ?? 'FasalX Farmer',
      email: json['email'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      phoneNumber:
          json['phoneNumber'] as String? ?? json['phone'] as String? ?? '',
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
    String? phoneNumber,
    FarmProfile? farm,
  }) {
    return AppUser(
      name: name ?? this.name,
      email: email ?? this.email,
      city: city ?? this.city,
      state: state ?? this.state,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      farm: farm ?? this.farm,
    );
  }
}

enum PasswordOtpPurpose { forgotPassword, changePassword }

class PasswordOtpResult {
  const PasswordOtpResult.success({
    required this.maskedTarget,
    required this.expiresAt,
  }) : message = null;

  const PasswordOtpResult.failure(this.message)
    : maskedTarget = '',
      expiresAt = null;

  final String? message;
  final String maskedTarget;
  final DateTime? expiresAt;
  bool get isSuccess => message == null;
}

class OtpVerifyResult {
  const OtpVerifyResult.success() : message = null;
  const OtpVerifyResult.failure(this.message);

  final String? message;
  bool get isSuccess => message == null;
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
  static const _authRepository = AuthRepository();

  Box<dynamic>? _box;
  AppUser? _currentUser;
  String? _selectedLanguage;
  _PasswordOtpSession? _passwordOtpSession;

  AppUser? get currentUser => _currentUser;
  String? get selectedLanguage => _selectedLanguage;
  bool get isAuthenticated => _currentUser != null;
  bool get hasSelectedLanguage => _selectedLanguage != null;
  bool get hasCompletedFarmSetup => _currentUser?.farm.isSetupComplete ?? false;

  String get _preferredLanguageCode =>
      _selectedLanguage == 'Hindi' ? 'hi' : 'en';

  Future<void> load() async {
    _box = await Hive.openBox<dynamic>(_authBoxName);
    _selectedLanguage = _box?.get(_languageKey) as String?;
    final firebaseUser = firebase.FirebaseAuth.instance.currentUser;
    final email = firebaseUser?.email ?? _box?.get(_sessionEmailKey) as String?;
    if (email != null) {
      final saved = _savedUsers[email.toLowerCase()];
      if (firebaseUser != null) {
        _currentUser = await _profileFromBackend(
          email,
          fallback: _savedProfileFromEntry(saved),
        );
        await _saveCurrentUser();
      } else if (saved != null) {
        _currentUser = _savedProfileFromEntry(saved);
      }
    }
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    await _box?.put(_languageKey, language);
    notifyListeners();
    if (_currentUser != null) {
      await _syncPreferredLanguage();
    }
  }

  Future<void> refreshProfile() async {
    final email =
        firebase.FirebaseAuth.instance.currentUser?.email ?? _currentUser?.email;
    if (email == null || email.trim().isEmpty) return;
    _currentUser = await _profileFromBackend(
      email.trim().toLowerCase(),
      fallback: _currentUser ?? _savedProfileForEmail(email),
    );
    await _saveCurrentUser();
    notifyListeners();
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final identifier = email.trim();
    final normalizedEmail = _emailForIdentifier(identifier);
    if (!_isValidEmail(normalizedEmail)) {
      return const AuthResult.failure(
        'Enter a valid registered email or mobile number.',
      );
    }

    try {
      await firebase.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      await _refreshFirebaseToken();
      await _syncUserWithBackend();
      _currentUser = await _profileFromBackend(
        normalizedEmail,
        fallback: _savedProfileForEmail(normalizedEmail),
      );
      await _box?.put(_sessionEmailKey, normalizedEmail);
      await _saveCurrentUser();
      await _syncPreferredLanguage();
      notifyListeners();
      return const AuthResult.success();
    } on firebase.FirebaseAuthException catch (error) {
      return AuthResult.failure(_firebaseMessage(error));
    } on ApiFailure catch (error) {
      return AuthResult.failure(_backendAuthMessage(error));
    } catch (_) {
      return const AuthResult.failure(
        'Could not connect to FasalX services. Please try again.',
      );
    }
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    String phoneNumber = '',
    required String city,
    required String state,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!_isValidEmail(normalizedEmail)) {
      return const AuthResult.failure('Enter a valid email address.');
    }
    try {
      final credential = await firebase.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: normalizedEmail,
            password: password,
          );
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      await _refreshFirebaseToken();
      final backendSynced = await _syncUserWithBackend();

      final user = AppUser(
        name: name.trim(),
        email: normalizedEmail,
        city: city.trim(),
        state: state.trim(),
        phoneNumber: phoneNumber.trim(),
      );
      _currentUser = user;
      if (backendSynced) {
        await _authRepository.updateProfile(_backendProfilePayload(user));
      }
      await _box?.put(_sessionEmailKey, normalizedEmail);
      await _saveCurrentUser();
      notifyListeners();
      return const AuthResult.success();
    } on firebase.FirebaseAuthException catch (error) {
      return AuthResult.failure(_firebaseMessage(error));
    } on ApiFailure catch (error) {
      return AuthResult.failure(_backendAuthMessage(error));
    } catch (_) {
      return const AuthResult.failure(
        'Could not create your account. Please try again.',
      );
    }
  }

  Future<AuthResult> sendPasswordReset(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!_isValidEmail(normalizedEmail)) {
      return const AuthResult.failure('Enter your registered email address.');
    }

    try {
      await firebase.FirebaseAuth.instance.sendPasswordResetEmail(
        email: normalizedEmail,
      );
      return const AuthResult.success();
    } on firebase.FirebaseAuthException catch (error) {
      return AuthResult.failure(_firebaseMessage(error));
    } catch (_) {
      return const AuthResult.failure(
        'Could not send reset email. Please try again.',
      );
    }
  }

  Future<void> updateProfile(AppUser user) async {
    _currentUser = user;
    await _saveCurrentUser();
    try {
      await _authRepository.updateProfile(_backendProfilePayload(user));
    } catch (_) {
      // Local profile state should remain usable if the backend is offline.
    }
    notifyListeners();
  }

  Future<void> updateFarmProfile(FarmProfile farm) async {
    final user = _currentUser;
    if (user == null) return;
    await updateProfile(user.copyWith(farm: farm));
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (_) {
      // Firebase sign-out below is the important client-side action.
    }
    await firebase.FirebaseAuth.instance.signOut();
    _currentUser = null;
    await _box?.delete(_sessionEmailKey);
    notifyListeners();
  }

  Future<AuthResult> deactivateAccount() async {
    if (_currentUser == null) {
      return const AuthResult.failure('Login again to deactivate your account.');
    }
    try {
      await _authRepository.deactivate();
      await firebase.FirebaseAuth.instance.signOut();
      _currentUser = null;
      await _box?.delete(_sessionEmailKey);
      notifyListeners();
      return const AuthResult.success();
    } on ApiFailure catch (error) {
      return AuthResult.failure(_backendAuthMessage(error));
    } catch (_) {
      return const AuthResult.failure(
        'Could not deactivate your account. Please try again.',
      );
    }
  }

  Future<AuthResult> deleteAccount() async {
    if (_currentUser == null) {
      return const AuthResult.failure('Login again to delete your account.');
    }
    try {
      await _authRepository.deleteAccount();
      final firebaseUser = firebase.FirebaseAuth.instance.currentUser;
      try {
        await firebaseUser?.delete();
      } on firebase.FirebaseAuthException catch (error) {
        if (error.code == 'requires-recent-login') {
          await firebase.FirebaseAuth.instance.signOut();
          _currentUser = null;
          await _box?.delete(_sessionEmailKey);
          notifyListeners();
          return const AuthResult.failure(
            'MongoDB account data was deleted. Firebase requires a fresh login to remove the auth user.',
          );
        }
        rethrow;
      }
      _currentUser = null;
      await _box?.delete(_sessionEmailKey);
      notifyListeners();
      return const AuthResult.success();
    } on ApiFailure catch (error) {
      return AuthResult.failure(_backendAuthMessage(error));
    } on firebase.FirebaseAuthException catch (error) {
      return AuthResult.failure(_firebaseMessage(error));
    } catch (_) {
      return const AuthResult.failure(
        'Could not delete your account. Please try again.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> activities({
    int limit = 20,
    int offset = 0,
  }) async {
    return _authRepository.activities(limit: limit, offset: offset);
  }

  Map<dynamic, dynamic> get _savedUsers {
    final saved = _box?.get(_usersKey);
    if (saved is Map) return Map<dynamic, dynamic>.from(saved);
    return {};
  }

  AppUser? _savedProfileForEmail(String email) {
    return _savedProfileFromEntry(_savedUsers[email.toLowerCase()]);
  }

  String _emailForIdentifier(String identifier) {
    final normalized = identifier.trim().toLowerCase();
    if (_isValidEmail(normalized)) return normalized;

    final normalizedPhone = _normalizePhone(identifier);
    if (normalizedPhone.isEmpty) return normalized;

    for (final entry in _savedUsers.entries) {
      final profile = _savedProfileFromEntry(entry.value);
      if (profile == null) continue;
      if (_normalizePhone(profile.phoneNumber) == normalizedPhone) {
        return profile.email.toLowerCase();
      }
    }
    return normalized;
  }

  AppUser? _savedProfileFromEntry(Object? saved) {
    if (saved is! Map || saved['profile'] is! Map) return null;
    return AppUser.fromJson(Map<dynamic, dynamic>.from(saved['profile'] as Map));
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _saveCurrentUser() async {
    final user = _currentUser;
    if (user == null) return;
    final users = _savedUsers;
    users[user.email.toLowerCase()] = {
      'profile': user.toJson(),
    };
    await _box?.put(_usersKey, users);
  }

  Future<void> _refreshFirebaseToken() async {
    await firebase.FirebaseAuth.instance.currentUser?.getIdToken(true);
  }

  Future<bool> _syncUserWithBackend() async {
    try {
      await _authRepository.syncUser();
      return true;
    } catch (error) {
      debugPrint('Backend auth sync skipped: $error');
      return false;
    }
  }

  Future<void> _syncPreferredLanguage() async {
    try {
      await _authRepository.updateProfile({
        'preferred_language': _preferredLanguageCode,
      });
    } catch (_) {
      // The local language choice is already saved; backend sync can retry later.
    }
  }

  Map<String, dynamic> _backendProfilePayload(AppUser user) {
    final payload = <String, dynamic>{
      'display_name': user.name,
      'preferred_language': _preferredLanguageCode,
      'farm_size_acres': _farmSizeAcres(user.farm),
      'phone_number': user.phoneNumber.trim().isEmpty
          ? null
          : user.phoneNumber.trim(),
      'avatar_url': null,
    };

    final location = _locationFromFarm(user.farm.location);
    if (location != null) {
      payload['location'] = location;
    }
    return payload;
  }

  double? _farmSizeAcres(FarmProfile farm) {
    final size = double.tryParse(farm.size.trim());
    if (size == null) return null;
    switch (farm.unit.trim().toLowerCase()) {
      case 'hectare':
      case 'hectares':
        return size * 2.47105;
      case 'bigha':
        return size * 0.619834;
      default:
        return size;
    }
  }

  Map<String, double>? _locationFromFarm(String location) {
    final match = RegExp(
      r'Lat\s+(-?\d+(?:\.\d+)?),\s+Lng\s+(-?\d+(?:\.\d+)?)',
      caseSensitive: false,
    ).firstMatch(location);
    if (match == null) return null;
    final lat = double.tryParse(match.group(1) ?? '');
    final lon = double.tryParse(match.group(2) ?? '');
    if (lat == null || lon == null) return null;
    return {'latitude': lat, 'longitude': lon};
  }

  Future<AppUser> _profileFromBackend(String email, {AppUser? fallback}) async {
    try {
      final profile = await _authRepository.getProfile();
      final preferredLanguage = profile['preferred_language']?.toString();
      if (preferredLanguage == 'hi') {
        _selectedLanguage = 'Hindi';
        await _box?.put(_languageKey, _selectedLanguage);
      } else if (preferredLanguage == 'en') {
        _selectedLanguage = 'English';
        await _box?.put(_languageKey, _selectedLanguage);
      }

      final farmSize = profile['farm_size_acres'];
      final backendFarmSize = farmSize == null ? null : farmSize.toString();
      final backendLocation = _formatBackendLocation(profile['location']);
      final fallbackFarm = fallback?.farm ?? const FarmProfile.empty();
      return AppUser(
        name:
            profile['display_name']?.toString() ??
            fallback?.name ??
            firebase.FirebaseAuth.instance.currentUser?.displayName ??
            'FasalX Farmer',
        email: email,
        city: fallback?.city ?? '',
        state: fallback?.state ?? '',
        phoneNumber:
            profile['phone_number']?.toString() ?? fallback?.phoneNumber ?? '',
        farm: fallbackFarm.copyWith(
          size: backendFarmSize ?? fallbackFarm.size,
          unit: backendFarmSize == null ? fallbackFarm.unit : 'Acre',
          location: backendLocation ?? fallbackFarm.location,
        ),
      );
    } catch (_) {
      return AppUser(
        name:
            fallback?.name ??
            firebase.FirebaseAuth.instance.currentUser?.displayName ??
            'FasalX Farmer',
        email: email,
        city: fallback?.city ?? '',
        state: fallback?.state ?? '',
        phoneNumber: fallback?.phoneNumber ?? '',
        farm: fallback?.farm ?? const FarmProfile.empty(),
      );
    }
  }

  String? _formatBackendLocation(Object? value) {
    if (value is! Map) return null;
    final lat = value['latitude'];
    final lon = value['longitude'];
    if (lat == null || lon == null) return null;
    final latValue = double.tryParse(lat.toString());
    final lonValue = double.tryParse(lon.toString());
    if (latValue == null || lonValue == null) return null;
    return 'Lat ${latValue.toStringAsFixed(5)}, Lng ${lonValue.toStringAsFixed(5)}';
  }

  Future<PasswordOtpResult> startPasswordOtp({
    required String identifier,
    required PasswordOtpPurpose purpose,
  }) async {
    final user = purpose == PasswordOtpPurpose.changePassword
        ? _currentUser
        : _savedProfileForEmail(_emailForIdentifier(identifier));
    final fallbackEmail = _emailForIdentifier(identifier);
    final email = user?.email ?? fallbackEmail;
    if (!_isValidEmail(email)) {
      return const PasswordOtpResult.failure(
        'Enter your registered email or mobile number.',
      );
    }

    final code = (100000 + Random.secure().nextInt(900000)).toString();
    final expiresAt = DateTime.now().add(const Duration(minutes: 2));
    final target = _preferredOtpTarget(user, email);
    _passwordOtpSession = _PasswordOtpSession(
      email: email,
      code: code,
      expiresAt: expiresAt,
      purpose: purpose,
    );

    debugPrint('FasalX password OTP for $target: $code');
    return PasswordOtpResult.success(
      maskedTarget: _maskContact(target),
      expiresAt: expiresAt,
    );
  }

  OtpVerifyResult verifyPasswordOtp(String code) {
    final session = _passwordOtpSession;
    if (session == null) {
      return const OtpVerifyResult.failure('Request a new OTP first.');
    }
    if (DateTime.now().isAfter(session.expiresAt)) {
      return const OtpVerifyResult.failure('OTP expired. Please resend OTP.');
    }
    if (code.trim() != session.code) {
      return const OtpVerifyResult.failure('Invalid OTP. Please try again.');
    }
    session.verified = true;
    return const OtpVerifyResult.success();
  }

  Future<AuthResult> updatePasswordAfterOtp(String password) async {
    final session = _passwordOtpSession;
    if (session == null || !session.verified) {
      return const AuthResult.failure('Please verify OTP first.');
    }
    if (!_isStrongPassword(password)) {
      return const AuthResult.failure(
        'Use 8+ characters with uppercase, lowercase, number, and special character.',
      );
    }
    if (DateTime.now().isAfter(session.expiresAt)) {
      return const AuthResult.failure('OTP expired. Please resend OTP.');
    }

    try {
      final current = firebase.FirebaseAuth.instance.currentUser;
      if (current != null &&
          current.email?.toLowerCase() == session.email.toLowerCase()) {
        await current.updatePassword(password);
        _passwordOtpSession = null;
        return const AuthResult.success();
      }

      await firebase.FirebaseAuth.instance.sendPasswordResetEmail(
        email: session.email,
      );
      return const AuthResult.failure(
        'Firebase requires the secure reset link sent to your registered email before changing this password.',
      );
    } on firebase.FirebaseAuthException catch (error) {
      return AuthResult.failure(_firebaseMessage(error));
    } catch (_) {
      return const AuthResult.failure(
        'Network error. Please check your connection and try again.',
      );
    }
  }

  bool _isStrongPassword(String value) {
    return value.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(value) &&
        RegExp(r'[a-z]').hasMatch(value) &&
        RegExp(r'[0-9]').hasMatch(value) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
  }

  String _preferredOtpTarget(AppUser? user, String email) {
    final phone = user?.phoneNumber.trim() ?? '';
    return phone.isNotEmpty ? phone : email;
  }

  String _maskContact(String value) {
    final normalizedPhone = _normalizePhone(value);
    if (normalizedPhone.length >= 10 && !value.contains('@')) {
      final last = normalizedPhone.substring(normalizedPhone.length - 4);
      return '******$last';
    }
    final parts = value.split('@');
    if (parts.length != 2 || parts.first.length < 2) return value;
    return '${parts.first.substring(0, 2)}******@${parts.last}';
  }

  String _firebaseMessage(firebase.FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
      case 'invalid-credential':
        return 'User not found or password is incorrect.';
      case 'wrong-password':
        return 'Wrong password. Please try again.';
      case 'email-already-in-use':
        return 'Email already registered. Please login.';
      case 'weak-password':
        return 'Use a stronger password.';
      case 'network-request-failed':
        return 'Network error. Check your connection and backend services.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _backendAuthMessage(ApiFailure error) {
    final code = error.code?.toUpperCase();
    if (error.statusCode == 401 ||
        error.statusCode == 403 ||
        code == 'INVALID_TOKEN' ||
        code == 'TOKEN_EXPIRED' ||
        code == 'TOKEN_REVOKED') {
      return 'Firebase signup worked, but the backend rejected the login token. Check that the backend Firebase Admin credentials use the same Firebase project as this app.';
    }
    return error.message;
  }
}

class _PasswordOtpSession {
  _PasswordOtpSession({
    required this.email,
    required this.code,
    required this.expiresAt,
    required this.purpose,
  });

  final String email;
  final String code;
  final DateTime expiresAt;
  final PasswordOtpPurpose purpose;
  bool verified = false;
}
