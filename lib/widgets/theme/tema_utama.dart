import 'package:flutter/material.dart';

class AuthBackgroundCore extends StatelessWidget {
  final Widget child;

  const AuthBackgroundCore({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C5F2D),
            Color(0xFF4A7C59),
            Color(0xFF6B8E23),
            Color(0xFF8FBC8F),
          ],
        ),
      ),
      child: SafeArea(child: child),
      // child: child,
    );
  }
}

class TemaUtama extends AuthBackgroundCore {
  const TemaUtama({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);
}
