import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/cpl_system/cubit/cpl_system_cubit.dart';
import '../../features/cpl_system/models/cpl_models.dart';

class CplUserAvatar extends StatelessWidget {
  final UserSession user;
  final double size;
  final double borderRadius;
  final bool showOnlineDot;
  final bool showCplBadge;
  final VoidCallback? onTap;

  const CplUserAvatar({
    super.key,
    required this.user,
    this.size = 64,
    this.borderRadius = 16,
    this.showOnlineDot = true,
    this.showCplBadge = true,
    this.onTap,
  });

  static String computeInitials(String name) {
    final clean = name
        .replaceAll(RegExp(r'^(Engr\.|Dr\.|Mr\.|Ms\.|Mrs\.)\s*', caseSensitive: false), '')
        .trim();
    final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'CP';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Uint8List? _decodeDataUri(String uri) {
    try {
      final commaIdx = uri.indexOf(',');
      if (commaIdx == -1) return null;
      return base64Decode(uri.substring(commaIdx + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = computeInitials(user.name);
    final rawUrl = user.profileImageUrl;
    String? resolvedUrl;
    try {
      resolvedUrl = context.read<CplSystemCubit>().resolveMediaUrl(rawUrl);
    } catch (_) {
      resolvedUrl = rawUrl;
    }

    Widget fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: (size * 0.34).clamp(11.0, 32.0),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              height: 1.0,
            ),
          ),
          if (showCplBadge && size >= 44) ...[
            const SizedBox(height: 2),
            Text(
              'CPL',
              style: TextStyle(
                color: const Color(0xFFFFEDD5),
                fontSize: (size * 0.13).clamp(7.5, 11.0),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ],
      ),
    );

    Widget avatarContent = fallback;
    if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
      if (resolvedUrl.startsWith('data:image')) {
        final bytes = _decodeDataUri(resolvedUrl);
        if (bytes != null) {
          avatarContent = ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            ),
          );
        }
      } else {
        avatarContent = ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            resolvedUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          ),
        );
      }
    }

    Widget box = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withAlpha((0.28 * 255).round()),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B1628).withAlpha((0.28 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: avatarContent,
        ),
        if (showOnlineDot)
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              width: (size * 0.25).clamp(11.0, 18.0),
              height: (size * 0.25).clamp(11.0, 18.0),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0B1628), width: 2.2),
              ),
            ),
          ),
      ],
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: box),
      );
    }
    return box;
  }
}
