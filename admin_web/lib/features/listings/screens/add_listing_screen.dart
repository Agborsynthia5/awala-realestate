import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/image_url_util.dart';
import '../../../core/theme/app_theme.dart';

class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({super.key});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  int _currentStep = 0;
  bool _isSaving = false;

  // Step 1: Photos state
  final List<String> _uploadedImages = [];
  bool _isUploading = false;

  // Step 2: Form Key & Data
  final _formKey = GlobalKey<FormBuilderState>();

  // Step 3: Map Location state
  LatLng _selectedLatLng = const LatLng(AppConstants.molykoLat, AppConstants.molykoLng);
  final MapController _mapController = MapController();

  // Step 4: Amenities state
  final List<String> _selectedAmenities = [];

  Future<void> _pickAndUploadImage() async {
    if (_uploadedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can upload a maximum of 10 images.')),
      );
      return;
    }

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _isUploading = true);

    try {
      final api = ref.read(apiServiceProvider);
      final bytes = await file.readAsBytes();
      final url = await api.uploadImage(bytes, file.name);
      setState(() {
        _uploadedImages.add(url);
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _submitListing() async {
    if (_uploadedImages.isEmpty) {
      setState(() => _currentStep = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload at least one image in Step 1.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState == null || !_formKey.currentState!.saveAndValidate()) {
      setState(() => _currentStep = 1);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final formValues = _formKey.currentState!.value;
      final user = ref.read(authProvider).user;

      final payload = {
        'owner_id': user?.id,
        'title': formValues['title'],
        'description': formValues['description'],
        'type': formValues['type'],
        'price': double.parse(formValues['price'].toString()),
        'currency': AppConstants.currency,
        'furnished': formValues['furnished'] ?? false,
        'bedrooms': int.parse(formValues['bedrooms']?.toString() ?? '1'),
        'bathrooms': int.parse(formValues['bathrooms']?.toString() ?? '1'),
        'location_name': formValues['location_name'],
        'latitude': _selectedLatLng.latitude,
        'longitude': _selectedLatLng.longitude,
        'neighborhood': formValues['neighborhood'],
        'city': 'Buea',
        'amenities': _selectedAmenities,
        'images': _uploadedImages,
        'whatsapp_number': formValues['whatsapp_number'],
        'phone_number': formValues['phone_number'],
      };

      await ref.read(apiServiceProvider).createProperty(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing created successfully!'), backgroundColor: AppColors.success),
        );
        context.go('/listings');
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create listing: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isSaving
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving listing in Buea, please wait...', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.go('/listings'),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Add New Listing',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

                // Stepper Form
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.cta,
                        onSurface: AppColors.textSecondary,
                      ),
                    ),
                    child: Stepper(
                      type: StepperType.horizontal,
                      currentStep: _currentStep,
                      onStepContinue: () {
                        if (_currentStep < 3) {
                          setState(() => _currentStep += 1);
                        } else {
                          _submitListing();
                        }
                      },
                      onStepCancel: () {
                        if (_currentStep > 0) {
                          setState(() => _currentStep -= 1);
                        }
                      },
                      steps: [
                        Step(
                          title: const Text('Photos'),
                          isActive: _currentStep >= 0,
                          state: _currentStep > 0 ? StepState.complete : StepState.editing,
                          content: _buildStep1Photos(),
                        ),
                        Step(
                          title: const Text('Details'),
                          isActive: _currentStep >= 1,
                          state: _currentStep > 1 ? StepState.complete : StepState.editing,
                          content: _buildStep2Details(),
                        ),
                        Step(
                          title: const Text('Location'),
                          isActive: _currentStep >= 2,
                          state: _currentStep > 2 ? StepState.complete : StepState.editing,
                          content: _buildStep3Location(),
                        ),
                        Step(
                          title: const Text('Amenities'),
                          isActive: _currentStep >= 3,
                          state: _currentStep > 3 ? StepState.complete : StepState.editing,
                          content: _buildStep4Amenities(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // STEP 1 UI: PHOTOS
  Widget _buildStep1Photos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Property Images',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload up to 10 high-quality photos. First photo will be the listing cover image.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // Images grid
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ..._uploadedImages.asMap().entries.map((entry) {
              final idx = entry.key;
              final url = entry.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(resolveImageUrl(url), width: 120, height: 120, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => setState(() => _uploadedImages.removeAt(idx)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                  if (idx == 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Text(
                          'COVER',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                ],
              );
            }),

            if (_uploadedImages.length < 10)
              InkWell(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.5, style: BorderStyle.solid),
                  ),
                  child: Center(
                    child: _isUploading
                        ? const CircularProgressIndicator()
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 36, color: AppColors.textHint),
                              SizedBox(height: 8),
                              Text('Add Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // STEP 2 UI: DETAILS
  Widget _buildStep2Details() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Property Specifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'title',
                          decoration: const InputDecoration(labelText: 'Listing Title', hintText: 'e.g., Modern Studio near UB Junction'),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.minLength(5),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderDropdown<String>(
                          name: 'type',
                          decoration: const InputDecoration(labelText: 'Property Type'),
                          initialValue: 'studio',
                          items: AppConstants.propertyTypes
                              .asMap()
                              .entries
                              .map((entry) => DropdownMenuItem(
                                    value: entry.value,
                                    child: Text(AppConstants.propertyTypeLabels[entry.key]),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'price',
                          decoration: InputDecoration(labelText: 'Price (${AppConstants.currencySymbol} / Month)'),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            FormBuilderValidators.min(1000),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'bedrooms',
                          initialValue: '1',
                          decoration: const InputDecoration(labelText: 'BedroomsCount'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'bathrooms',
                          initialValue: '1',
                          decoration: const InputDecoration(labelText: 'BathroomsCount'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderSwitch(
                          name: 'furnished',
                          title: const Text('Is Furnished'),
                          initialValue: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'whatsapp_number',
                          decoration: const InputDecoration(labelText: 'WhatsApp Contact', hintText: '+237...'),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'phone_number',
                          decoration: const InputDecoration(labelText: 'Direct Call Number', hintText: '677...'),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'description',
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description (EN/FR)', hintText: 'Enter description here...'),
                    validator: FormBuilderValidators.required(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // STEP 3 UI: LOCATION (MAP)
  Widget _buildStep3Location() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pin Location on Map',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select your listing location on OpenStreetMap relative to Molyko Junction.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // Simple Form Fields for Location Details
        FormBuilder(
          child: Column(
            children: [
              FormBuilderDropdown<String>(
                name: 'neighborhood',
                decoration: const InputDecoration(labelText: 'Select Neighborhood'),
                onChanged: (val) {
                  if (val != null) {
                    _formKey.currentState?.fields['neighborhood']?.didChange(val);
                  }
                },
                items: AppConstants.bueaNeighborhoods
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'location_name',
                decoration: const InputDecoration(labelText: 'Address Description', hintText: 'e.g. Opposite Chariot Hotel'),
                onChanged: (val) {
                  _formKey.currentState?.fields['location_name']?.didChange(val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Interactive Map
        Container(
          height: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLatLng,
                initialZoom: AppConstants.defaultZoom,
                onTap: (tapPosition, point) {
                  setState(() => _selectedLatLng = point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: AppConstants.osmTileUrl,
                  userAgentPackageName: 'com.awala.awala_mobile',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLatLng,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Selected Location: Latitude ${_selectedLatLng.latitude.toStringAsFixed(4)}, Longitude ${_selectedLatLng.longitude.toStringAsFixed(4)}',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // STEP 4 UI: AMENITIES
  Widget _buildStep4Amenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Amenities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select all features that apply to your property in Buea.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // Amenities Wrap Checklist
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppConstants.amenitiesList.map((amenity) {
            final isSelected = _selectedAmenities.contains(amenity);
            return FilterChip(
              label: Text(amenity),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedAmenities.add(amenity);
                  } else {
                    _selectedAmenities.remove(amenity);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
