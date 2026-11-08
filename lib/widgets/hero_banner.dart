import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
class HeroBanner extends StatelessWidget implements PreferredSizeWidget {
  const HeroBanner({
    super.key,
    required this.text,
    this.additionalText,
    this.height = 260,
    this.bottom,
    this.onBack,
    this.showBack = false,
  });

  const HeroBanner.compact({
    super.key,
    required this.text,
    this.additionalText,
    this.bottom,
    this.onBack,
    this.showBack = false,
  }) : height = 140;

  final String text;
  final String? additionalText;
  final double height;
  final Widget? bottom;
  final VoidCallback? onBack;

  final bool showBack;

  bool get _compact => height < 200;
  @override
  Size get preferredSize {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final statusBar = view.padding.top / view.devicePixelRatio;
    return Size.fromHeight(height + statusBar);
  }
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final width = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: height + top,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgroungHero.png',
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            cacheWidth: 900,
          ),
          ClipPath(
            clipper: _DiagonalClipper(
              topX: _compact ? 0.84 : 0.90,
              bottomX: _compact ? 0.66 : 0.50,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.orange.withValues(alpha: 0.80),
                    const Color(0xFFF4620F).withValues(alpha: 0.70),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, top + 16, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (onBack != null)
                      GestureDetector(
                        onTap: onBack,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.arrow_back_rounded,
                              color: AppTheme.white),
                        ),
                      ),
                    const Icon(Icons.bar_chart_rounded,
                        color: AppTheme.white, size: 30),
                    const SizedBox(width: 8),
                    const Text(
                      'CargoFlow',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _compact ? 12 : 40),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: width * 0.62),
                  child: Text(
                    text.toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: _compact ? 22 : 32,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (additionalText != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    additionalText!,
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: _compact ? 13 : 16,
                    ),
                  ),
                ],
                if (bottom != null) ...[const Spacer(), bottom!],
              ],
            ),
          ),
          // if (showBack)
          //   Positioned(
          //     left: 4,
          //     top: top,
          //     child: IconButton(
          //       icon: const Icon(Icons.arrow_back, color: Colors.white),
          //       onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  const _DiagonalClipper({required this.topX, required this.bottomX});

  final double topX;
  final double bottomX;

  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width * topX, 0)
    ..lineTo(size.width * bottomX, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant _DiagonalClipper old) =>
      old.topX != topX || old.bottomX != bottomX;
}