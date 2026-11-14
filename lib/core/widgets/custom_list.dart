import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

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

    final Color subtitleColor =
        widget.filled ? Colors.white : AppColors.textSecondary;

    final Color iconColor = widget.filled ? Colors.white : widget.color;

    final Color iconBgColor = widget.filled
        ? Colors.white.withValues(alpha: 0.22)
        : widget.color.withValues(alpha: 0.12);

    final Color trailingColor = widget.filled
        ? Colors.white.withValues(alpha: 0.9)
        : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.card),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                gradient: widget.filled
                    ? LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          widget.color,
                          // ختام التدرّج غامق كفاية إن النص الأبيض يفضل مقروء
                          // (4.6:1 على الأقل) بدل التدرّج الفاتح القديم.
                          widget.color.withValues(alpha: 0.95),
                        ],
                      )
                    : null,
                color: widget.filled ? null : AppColors.card,
                border: widget.filled
                    ? null
                    : const Border.fromBorderSide(
                        BorderSide(color: AppColors.border),
                      ),
                boxShadow:
                    widget.filled ? AppShadow.accent(widget.color) : AppShadow.card,
              ),
              child: Row(
                children: [
                  Container(
                    width: AppSizes.listIcon,
                    height: AppSizes.listIcon,
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
                  const SizedBox(width: AppSpacing.iconGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: AppTypography.rowTitle.copyWith(
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: AppSpacing.stack),
                          Text(
                            widget.subtitle!,
                            style: AppTypography.caption.copyWith(
                              color: subtitleColor,
                              fontWeight: FontWeight.w500,
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
                    padding: const EdgeInsets.only(top: AppSpacing.gap),
                    child: Column(
                      children: widget.children!
                          .map(
                            (child) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.gap),
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
