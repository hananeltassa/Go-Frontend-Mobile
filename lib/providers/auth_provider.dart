import 'package:flutter/material.dart';
import 'package:go_frontend_mobile/providers/activity_provider.dart';
import 'package:go_frontend_mobile/providers/booking_provider.dart';
import 'package:go_frontend_mobile/providers/destination_provider.dart';
import 'package:go_frontend_mobile/providers/img_provider.dart';
import 'package:go_frontend_mobile/providers/profile_provider.dart';
import 'package:go_frontend_mobile/providers/saved_provider.dart';
import 'package:go_frontend_mobile/services/dio_client.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService(DioClient());

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int? _roleId;
  int? get roleId => _roleId;

  int? _userId;
  int? get userId => _userId;

  bool _isGuest = false;
  bool get isGuest => _isGuest;

  bool _isMan = false;
  bool get isMan => _isMan;

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    int? roleId,
    String? businessName,
    int? businessCategory,
    String? subscriptionType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.registerUser(
      name: name,
      email: email,
      password: password,
      roleId: roleId ?? 2,
      businessName: businessName,
      businessCategory: businessCategory,
      subscriptionType: subscriptionType,
    );

    _isLoading = false;

    if (response['error'] == true) {
      _errorMessage = response['message'];
      notifyListeners();
      return false;
    }

    final data = response['data']?['data'];
    final user = data['user'];
    final token = data['token'];

    if (data == null ||
        !data.containsKey('user') ||
        !data.containsKey('token')) {
      _errorMessage = "Invalid response format from server";
      notifyListeners();
      return false;
    }

    _roleId = user['role_id'];
    _userId = user['id'];
    _user = UserModel.fromJson(user);

    await _secureStorage.write(key: 'auth_token', value: token);
    await _secureStorage.write(key: 'role_id', value: _roleId.toString());
    await _secureStorage.write(key: 'user_id', value: _userId.toString());

    _isLoggedIn = true;
    _isGuest = false;

    notifyListeners();
    return true;
  }

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isMan = true;
    notifyListeners();

    final response = await _authService.loginUser(
      email: email,
      password: password,
    );

    _isLoading = false;
    log("🔵 Raw Response: $response");

    if (response.containsKey('error') && response['error'] == true) {
      _isLoading = false;
      _errorMessage = response['message'] ?? "Invalid response from server";
      notifyListeners();
      return false;
    }

    final data = response['data']?['data'];
    final user = data['user'];
    final token = data['token'];

    if (data == null ||
        !data.containsKey('user') ||
        !data.containsKey('token')) {
      _isLoading = false;
      _errorMessage = "Invalid response format from server";
      notifyListeners();
      return false;
    }

    _roleId = user['role_id'];
    _userId = user['id'];
    _user = UserModel.fromJson(user);
    log("User Role ID: $_roleId");
    log("Extracted User: $user");
    log("Extracted Token: $token");
    log("Extracted User: ${_user?.toJson()}");

    await _secureStorage.write(key: 'auth_token', value: token);
    await _secureStorage.write(key: 'role_id', value: _roleId.toString());
    await _secureStorage.write(key: 'user_id', value: _userId.toString());

    _isLoggedIn = true;
    _isGuest = false;
    _isLoading = false;

    notifyListeners();
    return true;
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<int?> getRoleId() async {
    String? roleIdStr = await _secureStorage.read(key: 'role_id');
    if (roleIdStr != null) {
      _roleId = int.tryParse(roleIdStr);
      notifyListeners();
      return _roleId;
    }
    return null;
  }

  Future<void> logoutUser(BuildContext context) async {
    final savedProvider = context.read<SavedProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final destinationProvider = context.read<DestinationProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final activityProvider = context.read<ActivityProvider>();
    final imgProvider = context.read<ImgProvider>();

    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'role_id');
    await _secureStorage.delete(key: 'user_id');

    _user = null;
    _roleId = null;
    _userId = null;
    _errorMessage = null;
    _isLoading = false;
    _isLoggedIn = false;
    _isGuest = false;
    _isMan = false;
    notifyListeners();

    try {
      activityProvider.clearActivity();
      bookingProvider.clearBookings();
      savedProvider.clearSavedDestinations();
      profileProvider.clearProfile();
      destinationProvider.clearDestinations();
      imgProvider.clearImages();
    } catch (e) {
      debugPrint("⚠️ Could not clear providers: $e");
    }
  }

  Future<bool> tryAutoLogin() async {
    final token = await _secureStorage.read(key: 'auth_token');
    final userIdStr = await _secureStorage.read(key: 'user_id');
    final roleIdStr = await _secureStorage.read(key: 'role_id');

    _isGuest = false;
    _isMan = false;

    if (token != null && userIdStr != null && roleIdStr != null) {
      _userId = int.tryParse(userIdStr);
      _roleId = int.tryParse(roleIdStr);
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }

    _isLoggedIn = false;
    notifyListeners();
    return false;
  }

  void continueAsGuest() {
    _isGuest = true;
    _isLoggedIn = false;
    _user = null;
    _roleId = null;
    _userId = null;
    _errorMessage = null;
    notifyListeners();
  }

  void setIsGuest(bool value) {
    _isGuest = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
