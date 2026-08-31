import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:easy_qr_toolkit/core/theme/theme_provider.dart';
import 'package:easy_qr_toolkit/features/settings/view/widgets/theme_swatch_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ThemeSettingsBottomSheet extends ConsumerWidget {
  const ThemeSettingsBottomSheet({super.key});

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
    // Provider is now synchronous and always returns a valid state
    final themeState = ref.watch(themeControllerProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Theme',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dynamic Color',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Use system wallpaper colors',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              M3ESwitch(
                value: themeState.isDynamic,
                selectedIcon: const Icon(Icons.check_rounded, size: 14),
                unselectedIcon: const Icon(Icons.close_rounded, size: 14),
                onChanged: (value) {
                  ref
                      .read(themeControllerProvider.notifier)
                      .toggleDynamicColor(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Theme Colors'),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _swatches.length,
              separatorBuilder: (c, i) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final color = _swatches[index];
                final isSelected = !themeState.isDynamic &&
                    themeState.seedColor.toARGB32() == color.toARGB32();

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
          const SizedBox(height: 24),
          const Text('Theme Mode'),
           const SizedBox(height: 12),
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
                 ref.read(themeControllerProvider.notifier).setThemeMode(mode);
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
           )
        ],
      ),
    );
  }


}
