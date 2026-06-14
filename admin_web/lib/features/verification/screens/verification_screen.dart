import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/cloudinary_service.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  String? _nicUrl;
  String? _selfieUrl;
  bool _isUploadingNIC = false;
  bool _isUploadingSelfie = false;
  bool _isSubmitting = false;
  bool _submitted = false;

  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<void> _uploadDocument(bool isNIC) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() {
      if (isNIC) {
        _isUploadingNIC = true;
      } else {
        _isUploadingSelfie = true;
      }
    });

    try {
      final url = await _cloudinaryService.uploadImage(file);
      setState(() {
        if (isNIC) {
          _nicUrl = url;
          _isUploadingNIC = false;
        } else {
          _selfieUrl = url;
          _isUploadingSelfie = false;
        }
      });
    } catch (e) {
      setState(() {
        if (isNIC) {
          _isUploadingNIC = false;
        } else {
          _isUploadingSelfie = false;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload document: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _submitVerification() async {
    if (_nicUrl == null || _selfieUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both your National ID Card and Selfie.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate API review submission
    setState(() {
      _isSubmitting = false;
      _submitted = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification documents submitted. Our admin team will review it within 24 hours.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isVerified = user?.isVerified ?? false;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verification Request',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Submit documents to verify your identity and get the "Trusted Landlord" badge.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Status Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isVerified
                    ? AppColors.success.withValues(alpha: 0.1)
                    : (_submitted ? Colors.blue.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isVerified
                      ? AppColors.success.withValues(alpha: 0.3)
                      : (_submitted ? Colors.blue.withValues(alpha: 0.3) : AppColors.warning.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isVerified ? Icons.verified : (_submitted ? Icons.info_outline : Icons.warning_amber_rounded),
                    color: isVerified ? AppColors.success : (_submitted ? Colors.blue : AppColors.warning),
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVerified
                              ? 'Your Account is Verified'
                              : (_submitted ? 'Verification Review Pending' : 'Account Verification Required'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isVerified ? AppColors.success : (_submitted ? Colors.blue : AppColors.warning),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isVerified
                              ? 'Your properties will rank higher and show a "Trusted Badge" label to students in Buea.'
                              : (_submitted
                                  ? 'We are reviewing your ID and selfie. This usually takes less than 24 hours.'
                                  : 'Please upload a clear scan of your National Identity Card and a selfie holding the ID.'),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (!isVerified && !_submitted) ...[
              // Upload Section
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 768;
                  return Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    children: [
                      Expanded(
                        flex: isWide ? 1 : 0,
                        child: _UploadCard(
                          title: 'National ID Card (Front/Back)',
                          description: 'Provide a clear JPEG/PNG image of your National ID or Passport.',
                          url: _nicUrl,
                          isUploading: _isUploadingNIC,
                          onTap: () => _uploadDocument(true),
                        ),
                      ),
                      if (isWide) const SizedBox(width: 24),
                      if (!isWide) const SizedBox(height: 24),
                      Expanded(
                        flex: isWide ? 1 : 0,
                        child: _UploadCard(
                          title: 'Selfie holding ID Card',
                          description: 'Hold your ID next to your face. Make sure all details are readable.',
                          url: _selfieUrl,
                          isUploading: _isUploadingSelfie,
                          onTap: () => _uploadDocument(false),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),

              // Submit Button
              Center(
                child: SizedBox(
                  width: 280,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitVerification,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Verification Documents'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String title;
  final String description;
  final String? url;
  final bool isUploading;
  final VoidCallback onTap;

  const _UploadCard({
    required this.title,
    required this.description,
    this.url,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(description, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 24),
          if (isUploading)
            const CircularProgressIndicator()
          else if (url != null)
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(url!, height: 100, width: 150, fit: BoxFit.cover),
                ),
                Positioned(
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Change File', style: TextStyle(fontSize: 12)),
                  ),
                )
              ],
            )
          else
            OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Choose Image'),
            ),
        ],
      ),
    );
  }
}
