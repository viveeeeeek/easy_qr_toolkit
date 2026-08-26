import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:easy_qr_toolkit/core/theme/theme_provider.dart';
import 'package:easy_qr_toolkit/features/settings/view/widgets/theme_swatch_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  static const List<Color> _swatches = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.cyan,
    Colors.deepPurple,
    Colors.lightGreen,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
          child: Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        M3ECardList(
          itemCount: 3,
          gap: 3,
          color: colorScheme.surfaceContainerLow,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                // 1. Theme Mode
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.brightness_6_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Theme Mode',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: M3EButtonGroup(
                        type: M3EButtonGroupType.connected,
                        style: M3EButtonStyle.tonal,
                        selectedIndex: switch (themeState.themeMode) {
                          ThemeMode.system => 0,
                          ThemeMode.light => 1,
                          ThemeMode.dark => 2,
                        },
                        onSelectedIndexChanged: (index) {
                          if (index == null) return;
                          final mode = switch (index) {
                            0 => ThemeMode.system,
                            1 => ThemeMode.light,
                            _ => ThemeMode.dark,
                          };
                          ref
                              .read(themeControllerProvider.notifier)
                              .setThemeMode(mode);
                        },
                        actions: const [
                          M3EButtonGroupAction(
                            label: Text('System'),
                            icon: Icon(Icons.brightness_auto_rounded),
                          ),
                          M3EButtonGroupAction(
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode_rounded),
                          ),
                          M3EButtonGroupAction(
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              case 1:
                // 2. Dynamic Color
                return Row(
                  children: [
                    Icon(
                      Icons.palette_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dynamic Color',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'System wallpaper colors (Android 12+)',
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
                    M3ESwitch(
                      value: themeState.isDynamic,
                      selectedIcon:
                          const Icon(Icons.check_rounded, size: 14),
                      unselectedIcon:
                          const Icon(Icons.close_rounded, size: 14),
                      onChanged: (value) {
                        ref
                            .read(themeControllerProvider.notifier)
                            .toggleDynamicColor(value);
                      },
                    ),
                  ],
                );
              case 2:
              default:
                // 3. Custom Theme Colors
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.color_lens_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Custom Theme Colors',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                themeState.isDynamic
                                    ? 'Tap a color below to use a custom accent'
                                    : 'Select an accent color for the app',
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
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 56,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _swatches.length,
                        separatorBuilder: (c, i) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final color = _swatches[index];
                          final isSelected = !themeState.isDynamic &&
                              themeState.seedColor.toARGB32() ==
                                  color.toARGB32();

                          return ThemeSwatchPreview(
                            seedColor: color,
                            isSelected: isSelected,
                            onTap: () {
                              ref
                                  .read(themeControllerProvider.notifier)
                                  .setSeedColor(color);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
            }
          },
        ),
      ],
    );
  }
}
