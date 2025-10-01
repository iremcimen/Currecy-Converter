import 'package:flutter/material.dart';

class CodeBadge extends StatelessWidget {
  const CodeBadge({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 16,
      backgroundColor: scheme.secondaryContainer,
      child: Text(
        code.substring(0, 2),
        style: TextStyle(
          color: scheme.surfaceTint,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
