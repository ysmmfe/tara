import 'package:flutter/material.dart';

class TaraPill extends StatelessWidget {
  const TaraPill({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  });

  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor ?? colors.tertiary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
