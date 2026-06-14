import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../../models/property.dart';
import '../../models/user.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  void setToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // ─── Authentication ────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      setToken(data['access_token']);
      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/users/me', data: data);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Properties / Listings ──────────────────────────────────────────
  Future<List<Property>> getMyProperties(String ownerId) async {
    try {
      final response = await _dio.get('/properties', queryParameters: {
        'owner_id': ownerId,
        'include_inactive': true,
      });
      final results = response.data['results'] as List;
      return results.map((p) => Property.fromJson(p)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Property> createProperty(Map<String, dynamic> propertyData) async {
    try {
      final response = await _dio.post('/properties', data: propertyData);
      return Property.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Property> updateProperty(String id, Map<String, dynamic> propertyData) async {
    try {
      final response = await _dio.put('/properties/$id', data: propertyData);
      return Property.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      await _dio.delete('/properties/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Property> togglePropertyActive(String id, bool isActive) async {
    try {
      final response = await _dio.put('/properties/$id', data: {
        'is_active': isActive,
      });
      return Property.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload an image to local backend storage (offline-friendly).
  Future<String> uploadImage(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final response = await _dio.post(
        '/uploads/images',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data as Map<String, dynamic>;
      return data['url'] as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Exception handling helper
  String _handleError(DioException e) {
    if (e.response != null) {
      final detail = e.response?.data?['detail'];
      if (detail != null) return detail.toString();
      return 'Server error (${e.response?.statusCode})';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Network connection timed out';
    }
    return 'Connection failed. Please ensure the backend is running.';
  }
}
