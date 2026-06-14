import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:awala_mobile/core/theme/app_theme.dart';
import 'package:awala_mobile/core/constants/app_constants.dart';
import 'package:awala_mobile/core/router/app_router.dart';
import 'package:awala_mobile/core/services/api_service.dart';
import '../widgets/property_card.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedType = 'all';
  String _searchQuery = '';

  // Listings loaded from API
  final ApiService _service = ApiService();
  List<Map<String, dynamic>> _listings = [];
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> get _filtered {
    return _listings.where((p) {
      final matchType = _selectedType == 'all' || p['type'] == _selectedType;
      final matchQuery = _searchQuery.isEmpty ||
          p['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['neighborhood'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchType && matchQuery;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.fetchProperties(query: {'page_size': 50});
      if (!mounted) return;
      setState(() {
        _listings = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.primary,
            expandedHeight: 130,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient),
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good morning 👋',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13)),
                            const Text('Find your space in Buea',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune_rounded,
                              color: Colors.white),
                          onPressed: _showFilterSheet,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SearchBarWidget(
                  onChanged: (q) => setState(() => _searchQuery = q),
                  onTap: () {},
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Filter chips
            FilterChipBar(
              selectedType: _selectedType,
              onSelected: (t) => setState(() => _selectedType = t),
            ),
            const SizedBox(height: 4),

            // Results header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filtered.length} properties found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: () => context.go(AppRoutes.map),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Map view'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        textStyle: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),

            // Listing grid
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cloud_off_outlined,
                                    size: 48, color: AppColors.textSecondary),
                                const SizedBox(height: 12),
                                Text(_error!,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchListings,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _filtered.isEmpty
                      ? _EmptyState(onBrowse: () => setState(() {
                            _selectedType = 'all';
                            _searchQuery = '';
                          }))
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 1.6,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) {
                            final p = _filtered[i];
                            return PropertyCard(
                              property: p,
                              onTap: () => context.push(
                                  '/property/${p['id']}', extra: p),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterBottomSheet(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyState({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home_work_outlined,
                  size: 52, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            Text('No properties found',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search for a different area.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onBrowse,
              child: const Text('Browse All Properties'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();
  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(10000, 200000);
  bool? _furnished;
  String? _neighborhood;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24, right: 24, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Filter Properties',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),

          // Price range
          Text('Price Range (FCFA)',
              style: Theme.of(context).textTheme.titleMedium),
          RangeSlider(
            values: _priceRange,
            min: 5000,
            max: 500000,
            divisions: 99,
            activeColor: AppColors.primary,
            labels: RangeLabels(
              '${(_priceRange.start / 1000).toStringAsFixed(0)}K',
              '${(_priceRange.end / 1000).toStringAsFixed(0)}K',
            ),
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(_priceRange.start / 1000).toStringAsFixed(0)}K FCFA',
                  style: Theme.of(context).textTheme.bodySmall),
              Text('${(_priceRange.end / 1000).toStringAsFixed(0)}K FCFA',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 16),

          // Furnished toggle
          Text('Furnished', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              _ToggleChip(label: 'Any', selected: _furnished == null,
                  onTap: () => setState(() => _furnished = null)),
              const SizedBox(width: 8),
              _ToggleChip(label: 'Furnished', selected: _furnished == true,
                  onTap: () => setState(() => _furnished = true)),
              const SizedBox(width: 8),
              _ToggleChip(label: 'Unfurnished', selected: _furnished == false,
                  onTap: () => setState(() => _furnished = false)),
            ],
          ),
          const SizedBox(height: 16),

          // Neighborhood
          Text('Neighborhood', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _neighborhood,
            hint: const Text('Any neighborhood'),
            decoration: const InputDecoration(),
            items: AppConstants.bueaNeighborhoods
                .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                .toList(),
            onChanged: (v) => setState(() => _neighborhood = v),
          ),
          const SizedBox(height: 24),

          // Apply
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
