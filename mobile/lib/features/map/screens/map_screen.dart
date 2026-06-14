import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:awala_mobile/core/theme/app_theme.dart';
import 'package:awala_mobile/core/constants/app_constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Demo property pins
  final List<Map<String, dynamic>> _pins = [
    {'id': '1', 'title': 'Self-Contained Room', 'lat': 4.1530, 'lng': 9.2348, 'price': 25000, 'type': 'room'},
    {'id': '2', 'title': 'Modern Studio', 'lat': 4.1580, 'lng': 9.2290, 'price': 55000, 'type': 'studio'},
    {'id': '3', 'title': '2-Bedroom Apartment', 'lat': 4.1510, 'lng': 9.2370, 'price': 85000, 'type': 'apartment'},
    {'id': '4', 'title': 'Affordable Room', 'lat': 4.1650, 'lng': 9.2450, 'price': 18000, 'type': 'room'},
    {'id': '5', 'title': 'Cozy Studio', 'lat': 4.1560, 'lng': 9.2310, 'price': 40000, 'type': 'studio'},
  ];

  Map<String, dynamic>? _selectedPin;

  Color _pinColor(String type) {
    switch (type) {
      case 'studio': return AppColors.accent;
      case 'apartment': return const Color(0xFF8B5CF6);
      case 'villa': return AppColors.cta;
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Map ───────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                  AppConstants.molykoLat, AppConstants.molykoLng),
              initialZoom: AppConstants.defaultZoom,
              minZoom: AppConstants.minZoom,
              maxZoom: AppConstants.maxZoom,
              onTap: (_, __) => setState(() => _selectedPin = null),
            ),
            children: [
              // OSM tiles
              TileLayer(
                urlTemplate: AppConstants.osmTileUrl,
                userAgentPackageName: 'com.awala.mobile',
              ),

              // Property markers
              MarkerLayer(
                markers: [
                  // Molyko Junction landmark
                  Marker(
                    point: LatLng(AppConstants.molykoLat, AppConstants.molykoLng),
                    width: 120,
                    height: 40,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '📍 Molyko Jcn',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Property pins
                  ..._pins.map((p) => Marker(
                        point: LatLng(p['lat'], p['lng']),
                        width: 70,
                        height: 36,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPin = p),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedPin?['id'] == p['id']
                                  ? AppColors.cta
                                  : _pinColor(p['type']),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Text(
                              '${((p['price'] as int) / 1000).toStringAsFixed(0)}K',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),

          // ─── Top bar ───────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search area...',
                        hintStyle: TextStyle(
                            color: AppColors.textHint, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: AppColors.textHint, size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Recenter
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.my_location_rounded,
                        color: AppColors.primary),
                    onPressed: () => _mapController.move(
                      LatLng(AppConstants.molykoLat, AppConstants.molykoLng),
                      AppConstants.defaultZoom,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Property count badge ──────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 68,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_pins.length} properties',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // ─── Selected pin preview card ─────────────────────────────
          if (_selectedPin != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: _PinPreviewCard(
                property: _selectedPin!,
                onTap: () => context.push('/property/${_selectedPin!['id']}', extra: _selectedPin!),
                onClose: () => setState(() => _selectedPin = null),
              ),
            ),
        ],
      ),
    );
  }
}

class _PinPreviewCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;
  final VoidCallback onClose;
  const _PinPreviewCard(
      {required this.property, required this.onTap, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_rounded,
                  color: AppColors.accent, size: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property['title'],
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    '${((property['price'] as int) / 1000).toStringAsFixed(0)}K FCFA/mo · ${property['type']}',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textHint, size: 20),
                  onPressed: onClose,
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
