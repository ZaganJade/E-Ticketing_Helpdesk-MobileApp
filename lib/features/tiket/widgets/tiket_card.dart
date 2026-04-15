import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../models/tiket_model.dart';

/// Modern Tiket Card Widget - Stylish and Interactive Design
/// Features: glassmorphism effect, animated interactions, modern typography
class TiketCard extends StatefulWidget {
  final TiketModel tiket;
  final VoidCallback? onTap;

  const TiketCard({
    super.key,
    required this.tiket,
    this.onTap,
  });

  @override
  State<TiketCard> createState() => _TiketCardState();
}

class _TiketCardState extends State<TiketCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    setState(() => _isHovered = true);
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    setState(() => _isHovered = false);
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _isHovered = false);
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return const Color(0xFFEF4444); // Red
      case 'DIPROSES':
        return const Color(0xFF3B82F6); // Blue
      case 'SELESAI':
        return const Color(0xFF10B981); // Green
      default:
        return const Color(0xFF64748B); // Gray
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return const Color(0xFFFEE2E2); // Red light
      case 'DIPROSES':
        return const Color(0xFFDBEAFE); // Blue light
      case 'SELESAI':
        return const Color(0xFFD1FAE5); // Green light
      default:
        return const Color(0xFFF1F5F9); // Gray light
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return LucideIcons.circle;
      case 'DIPROSES':
        return LucideIcons.loader;
      case 'SELESAI':
        return LucideIcons.check;
      default:
        return Icons.help_outline;
    }
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}b';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}h';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}j';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'Baru';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final statusColor = _getStatusColor(widget.tiket.status);
    final statusBgColor = _getStatusBgColor(widget.tiket.status);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered
                      ? statusColor.withOpacity(0.5)
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  width: _isHovered ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(_isHovered ? 0.15 : 0.08),
                    blurRadius: _isHovered ? 20 : 12,
                    offset: const Offset(0, 4),
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // Top accent bar with status color
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor,
                            statusColor.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Main content
                    Padding(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: ID Badge + Status + Time
                          Row(
                            children: [
                              // ID Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 10 : 8,
                                  vertical: isTablet ? 6 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#${widget.tiket.id.substring(0, widget.tiket.id.length > 6 ? 6 : widget.tiket.id.length).toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 11,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Status Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 12 : 10,
                                  vertical: isTablet ? 8 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? statusColor.withOpacity(0.15)
                                      : statusBgColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStatusIcon(widget.tiket.status),
                                      size: isTablet ? 16 : 14,
                                      color: statusColor,
                                    ),
                                    SizedBox(width: isTablet ? 8 : 6),
                                    Text(
                                      widget.tiket.statusLabel,
                                      style: TextStyle(
                                        fontSize: isTablet ? 13 : 12,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 16 : 14),
                          // Title
                          Text(
                            widget.tiket.judul,
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              letterSpacing: -0.3,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isTablet ? 10 : 8),
                          // Description
                          Text(
                            widget.tiket.deskripsi,
                            style: TextStyle(
                              fontSize: isTablet ? 15 : 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isTablet ? 20 : 16),
                          // Footer with user info and date
                          Container(
                            padding: EdgeInsets.all(isTablet ? 14 : 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF334155).withOpacity(0.5)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF475569)
                                    : const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Creator info
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: isTablet ? 36 : 32,
                                        height: isTablet ? 36 : 32,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF0EA5E9),
                                              const Color(0xFF0284C7),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          LucideIcons.user,
                                          size: isTablet ? 18 : 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: isTablet ? 12 : 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Dibuat oleh',
                                              style: TextStyle(
                                                fontSize: isTablet ? 12 : 11,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF94A3B8),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              widget.tiket.pembuatNama ?? 'Unknown',
                                              style: TextStyle(
                                                fontSize: isTablet ? 14 : 13,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF1E293B),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Divider
                                Container(
                                  width: 1,
                                  height: isTablet ? 40 : 36,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 16 : 12,
                                  ),
                                  color: isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFFE2E8F0),
                                ),
                                // Date info
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          LucideIcons.calendar,
                                          size: isTablet ? 14 : 12,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                        SizedBox(width: isTablet ? 6 : 4),
                                        Text(
                                          _formatDate(widget.tiket.dibuatPada),
                                          style: TextStyle(
                                            fontSize: isTablet ? 13 : 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getRelativeTime(widget.tiket.dibuatPada),
                                      style: TextStyle(
                                        fontSize: isTablet ? 12 : 11,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Assigned to (if any)
                          if (widget.tiket.penanggungJawabNama != null) ...[
                            SizedBox(height: isTablet ? 14 : 12),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 14 : 12,
                                vertical: isTablet ? 10 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF0EA5E9).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.headphones,
                                    size: isTablet ? 16 : 14,
                                    color: const Color(0xFF0EA5E9),
                                  ),
                                  SizedBox(width: isTablet ? 8 : 6),
                                  Text(
                                    'Penanggung Jawab: ',
                                    style: TextStyle(
                                      fontSize: isTablet ? 13 : 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    widget.tiket.penanggungJawabNama!,
                                    style: TextStyle(
                                      fontSize: isTablet ? 13 : 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0EA5E9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Bottom action hint
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                        vertical: isTablet ? 12 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155).withOpacity(0.5)
                            : const Color(0xFFF8FAFC),
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ketuk untuk melihat detail',
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          SizedBox(width: isTablet ? 8 : 6),
                          Icon(
                            LucideIcons.chevronRight,
                            size: isTablet ? 18 : 16,
                            color: const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact Tiket Card - For list views with limited space
class TiketCardCompact extends StatefulWidget {
  final TiketModel tiket;
  final VoidCallback? onTap;

  const TiketCardCompact({
    super.key,
    required this.tiket,
    this.onTap,
  });

  @override
  State<TiketCardCompact> createState() => _TiketCardCompactState();
}

class _TiketCardCompactState extends State<TiketCardCompact> {
  bool _isPressed = false;

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return const Color(0xFFEF4444);
      case 'DIPROSES':
        return const Color(0xFF3B82F6);
      case 'SELESAI':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return LucideIcons.circle;
      case 'DIPROSES':
        return LucideIcons.loader;
      case 'SELESAI':
        return LucideIcons.check;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final statusColor = _getStatusColor(widget.tiket.status);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(bottom: isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isPressed
                ? statusColor.withOpacity(0.5)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: _isPressed ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(_isPressed ? 0.1 : 0.05),
              blurRadius: _isPressed ? 16 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left status indicator
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 16 : 14),
                  child: Row(
                    children: [
                      // Status icon
                      Container(
                        width: isTablet ? 44 : 40,
                        height: isTablet ? 44 : 40,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getStatusIcon(widget.tiket.status),
                          size: isTablet ? 22 : 20,
                          color: statusColor,
                        ),
                      ),
                      SizedBox(width: isTablet ? 16 : 14),
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tiket.judul,
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 15,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  widget.tiket.statusLabel,
                                  style: TextStyle(
                                    fontSize: isTablet ? 13 : 12,
                                    fontWeight: FontWeight.w500,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFCBD5E1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  LucideIcons.user,
                                  size: isTablet ? 13 : 12,
                                  color: const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.tiket.pembuatNama ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: isTablet ? 13 : 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Arrow
                      Icon(
                        LucideIcons.chevronRight,
                        size: isTablet ? 22 : 20,
                        color: const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton loading for TiketCard
class TiketCardSkeleton extends StatelessWidget {
  final bool compact;

  const TiketCardSkeleton({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    if (compact) {
      return Container(
        margin: EdgeInsets.only(bottom: isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 16 : 14),
                  child: Row(
                    children: [
                      Container(
                        width: isTablet ? 44 : 40,
                        height: isTablet ? 44 : 40,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(width: isTablet ? 16 : 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: isTablet ? 18 : 16,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: isTablet ? 150 : 120,
                              height: isTablet ? 14 : 12,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              height: 4,
              color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
            ),
            Padding(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: isTablet ? 70 : 60,
                        height: isTablet ? 28 : 24,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: isTablet ? 90 : 80,
                        height: isTablet ? 32 : 28,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 16 : 14),
                  Container(
                    width: double.infinity,
                    height: isTablet ? 24 : 22,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: isTablet ? 250 : 200,
                    height: isTablet ? 20 : 18,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 16),
                  Container(
                    height: isTablet ? 70 : 64,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status badge widget
class TiketStatusBadge extends StatelessWidget {
  final String status;
  final bool isLarge;

  const TiketStatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return const Color(0xFFEF4444);
      case 'DIPROSES':
        return const Color(0xFF3B82F6);
      case 'SELESAI':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return const Color(0xFFFEE2E2);
      case 'DIPROSES':
        return const Color(0xFFDBEAFE);
      case 'SELESAI':
        return const Color(0xFFD1FAE5);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return LucideIcons.circle;
      case 'DIPROSES':
        return LucideIcons.loader;
      case 'SELESAI':
        return LucideIcons.check;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return 'Terbuka';
      case 'DIPROSES':
        return 'Diproses';
      case 'SELESAI':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final statusColor = _getStatusColor(status);
    final statusBgColor = _getStatusBgColor(status);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? (isTablet ? 14 : 12) : (isTablet ? 12 : 10),
        vertical: isLarge ? (isTablet ? 10 : 8) : (isTablet ? 8 : 6),
      ),
      decoration: BoxDecoration(
        color: isDark ? statusColor.withOpacity(0.15) : statusBgColor,
        borderRadius: BorderRadius.circular(isLarge ? 20 : 8),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: isLarge ? (isTablet ? 18 : 16) : (isTablet ? 16 : 14),
            color: statusColor,
          ),
          SizedBox(width: isLarge ? (isTablet ? 10 : 8) : (isTablet ? 8 : 6)),
          Text(
            _getStatusLabel(status),
            style: TextStyle(
              fontSize: isLarge ? (isTablet ? 15 : 14) : (isTablet ? 13 : 12),
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
