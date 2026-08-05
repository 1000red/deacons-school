import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomList extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool filled;
  final List<Widget>? children;
  final bool? isExpanded;

  const CustomList({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.filled = true,
    this.children,
    this.isExpanded,
  });

  @override
  State<CustomList> createState() => _CustomListState();
}

class _CustomListState extends State<CustomList> {
  bool _internalExpanded = false;

  bool get _isControlled => widget.isExpanded != null;

  bool get _expanded => _isControlled ? widget.isExpanded! : _internalExpanded;

  bool get _isExpandable =>
      widget.children != null && widget.children!.isNotEmpty;

  void _handleTap() {
    if (_isControlled) {
      widget.onTap?.call();
      return;
    }

    if (_isExpandable) {
      setState(() {
        _internalExpanded = !_internalExpanded;
      });
    } else {
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color titleColor =
        widget.filled ? Colors.white : AppColors.textPrimary;

    final Color subtitleColor = widget.filled
        ? Colors.white.withValues(alpha: 0.85)
        : AppColors.textSecondary;

    final Color iconColor = widget.filled ? Colors.white : widget.color;

    final Color iconBgColor = widget.filled
        ? Colors.white.withValues(alpha: 0.22)
        : widget.color.withValues(alpha: 0.12);

    final Color trailingColor = widget.filled
        ? Colors.white.withValues(alpha: 0.85)
        : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: widget.filled
                    ? LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          widget.color,
                          widget.color.withValues(alpha: 0.75),
                        ],
                      )
                    : null,
                color: widget.filled ? null : AppColors.card,
                border: widget.filled
                    ? null
                    : Border.all(
                        color: AppColors.border,
                      ),
                boxShadow: widget.filled
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.32),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (_isExpandable || _isControlled)
                    AnimatedRotation(
                      turns: _expanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.chevron_left,
                        color: trailingColor,
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_left,
                      color: trailingColor,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_isExpandable)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: widget.children!
                          .map(
                            (child) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: child,
                            ),
                          )
                          .toList(),
                    ),
                  )
                : const SizedBox(
                    width: double.infinity,
                    height: 0,
                  ),
          ),
      ],
    );
  }
}
