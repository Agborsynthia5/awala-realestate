import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:awala_mobile/core/theme/app_theme.dart';
import 'package:awala_mobile/core/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  final String role;
  const OnboardingScreen({super.key, this.role = 'searcher'});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _isLast = false;

  List<_OnboardingPage> get _pages => widget.role == 'landlord'
      ? _landlordPages
      : _searcherPages;

  static const _searcherPages = [
    _OnboardingPage(
      icon: Icons.search_rounded,
      title: 'Find Rooms Fast',
      subtitle:
          'Search hundreds of verified rooms, studios and apartments in Buea in seconds.',
      color: AppColors.accent,
    ),
    _OnboardingPage(
      icon: Icons.map_rounded,
      title: 'See on the Map',
      subtitle:
          'View all listings on a live map. Know exactly how far each property is from Molyko Junction.',
      color: AppColors.primary,
    ),
    _OnboardingPage(
      icon: Icons.notifications_active_rounded,
      title: 'Get Instant Alerts',
      subtitle:
          'Save your search and get notified the moment a matching property is listed.',
      color: AppColors.cta,
    ),
  ];

  static const _landlordPages = [
    _OnboardingPage(
      icon: Icons.add_home_rounded,
      title: 'List Your Property',
      subtitle:
          'Add your rooms and apartments to reach thousands of students and young professionals in Buea.',
      color: AppColors.accent,
    ),
    _OnboardingPage(
      icon: Icons.verified_rounded,
      title: 'Get Verified',
      subtitle:
          'Earn a trusted badge by verifying your identity. Verified listings get 3× more views.',
      color: AppColors.primary,
    ),
    _OnboardingPage(
      icon: Icons.bar_chart_rounded,
      title: 'Manage Listings',
      subtitle:
          'Use the Awala web dashboard to manage all your listings, track views, and respond to inquiries.',
      color: AppColors.cta,
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _isLast = page == _pages.length - 1;
    });
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPageView(page: page);
                },
              ),
            ),

            // Indicator & Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.border,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLast
                          ? _finish
                          : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut),
                      child: Text(_isLast ? 'Get Started' : 'Next'),
                    ),
                  ),
                  if (!_isLast) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Already have an account? Login',
                          style: TextStyle(color: AppColors.textSecondary,
                              fontSize: 13)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _OnboardingPage(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color});
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 72, color: page.color),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
