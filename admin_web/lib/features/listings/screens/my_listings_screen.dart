import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/image_url_util.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/property.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  bool _isLoading = true;
  List<Property> _properties = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    try {
      final props = await ref.read(apiServiceProvider).getMyProperties(user.id);
      setState(() {
        _properties = props;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load listings: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }



  Future<void> _toggleActive(Property property) async {
    try {
      await ref.read(apiServiceProvider).togglePropertyActive(property.id, !property.isActive);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Listing "${property.title}" is now ${!property.isActive ? 'Taken' : 'Free'}'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadListings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deleteProperty(Property property) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text('Are you sure you want to permanently delete "${property.title}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(apiServiceProvider).deleteProperty(property.id);
      setState(() {
        _properties = _properties.where((p) => p.id != property.id).toList();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted successfully'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete listing: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProperties = _properties.where((p) {
      return p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.neighborhood?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Listings',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage, active/deactivate, or delete your real estate listings.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/listings/add'),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add New Listing'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Filters & Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search listings by title or neighborhood...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() => _isLoading = true);
                    _loadListings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Listings Table
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProperties.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_work_outlined, size: 64, color: AppColors.textHint),
                              const SizedBox(height: 16),
                              const Text(
                                'No listings found',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              const SizedBox(height: 8),
                              const Text('Click "Add New Listing" to create your first property.'),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 36,
                                  headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.05)),
                                  columns: const [
                                    DataColumn(label: Text('Photo', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: filteredProperties.map((p) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: p.images.isNotEmpty
                                                ? Image.network(resolveImageUrl(p.images.first), width: 60, height: 45, fit: BoxFit.cover)
                                                : Container(
                                                    width: 60,
                                                    height: 45,
                                                    color: AppColors.background,
                                                    child: const Icon(Icons.image_not_supported_outlined, size: 16),
                                                  ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            p.title,
                                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                                          ),
                                        ),
                                        DataCell(Text('${p.price.toStringAsFixed(0)} FCFA')),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: p.isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              p.isActive ? 'Free' : 'Taken',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: p.isActive ? AppColors.success : AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert),
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                context.push('/listings/edit', extra: p);
                                              } else if (value == 'delete') {
                                                _deleteProperty(p);
                                              } else if (value == 'toggle') {
                                                _toggleActive(p);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'toggle',
                                                child: Row(
                                                  children: [
                                                    Icon(p.isActive ? Icons.event_busy : Icons.event_available, color: p.isActive ? AppColors.error : AppColors.success, size: 20),
                                                    const SizedBox(width: 8),
                                                    Text(p.isActive ? 'Set as Taken' : 'Set as Free', style: TextStyle(color: p.isActive ? AppColors.error : AppColors.success)),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Delete completely', style: TextStyle(color: AppColors.error)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

