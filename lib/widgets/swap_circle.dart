import 'package:flutter/material.dart';

class SwapCircle extends StatelessWidget {
  const SwapCircle({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.primaryContainer,
          border: Border.all(color: scheme.primary.withAlpha(89)),
        ),
        child: Icon(Icons.swap_horiz_rounded, color: scheme.onPrimaryContainer),
      ),
    );
  }
}
