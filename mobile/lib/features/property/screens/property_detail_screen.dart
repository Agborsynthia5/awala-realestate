import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awala_mobile/core/theme/app_theme.dart';
import 'package:awala_mobile/core/constants/app_constants.dart';
import 'package:awala_mobile/core/utils/image_url_util.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;
  final Map<String, dynamic>? propertyData;
  const PropertyDetailScreen({super.key, required this.propertyId, this.propertyData});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isSaved = false;
  int _currentImage = 0;
  final PageController _imageController = PageController();

  // Demo property — replace with API call via Riverpod
  late Map<String, dynamic> _property;

  @override
  void initState() {
    super.initState();
    _property = widget.propertyData ?? {
      'id': widget.propertyId,
      'title': 'Spacious Self-Contained Room',
      'description':
          'Located in a serene and secure environment in Molyko, this bright self-contained room features reliable water supply and 24/7 electricity. Walking distance from UB campus and all major amenities. Ideal for students and young professionals.',
      'type': 'room',
      'price': 25000,
      'currency': 'XAF',
      'furnished': true,
      'bedrooms': 1,
      'bathrooms': 1,
      'location_name': 'Molyko Junction Area, Buea',
      'neighborhood': 'Molyko',
      'city': 'Buea',
      'distance_from_molyko_km': 0.3,
      'is_verified': true,
      'is_active': true,
      'whatsapp_number': '+237677000001',
      'phone_number': '+237677000001',
      'amenities': [
        'WiFi', 'Running Water', '24/7 Electricity', 'Security', 'Tiled Floors'
      ],
      'images': [],
      'owner_name': 'Ngwa Emmanuel',
    };
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    final number = (_property['whatsapp_number'] as String)
        .replaceAll('+', '').replaceAll(' ', '');
    final msg = Uri.encodeComponent(
        'Hi, I saw your listing "${_property['title']}" on Awala RealEstate. Is it still available?');
    final url = Uri.parse('${AppConstants.whatsappScheme}$number?text=$msg');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _callLandlord() async {
    final url = Uri.parse('tel:${_property['phone_number']}');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final amenities = List<String>.from(_property['amenities'] ?? []);
    final images = resolvePropertyImages(_property['images'] as List?);
    final distance = _property['distance_from_molyko_km'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Image Header ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 16),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: Icon(
                      _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: _isSaved ? AppColors.cta : Colors.white,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isSaved = !_isSaved),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image carousel
                  images.isNotEmpty
                      ? PageView.builder(
                          controller: _imageController,
                          onPageChanged: (i) =>
                              setState(() => _currentImage = i),
                          itemCount: images.length,
                          itemBuilder: (_, i) => Image.network(
                            images[i],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              child: Icon(Icons.broken_image_outlined,
                                  size: 48, color: AppColors.accent.withValues(alpha: 0.4)),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_work_outlined,
                                  size: 80,
                                  color: AppColors.accent.withValues(alpha: 0.4)),
                              const SizedBox(height: 8),
                              Text('No photos yet',
                                  style: TextStyle(
                                      color: AppColors.accent.withValues(alpha: 0.6),
                                      fontSize: 13)),
                            ],
                          ),
                        ),

                  // Page indicator
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentImage + 1}/${images.length}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── Content ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(_property['title'] ?? '',
                            style: Theme.of(context).textTheme.headlineMedium),
                      ),
                      if (_property['is_verified'] == true)
                        Chip(
                          label: const Text('Verified',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                          backgroundColor: AppColors.success,
                          padding: EdgeInsets.zero,
                          avatar: const Icon(Icons.verified_rounded,
                              color: Colors.white, size: 14),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 16, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _property['location_name'] ?? _property['neighborhood'] ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Distance from Molyko
                  if (distance != null)
                    Row(
                      children: [
                        const Icon(Icons.near_me_rounded,
                            size: 14, color: AppColors.cta),
                        const SizedBox(width: 4),
                        Text(
                          '${(distance as num).toStringAsFixed(1)} km from Molyko Junction',
                          style: const TextStyle(
                              color: AppColors.cta,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Monthly Rent',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            Text(
                              '${((_property['price'] as num).toInt() / 1000).toStringAsFixed(0)}K FCFA/month',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        _StatusBadge(
                            active: _property['is_active'] == true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Specs
                  Row(
                    children: [
                      _InfoTile(
                          icon: Icons.bed_rounded,
                          label: 'Bedrooms',
                          value: '${_property['bedrooms'] ?? 1}'),
                      const SizedBox(width: 12),
                      _InfoTile(
                          icon: Icons.bathtub_rounded,
                          label: 'Bathrooms',
                          value: '${_property['bathrooms'] ?? 1}'),
                      const SizedBox(width: 12),
                      _InfoTile(
                          icon: Icons.chair_rounded,
                          label: 'Furnished',
                          value: _property['furnished'] == true ? 'Yes' : 'No'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text('Description',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    _property['description'] ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.7),
                  ),
                  const SizedBox(height: 20),

                  // Amenities
                  Text('Amenities',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: amenities
                        .map((a) => _AmenityChip(label: a))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // Report
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _showReportDialog(),
                      icon: const Icon(Icons.flag_outlined,
                          size: 16, color: AppColors.error),
                      label: const Text('Report this listing',
                          style: TextStyle(
                              color: AppColors.error, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ─── Bottom Contact Bar ──────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Call
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _callLandlord,
                icon: const Icon(Icons.phone_rounded, size: 18),
                label: const Text('Call'),
              ),
            ),
            const SizedBox(width: 12),
            // WhatsApp
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _openWhatsApp,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366)),
                icon: const Icon(Icons.chat_rounded, size: 18),
                label: const Text('WhatsApp'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report Listing'),
        content: const Text(
            'Why are you reporting this listing? Our team will review it within 24 hours.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error),
              child: const Text('Report')),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool active;
  const _StatusBadge({required this.active});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: active
              ? AppColors.success.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          active ? 'Available' : 'Taken',
          style: TextStyle(
              color: active ? AppColors.success : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.accent, size: 22),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}

class _AmenityChip extends StatelessWidget {
  final String label;
  const _AmenityChip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 13, color: AppColors.success),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.success,
                  fontWeight: FontWeight.w500)),
        ]),
      );
}
