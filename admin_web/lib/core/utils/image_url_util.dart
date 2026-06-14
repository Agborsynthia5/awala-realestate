import '../constants/app_constants.dart';

/// Resolve a stored image path to a full URL loadable by Image.network / CachedNetworkImage.
String resolveImageUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:')) {
    return url;
  }
  if (url.startsWith('/')) {
    return '${AppConstants.apiHost}$url';
  }
  return '${AppConstants.apiHost}/$url';
}
