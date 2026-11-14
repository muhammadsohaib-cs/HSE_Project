import 'package:flutter/material.dart';
import '../theme/cpl_theme.dart';

enum CplLogoSize { small, medium, large }

class CplBrandLogo extends StatelessWidget {
  final double? height;
  final bool showSubtitle;
  final bool isDark;
  final VoidCallback? onTap;

  const CplBrandLogo({
    super.key,
    this.height,
    this.showSubtitle = true,
    this.isDark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final logoH = height ?? 36.0;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Official CPL Brand Logo Container with Vector Fallback
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.12 * 255).round()),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/cpl_logo.png',
            height: logoH,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildVectorEmblem(logoH),
          ),
        ),

        if (showSubtitle) ...[
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CHINIOT ',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w900,
                      fontSize: (logoH * 0.42).clamp(11.0, 16.0),
                      letterSpacing: 0.8,
                      color: isDark ? Colors.white : CplColors.renewableGreen,
                    ),
                  ),
                  Text(
                    'POWER',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w900,
                      fontSize: (logoH * 0.42).clamp(11.0, 16.0),
                      letterSpacing: 0.8,
                      color: CplColors.energyAmber,
                    ),
                  ),
                ],
              ),
              Text(
                '62.4 MW CO-GEN • HSE SYSTEM',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: (logoH * 0.26).clamp(8.5, 10.5),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: isDark ? CplColors.slate300 : CplColors.slate600,
                ),
              ),
            ],
          ),
        ],
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
  }

  Widget _buildVectorEmblem(double h) {
    return Container(
      width: h,
      height: h,
      decoration: BoxDecoration(
        color: CplColors.corporateNavy,
        borderRadius: BorderRadius.circular(h * 0.22),
        border: Border.all(color: CplColors.energyAmber, width: 1.5),
      ),
      child: Center(
        child: Icon(
          Icons.energy_savings_leaf,
          size: h * 0.62,
          color: CplColors.renewableGreen,
        ),
      ),
    );
  }
}

