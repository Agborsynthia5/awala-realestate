import '../constants/app_constants.dart';

/// Resolve a stored image path to a full URL loadable by CachedNetworkImage.
String resolveImageUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  if (url.startsWith('/')) {
    return '${AppConstants.apiHost}$url';
  }
  return '${AppConstants.apiHost}/$url';
}

/// Resolve all image paths in a property map returned by the API.
List<String> resolvePropertyImages(List<dynamic>? images) {
  if (images == null || images.isEmpty) return [];
  return images.map((e) => resolveImageUrl(e.toString())).toList();
}
