import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;

  Future<void> _saveProfile() async {
    if (_formKey.currentState == null || !_formKey.currentState!.saveAndValidate()) {
      return;
    }

    setState(() => _isSaving = true);
    final formValues = _formKey.currentState!.value;

    try {
      final payload = {
        'name': formValues['name'],
        'phone': formValues['phone'],
        'preferred_language': formValues['preferred_language'],
      };

      final updatedUser = await ref.read(apiServiceProvider).updateProfile(payload);
      ref.read(authProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  'Account Settings',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update your profile details, contact information, and notifications.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Main settings forms
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 960;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Info Form
                    Expanded(
                      flex: isWide ? 2 : 0,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        child: FormBuilder(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Personal Information',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              const SizedBox(height: 24),

                              FormBuilderTextField(
                                name: 'email',
                                initialValue: user.email,
                                enabled: false,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  helperText: 'Email address cannot be changed.',
                                ),
                              ),
                              const SizedBox(height: 20),

                              FormBuilderTextField(
                                name: 'name',
                                initialValue: user.name,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.minLength(3),
                                ]),
                              ),
                              const SizedBox(height: 20),

                              FormBuilderTextField(
                                name: 'phone',
                                initialValue: user.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                              ),
                              const SizedBox(height: 20),

                              FormBuilderDropdown<String>(
                                name: 'preferred_language',
                                initialValue: user.preferredLanguage,
                                decoration: const InputDecoration(
                                  labelText: 'Preferred Language',
                                  prefixIcon: Icon(Icons.language_outlined),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'en', child: Text('English')),
                                  DropdownMenuItem(value: 'fr', child: Text('French')),
                                ],
                              ),
                              const SizedBox(height: 32),

                              SizedBox(
                                width: 180,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveProfile,
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text('Save Changes'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (isWide) const SizedBox(width: 24),
                    if (!isWide) const SizedBox(height: 24),

                    // Additional options card (Password reset simulation / Preferences)
                    Expanded(
                      flex: isWide ? 1 : 0,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Security & Password',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'To ensure security of your landlord account, choose a strong password.',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                const SizedBox(height: 24),
                                FormBuilderTextField(
                                  name: 'current_password',
                                  obscureText: true,
                                  decoration: const InputDecoration(labelText: 'Current Password'),
                                ),
                                const SizedBox(height: 16),
                                FormBuilderTextField(
                                  name: 'new_password',
                                  obscureText: true,
                                  decoration: const InputDecoration(labelText: 'New Password'),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Password updated successfully!'), backgroundColor: AppColors.success),
                                      );
                                    },
                                    child: const Text('Update Password'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
