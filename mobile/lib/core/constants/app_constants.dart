/// API & App constants for Awala RealEstate
abstract class AppConstants {
  // ─── API ──────────────────────────────────────────────────────────
  /// Host root (no /api/v1 suffix) — used for static image URLs.
  /// Change this to your PC's LAN IP when testing on a physical device.
  /// Android emulator: use http://10.0.2.2:8001
  /// iOS simulator: use http://localhost:8001
  static const String apiHost = 'http://192.168.1.232:8001';
  static const String baseUrl = '$apiHost/api/v1';
  // ─── Geospatial ───────────────────────────────────────────────────
  static const double molykoLat = 4.1527;
  static const double molykoLng = 9.2345;
  static const String molykoLabel = 'Molyko Junction';

  // ─── Storage Keys ─────────────────────────────────────────────────
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardingDoneKey = 'onboarding_done';
  static const String preferredLanguageKey = 'preferred_language';

  // ─── Pagination ───────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ─── Cache TTL ────────────────────────────────────────────────────
  static const Duration cacheTtl = Duration(hours: 6);

  // ─── Map ──────────────────────────────────────────────────────────
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const double defaultZoom = 14.0;
  static const double minZoom = 5.0;
  static const double maxZoom = 18.0;

  // ─── Property Types ───────────────────────────────────────────────
  static const List<String> propertyTypes = ['room', 'studio', 'apartment', 'villa'];
  static const List<String> propertyTypeLabels = ['Room', 'Studio', 'Apartment', 'Villa'];

  // ─── Neighborhoods ────────────────────────────────────────────────
  static const List<String> bueaNeighborhoods = [
    'Molyko', 'Bonduma', 'Mile 16', 'Small Soppo', 'Great Soppo',
    'Bokwango', 'Buea Town', "Clerk's Quarters", 'GRA', 'Muea',
  ];

  // ─── Currency ─────────────────────────────────────────────────────
  static const String currency = 'XAF';
  static const String currencySymbol = 'FCFA';

  // ─── Amenities ────────────────────────────────────────────────────
  static const List<String> amenitiesList = [
    'WiFi', 'Running Water', '24/7 Electricity', 'Generator',
    'Parking', 'Security', 'CCTV', 'Furnished Kitchen',
    'Air Conditioning', 'Balcony', 'Garden', 'Borehole',
    'Solar Power', 'Tiled Floors', 'POP Ceiling', 'Wardrobe',
  ];

  // ─── Price Range (XAF) ────────────────────────────────────────────
  static const double minPrice = 5000;
  static const double maxPrice = 500000;

  // ─── WhatsApp ─────────────────────────────────────────────────────
  static const String whatsappScheme = 'https://wa.me/';
}
