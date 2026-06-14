import 'package:dio/dio.dart';
import 'package:awala_mobile/core/constants/app_constants.dart';

class PropertyService {
  final Dio _dio;

  PropertyService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  /// Fetch a paginated list of properties from the backend.
  /// Returns the `results` array from the API response as a List of maps.
  Future<List<Map<String, dynamic>>> fetchProperties({Map<String, dynamic>? query}) async {
    try {
      final resp = await _dio.get('/properties', queryParameters: query);
      if (resp.statusCode == 200) {
        final data = resp.data as Map<String, dynamic>?;
        if (data != null && data.containsKey('results')) {
          final results = data['results'] as List<dynamic>;
          return results.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
      return [];
    } on DioException {
      // You may want to handle logging / error mapping here.
      return [];
    }
  }
}
