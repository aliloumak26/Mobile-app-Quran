import 'package:flutter/material.dart';

class PersistentPlayerWrapper extends StatelessWidget {
  final Widget child;
  const PersistentPlayerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
