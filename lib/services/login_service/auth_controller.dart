import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rburger/services/data/branch_data.dart';
import 'package:rburger/services/data/menu_data.dart';

class AuthController extends ChangeNotifier {
  static final AuthController instance = AuthController._internal();
  AuthController._internal();

  final _storage = const FlutterSecureStorage();

  static const _keyToken = 'token';
  static const _keyRefreshToken = 'refreshToken';
  static const _keyName = 'name';
  static const _keyMobile = 'mobile';
  static const _keyAddress = 'address';
  static const _keyCustomerId = 'customerId';
  static const _keyDriverId = 'driverId';
  static const _keyDriverBranchId = 'driverBranchId';
  static const _keyCustomerBranchId = 'customerBranchId';

  bool isLoggedIn = false;
  bool isDriverLoggedIn = false;

  String? token;
  String? refreshToken;
  String name = '';
  String mobile = '';
  String address = '';
  String? customerId;
  String? driverId;
  int? driverBranchId;
  int? customerBranchId;

  Future<void> tryAutoLogin() async {
    try {
      final storedToken = await _storage.read(key: _keyToken);
      final storedRefreshToken = await _storage.read(key: _keyRefreshToken);
      final storedName = await _storage.read(key: _keyName);
      final storedMobile = await _storage.read(key: _keyMobile);
      final storedAddress = await _storage.read(key: _keyAddress);
      final storedCustomerId = await _storage.read(key: _keyCustomerId);
      final storedCustomerBranchId = await _storage.read(
        key: _keyCustomerBranchId,
      );

      final storedDriverId = await _storage.read(key: _keyDriverId);
      final storedDriverBranchId = await _storage.read(key: _keyDriverBranchId);

      // 1. Check Driver Login
      if (storedDriverId != null && storedToken != null) {
        token = storedToken;
        refreshToken = storedRefreshToken;
        driverId = storedDriverId;
        driverBranchId = storedDriverBranchId != null
            ? int.tryParse(storedDriverBranchId)
            : null;
        isDriverLoggedIn = true;

        if (driverBranchId != null) {
          await MenuService.getMenu(driverBranchId!);
        }

        notifyListeners();
        return;
      }

      // 2. Check Customer Login
      if (storedToken != null && storedCustomerId != null) {
        token = storedToken;
        refreshToken = storedRefreshToken;
        name = storedName ?? '';
        mobile = storedMobile ?? '';
        address = storedAddress ?? '';
        customerId = storedCustomerId;
        customerBranchId = storedCustomerBranchId != null
            ? int.tryParse(storedCustomerBranchId)
            : null;
        isLoggedIn = true;

        final branchIdToUse = await getSavedBranchId();
        await MenuService.getMenu(customerBranchId ?? branchIdToUse);

        notifyListeners();
        return;
      }

      // 3. Fallback for Guest Users / Not Logged In
      // This ensures the menu is ALWAYS loaded on cold start even if no tokens exist
      final defaultBranchId = await getSavedBranchId();
      await MenuService.getMenu(defaultBranchId);
    } catch (e) {
      debugPrint('Secure storage decryption error (wiping corrupted keys): $e');
      await _storage.deleteAll();
      isLoggedIn = false;
      isDriverLoggedIn = false;

      // Even if storage fails, try to grab the default menu for guests
      try {
        final defaultBranchId = await getSavedBranchId();
        await MenuService.getMenu(defaultBranchId);
      } catch (_) {}

      notifyListeners();
    }
  }

  Future<void> saveBranchId(int branchId) async {
    customerBranchId = branchId;
    await _storage.write(key: _keyCustomerBranchId, value: branchId.toString());
    notifyListeners();
  }

  Future<int> getSavedBranchId() async {
    try {
      if (customerBranchId != null) return customerBranchId!;
      final String? storedValue = await _storage.read(
        key: _keyCustomerBranchId,
      );
      if (storedValue != null) {
        customerBranchId = int.tryParse(storedValue);
        if (customerBranchId != null) return customerBranchId!;
      }
    } catch (e) {
      debugPrint('Secure storage error: $e');
      await _storage.deleteAll();
    }

    // If branches list is empty, fetch them explicitly right here to guarantee we get ID 2 (Sohag)
    if (branches.isEmpty) {
      try {
        await BranchService.getBranch();
      } catch (e) {
        debugPrint('Failed to fetch branches in fallback: $e');
      }
    }

    if (branches.isNotEmpty) {
      customerBranchId = branches.first.id;
      return customerBranchId!;
    }

    return branches.isNotEmpty
        ? branches.first.id
        : throw Exception('No branches available');
  }

  bool _isTokenExpired(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return true;
      final payload =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              )
              as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp == null) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
      // 30s buffer so we refresh slightly before actual expiry
      return DateTime.now().isAfter(
        expiry.subtract(const Duration(seconds: 30)),
      );
    } catch (e) {
      debugPrint('JWT decode failed: $e');
      return true;
    }
  }

  Future<String?> getValidAccessToken() async {
    if (token == null) return null;
    if (!_isTokenExpired(token!)) return token;

    final refreshed = await TokenAuthService.refreshToken();
    return refreshed ? token : null;
  }

  Future<void> loginCustomer({
    required String customerId,
    required String fullName,
    required String accessToken,
    required String refreshTokenValue,
    String? mobile,
    String? address,
  }) async {
    await _storage.write(key: _keyCustomerId, value: customerId);
    await _storage.write(key: _keyName, value: fullName);
    await _storage.write(key: _keyToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshTokenValue);
    if (mobile != null) await _storage.write(key: _keyMobile, value: mobile);
    if (address != null) await _storage.write(key: _keyAddress, value: address);

    this.customerId = customerId;
    name = fullName;
    token = accessToken;
    refreshToken = refreshTokenValue;
    if (mobile != null) this.mobile = mobile;
    if (address != null) this.address = address;
    isLoggedIn = true;
    isDriverLoggedIn = false;

    // Fetch menu using the user's previously saved branch ID upon login
    final branchIdToUse = await getSavedBranchId();
    await MenuService.getMenu(branchIdToUse);

    notifyListeners();
  }

  Future<void> loginDriver({
    required String driverId,
    required String fullName,
    required int branchId,
    required String accessToken,
    required String refreshTokenValue,
  }) async {
    await _storage.write(key: _keyDriverId, value: driverId);
    await _storage.write(key: _keyName, value: fullName);
    await _storage.write(key: _keyDriverBranchId, value: branchId.toString());
    await _storage.write(key: _keyToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshTokenValue);

    this.driverId = driverId;
    name = fullName;
    driverBranchId = branchId;
    token = accessToken;
    refreshToken = refreshTokenValue;
    isDriverLoggedIn = true;
    isLoggedIn = false;

    await MenuService.getMenu(branchId);

    notifyListeners();
  }

  Future<void> updateTokens({
    required String newAccessToken,
    required String newRefreshToken,
  }) async {
    token = newAccessToken;
    refreshToken = newRefreshToken;
    await _storage.write(key: _keyToken, value: newAccessToken);
    await _storage.write(key: _keyRefreshToken, value: newRefreshToken);
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyName);
    await _storage.delete(key: _keyMobile);
    await _storage.delete(key: _keyAddress);
    await _storage.delete(key: _keyCustomerId);
    await _storage.delete(key: _keyCustomerBranchId);
    await _storage.delete(key: _keyDriverId);
    await _storage.delete(key: _keyDriverBranchId);

    token = null;
    refreshToken = null;
    name = '';
    mobile = '';
    address = '';
    customerId = null;
    customerBranchId = null;
    driverId = null;
    driverBranchId = null;
    isLoggedIn = false;
    isDriverLoggedIn = false;

    notifyListeners();
  }
}

class TokenAuthService {
  static final String _baseUrl = dotenv.get('API_URL');

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<bool> refreshToken() async {
    try {
      final currentRefreshToken = AuthController.instance.refreshToken;
      if (currentRefreshToken == null) return false;

      final response = await _dio.post(
        '/v1/auth/refresh',
        data: {'refreshToken': currentRefreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        await AuthController.instance.updateTokens(
          newAccessToken: data['accessToken'],
          newRefreshToken: data['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return false;
    }
  }

  static Future<void> logoutUser() async {
    try {
      final currentAccessToken = AuthController.instance.token;
      final currentRefreshToken = AuthController.instance.refreshToken;
      if (currentRefreshToken != null) {
        await _dio.post(
          '/v1/auth/logout',
          data: {
            'accessToken': currentAccessToken,
            'refreshToken': currentRefreshToken,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $currentAccessToken'},
          ),
        );
      }
    } catch (e) {
      debugPrint('Logout API call failed: $e');
    } finally {
      await AuthController.instance.logout();
    }
  }
}
