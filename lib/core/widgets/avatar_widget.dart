import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// WhatsApp-style avatar widget that shows a gender-based illustration.
/// If the user has a profile image URL, it shows the image instead.
class UserAvatar extends StatelessWidget {
  final String? name;
  final String gender; // 'male', 'female', 'other'
  final String? imageUrl;
  final double size;
  final bool showBorder;
  final bool editable;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.name,
    this.gender = 'male',
    this.imageUrl,
    this.size = 60,
    this.showBorder = true,
    this.editable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _avatarGradient,
              border: showBorder
                  ? Border.all(color: AppColors.glassBorder, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withValues(alpha: 0.25),
                  blurRadius: size * 0.3,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildGenderAvatar(),
                    )
                  : _buildGenderAvatar(),
            ),
          ),
          if (editable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(size * 0.06),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: size * 0.15,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenderAvatar() {
    return CustomPaint(
      size: Size(size, size),
      painter: _AvatarPainter(gender: gender),
    );
  }

  LinearGradient get _avatarGradient {
    switch (gender) {
      case 'female':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE91E8C), Color(0xFFFF6FB5)],
        );
      case 'other':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
        );
      default: // male
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        );
    }
  }

  Color get _accentColor {
    switch (gender) {
      case 'female':
        return const Color(0xFFE91E8C);
      case 'other':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF1565C0);
    }
  }
}

/// Custom painter that draws a WhatsApp-style silhouette avatar.
class _AvatarPainter extends CustomPainter {
  final String gender;

  _AvatarPainter({required this.gender});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    if (gender == 'female') {
      _drawFemale(canvas, size, paint, cx, cy, r);
    } else {
      _drawMale(canvas, size, paint, cx, cy, r);
    }
  }

  void _drawMale(
      Canvas canvas, Size size, Paint paint, double cx, double cy, double r) {
    // Head
    final headR = r * 0.28;
    final headY = cy - r * 0.12;
    canvas.drawCircle(Offset(cx, headY), headR, paint);

    // Body/shoulders
    final bodyPath = Path();
    bodyPath.moveTo(cx - r * 0.45, cy + r * 0.7);
    bodyPath.quadraticBezierTo(cx - r * 0.45, cy + r * 0.25, cx, cy + r * 0.2);
    bodyPath.quadraticBezierTo(cx + r * 0.45, cy + r * 0.25, cx + r * 0.45, cy + r * 0.7);
    bodyPath.lineTo(cx + r * 0.6, cy + r * 0.95);
    bodyPath.lineTo(cx - r * 0.6, cy + r * 0.95);
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);
  }

  void _drawFemale(
      Canvas canvas, Size size, Paint paint, double cx, double cy, double r) {
    // Head
    final headR = r * 0.26;
    final headY = cy - r * 0.15;
    canvas.drawCircle(Offset(cx, headY), headR, paint);

    // Hair bumps (longer hair)
    final hairPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Left hair
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.2, headY - r * 0.05),
        width: r * 0.35,
        height: r * 0.55,
      ),
      hairPaint,
    );
    // Right hair
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + r * 0.2, headY - r * 0.05),
        width: r * 0.35,
        height: r * 0.55,
      ),
      hairPaint,
    );
    // Redraw head on top
    canvas.drawCircle(Offset(cx, headY), headR, paint);

    // Body - slightly narrower, more curved
    final bodyPath = Path();
    bodyPath.moveTo(cx - r * 0.38, cy + r * 0.7);
    bodyPath.quadraticBezierTo(
        cx - r * 0.35, cy + r * 0.22, cx, cy + r * 0.18);
    bodyPath.quadraticBezierTo(
        cx + r * 0.35, cy + r * 0.22, cx + r * 0.38, cy + r * 0.7);
    bodyPath.lineTo(cx + r * 0.55, cy + r * 0.95);
    bodyPath.lineTo(cx - r * 0.55, cy + r * 0.95);
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
