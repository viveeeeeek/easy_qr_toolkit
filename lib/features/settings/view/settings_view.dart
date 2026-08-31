import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:easy_qr_toolkit/features/settings/view/widgets/about_app_section.dart';
import 'package:easy_qr_toolkit/features/settings/view/widgets/appearance_section.dart';
import 'package:material_ui/material_ui.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverAppBar.large(
            pinned: true,
            scrolledUnderElevation: 0,
            title: Text('Settings'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Appearance Section
                const AppearanceSection(),
                const SizedBox(height: 12),

                // 2. About App Section (Includes Developer Card)
                const AboutAppSection(),
                const SizedBox(height: 20),

                // 3. Privacy & Local Storage Badge Card
                M3ECard(
                  variant: M3ECardVariant.filled,
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 22,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '100% Offline & Private',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your scanned and generated QR data never leaves this device.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Subtle Footer
                Center(
                  child: Text(
                    'Crafted with Material 3 & Flutter',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
