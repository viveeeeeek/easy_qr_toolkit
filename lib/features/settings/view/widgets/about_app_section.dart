import 'package:easy_qr_toolkit/core/constants/app_constants.dart';
import 'package:easy_qr_toolkit/core/providers/package_info_provider.dart';
import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class AboutAppSection extends ConsumerWidget {
  const AboutAppSection({super.key});

  Future<void> _launchLink(BuildContext context, String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $urlString'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final packageInfo = ref.watch(packageInfoProvider);
    final versionText = packageInfo.buildNumber.isNotEmpty
        ? 'v${packageInfo.version} (${packageInfo.buildNumber})'
        : 'v${packageInfo.version}';
    final fullVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
          child: Text(
            'About App',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
        ),

        // 1. App Header Hero Card
        M3ECard(
          variant: M3ECardVariant.filled,
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _M3EIconContainer(
                polygon: MaterialShapes.cookie9Sided,
                backgroundColor: colorScheme.primaryContainer,
                size: 52,
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 30,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            AppConstants.appName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (versionText.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              versionText,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Fast, clean & Material You QR toolkit',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 2. Action Links Card List
        M3ECardList(
          itemCount: 4,
          gap: 3,
          color: colorScheme.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          onTap: (index) {
            switch (index) {
              case 0:
                _launchLink(context, AppConstants.playStoreUrl);
              case 1:
                Share.share(
                  'Generate and scan QR codes with Material You styling on Easy QR Toolkit!\n${AppConstants.playStoreUrl}',
                  subject: 'Easy QR Toolkit App',
                );
              case 2:
                _launchLink(context, AppConstants.projectRepoUrl);
              case 3:
                showLicensePage(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion:
                      fullVersion.isNotEmpty ? fullVersion : null,
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _M3EIconContainer(
                      polygon: MaterialShapes.cookie9Sided,
                      backgroundColor: colorScheme.primaryContainer,
                      size: 56,
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 34,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                );
            }
          },
          itemBuilder: (context, index) {
            final (icon, title) = switch (index) {
              0 => (Icons.star_rounded, 'Rate on Google Play'),
              1 => (Icons.share_rounded, 'Share App'),
              2 => (Icons.code_rounded, 'Source Code'),
              3 => (Icons.article_rounded, 'Open Source Licenses'),
              _ => (Icons.info_rounded, ''),
            };

            return Row(
              children: [
                Icon(
                  icon,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _M3EIconContainer extends StatelessWidget {
  final RoundedPolygon polygon;
  final Widget child;
  final Color backgroundColor;
  final double size;

  const _M3EIconContainer({
    required this.polygon,
    required this.child,
    required this.backgroundColor,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _M3EShapePainter(
              polygon: polygon,
              color: backgroundColor,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _M3EShapePainter extends CustomPainter {
  final RoundedPolygon polygon;
  final Color color;

  const _M3EShapePainter({
    required this.polygon,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = polygon.toPath();
    final matrix = Matrix4.identity()
      ..scaleByVector3(Vector3(size.width, size.height, 1.0));
    final scaledPath = path.transform(matrix.storage);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(scaledPath, paint);
  }

  @override
  bool shouldRepaint(covariant _M3EShapePainter oldDelegate) {
    return oldDelegate.polygon != polygon || oldDelegate.color != color;
  }
}
