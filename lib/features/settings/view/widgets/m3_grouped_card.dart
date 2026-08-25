import 'package:flutter/material.dart';

enum M3GroupPosition { single, top, middle, bottom }

class M3GroupedCard extends StatelessWidget {
  final Widget child;
  final M3GroupPosition position;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;
  final double innerRadius;

  const M3GroupedCard({
    super.key,
    required this.child,
    this.position = M3GroupPosition.middle,
    this.onTap,
    this.padding,
    this.color,
    this.radius = 24.0,
    this.innerRadius = 4.0,
  });

  BorderRadius get _borderRadius {
    switch (position) {
      case M3GroupPosition.single:
        return BorderRadius.circular(radius);
      case M3GroupPosition.top:
        return BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(innerRadius),
          bottomRight: Radius.circular(innerRadius),
        );
      case M3GroupPosition.middle:
        return BorderRadius.circular(innerRadius);
      case M3GroupPosition.bottom:
        return BorderRadius.only(
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
          topLeft: Radius.circular(innerRadius),
          topRight: Radius.circular(innerRadius),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = color ?? colorScheme.surfaceContainer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Material(
        color: cardColor,
        borderRadius: _borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: _borderRadius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

class M3SectionHeader extends StatelessWidget {
  final String title;

  const M3SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
