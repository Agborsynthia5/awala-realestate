import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:awala_mobile/core/utils/image_url_util.dart';
import 'package:awala_mobile/core/theme/app_theme.dart';

class PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;

  const PropertyCard({super.key, required this.property, required this.onTap});

  String _formatPrice(dynamic price) {
    final p = (price as num).toInt();
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K FCFA/mo';
    return '$p FCFA/mo';
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'studio': return AppColors.accent;
      case 'apartment': return const Color(0xFF8B5CF6);
      case 'villa': return AppColors.cta;
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawImages = property['images'] as List? ?? [];
    final images = rawImages.map((e) => resolveImageUrl(e.toString())).toList();
    final hasImage = images.isNotEmpty;
    final type = property['type'] as String? ?? 'room';
    final isVerified = property['is_verified'] as bool? ?? false;
    final distance = property['distance_from_molyko_km'] ??
        property['distance'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // ─── Image ───────────────────────────────────────────
              SizedBox(
                width: 130,
                child: Stack(
                  children: [
                    if (hasImage)
                      CachedNetworkImage(
                        imageUrl: images[0],
                        height: double.infinity,
                        width: 130,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: AppColors.background,
                          highlightColor: Colors.white,
                          child: Container(color: AppColors.background),
                        ),
                        errorWidget: (_, __, ___) => _PlaceholderImage(type: type),
                      )
                    else
                      _PlaceholderImage(type: type),

                    // Type badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _typeColor(type),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          type[0].toUpperCase() + type.substring(1),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Details ──────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title + Verified
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              property['title'] ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.verified_rounded,
                                  color: AppColors.accent, size: 16),
                            ),
                        ],
                      ),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            property['neighborhood'] ?? 'Buea',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),

                      // Specs
                      Row(
                        children: [
                          _SpecBadge(
                              icon: Icons.bed_rounded,
                              label: '${property['bedrooms'] ?? 1} bed'),
                          const SizedBox(width: 8),
                          _SpecBadge(
                              icon: Icons.bathtub_rounded,
                              label: '${property['bathrooms'] ?? 1} bath'),
                          if (property['furnished'] == true) ...[
                            const SizedBox(width: 8),
                            _SpecBadge(
                                icon: Icons.chair_rounded,
                                label: 'Furnished'),
                          ],
                        ],
                      ),

                      // Price + Distance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatPrice(property['price'] ?? 0),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (distance != null)
                            Row(
                              children: [
                                const Icon(Icons.near_me_rounded,
                                    size: 12, color: AppColors.cta),
                                const SizedBox(width: 2),
                                Text(
                                  '${distance.toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.cta,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final String type;
  const _PlaceholderImage({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accent.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          type == 'villa'
              ? Icons.villa_rounded
              : type == 'apartment'
                  ? Icons.apartment_rounded
                  : Icons.meeting_room_rounded,
          size: 40,
          color: AppColors.accent.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
