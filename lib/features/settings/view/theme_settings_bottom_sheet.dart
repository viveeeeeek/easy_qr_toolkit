import 'package:easy_qr_toolkit/features/settings/view/widgets/theme_swatch_preview.dart';
import 'package:easy_qr_toolkit/core/theme/theme_provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          SwitchListTile(
            title: const Text('Dynamic Color'),
            subtitle: const Text('Use system wallpaper colors'),
            value: themeState.isDynamic,
            onChanged: (value) {
              ref.read(themeControllerProvider.notifier).toggleDynamicColor(value);
            },
            contentPadding: EdgeInsets.zero,
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
                // If dynamic is enabled, we still show selection but maybe dim it? 
                // Or user selecting a color automatically disables dynamic (handled in provider).
                // Here we check if selected.
                final isSelected = !themeState.isDynamic && themeState.seedColor.value == color.value;

                return ThemeSwatchPreview(
                  seedColor: color,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(themeControllerProvider.notifier).setSeedColor(color);
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
             child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
                ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
              ],
              selected: {themeState.themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                 ref.read(themeControllerProvider.notifier).setThemeMode(newSelection.first);
              },
             ),
           )
        ],
      ),
    );
  }


}
