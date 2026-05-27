import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/os_empty_state.dart';
import '../../controllers/app_settings_controller.dart';
import '../../l10n/l10n_extension.dart';
import '../library/library_view.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _finishOnboarding() {
    ref.read(appSettingsProvider.notifier).setHasSeenOnboarding(true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LibraryView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            children: [
              _buildStep(
                icon: OpenshelfLogoIcon(size: 80, color: Theme.of(context).colorScheme.primary),
                title: context.l10n.onboardingWelcomeTitle,
                subtitle: context.l10n.onboardingWelcomeSub,
              ),
              _buildStep(
                iconData: Icons.bookmarks_outlined,
                title: context.l10n.onboardingOrganizeTitle,
                subtitle: context.l10n.onboardingOrganizeSub,
                color: Colors.purple,
              ),
              _buildStep(
                iconData: Icons.bar_chart_outlined,
                title: context.l10n.onboardingProgressTitle,
                subtitle: context.l10n.onboardingProgressSub,
                color: Colors.blue,
              ),
              _buildStep(
                iconData: Icons.qr_code_scanner,
                title: context.l10n.onboardingAddTitle,
                subtitle: context.l10n.onboardingAddSub,
                color: Colors.teal,
                isLast: true,
              ),
            ],
          ),
          // Dot indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => _buildDot(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    Widget? icon, 
    IconData? iconData, 
    required String title, 
    required String subtitle, 
    Color? color, 
    bool isLast = false,
  }) {
    return OsEmptyState(
      iconWidget: icon,
      icon: iconData,
      message: title,
      subtitle: subtitle,
      accentColor: color,
      actionLabel: isLast ? context.l10n.onboardingStart : context.l10n.onboardingNext,
      actionIcon: isLast ? Icons.check : Icons.arrow_forward_rounded,
      onActionPressed: () {
        if (isLast) {
          _finishOnboarding();
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400), 
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  Widget _buildDot(int index) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? (index == 0 ? theme.colorScheme.primary : 
               index == 1 ? Colors.purple :
               index == 2 ? Colors.blue : Colors.teal)
            : theme.colorScheme.onSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
