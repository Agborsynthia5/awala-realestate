import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '../../../core/theme/app_theme.dart';

class InquiryItem {
  final String id;
  final String studentName;
  final String propertyTitle;
  final String message;
  final String phone;
  final DateTime date;
  bool isReplied;

  InquiryItem({
    required this.id,
    required this.studentName,
    required this.propertyTitle,
    required this.message,
    required this.phone,
    required this.date,
    this.isReplied = false,
  });
}

class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({super.key});

  @override
  State<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  final List<InquiryItem> _inquiries = [
    InquiryItem(
      id: '1',
      studentName: 'Brenda Ateh',
      propertyTitle: 'Modern Studio near UB Junction',
      message: 'Hello, is water flowing constantly at the property? I would like to schedule a visit.',
      phone: '+237675849301',
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    InquiryItem(
      id: '2',
      studentName: 'Junior Fonge',
      propertyTitle: 'Single Room - Bonduma',
      message: 'Is the room furnished as shown in the pictures, or is it empty?',
      phone: '+237651094852',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    InquiryItem(
      id: '3',
      studentName: 'Amadu Bello',
      propertyTitle: '2 Bedroom Apartment - GRA',
      message: 'Can I pay a 6-month deposit instead of the requested 1-year deposit?',
      phone: '+237699023410',
      date: DateTime.now().subtract(const Duration(days: 2)),
      isReplied: true,
    ),
    InquiryItem(
      id: '4',
      studentName: 'Clarisse Ngala',
      propertyTitle: 'Modern Studio near UB Junction',
      message: 'Is there prepaid electricity meter for this room?',
      phone: '+237677112233',
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  void _openWhatsApp(String phone, String message) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final url = 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}';
    web.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Inquiries',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Messages and contact requests from searchers regarding your listings.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Inquiries List
            Expanded(
              child: ListView.separated(
                itemCount: _inquiries.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final inquiry = _inquiries[index];
                  return Card(
                    elevation: inquiry.isReplied ? 1 : 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: inquiry.isReplied ? Colors.transparent : AppColors.accent.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    child: Text(
                                      inquiry.studentName[0],
                                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        inquiry.studentName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Inquired about: ${inquiry.propertyTitle}',
                                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: inquiry.isReplied ? AppColors.success.withValues(alpha: 0.1) : AppColors.cta.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  inquiry.isReplied ? 'Replied' : 'New',
                                  style: TextStyle(
                                    color: inquiry.isReplied ? AppColors.success : AppColors.cta,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(),
                          ),
                          Text(
                            inquiry.message,
                            style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Received: ${_formatDate(inquiry.date)}',
                                style: TextStyle(color: AppColors.textHint, fontSize: 12),
                              ),
                              Row(
                                children: [
                                  if (!inquiry.isReplied)
                                    TextButton(
                                      onPressed: () {
                                        setState(() => inquiry.isReplied = true);
                                      },
                                      child: const Text('Mark as Replied'),
                                    ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() => inquiry.isReplied = true);
                                      _openWhatsApp(
                                        inquiry.phone,
                                        'Hello ${inquiry.studentName}, responding to your inquiry on Awala about "${inquiry.propertyTitle}":',
                                      );
                                    },
                                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                    label: const Text('Reply on WhatsApp'),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      if (difference.inHours == 0) {
        return 'Just now';
      }
      return '${difference.inHours} hours ago';
    }
    return '${difference.inDays} days ago';
  }
}
