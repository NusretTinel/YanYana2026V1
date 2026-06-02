import 'package:flutter/material.dart';

/// Centers community tab content on wide screens with a readable max width.
class CommunityResponsiveShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const CommunityResponsiveShell({
    super.key,
    required this.child,
    this.maxWidth = 760,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
