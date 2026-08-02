import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// بطاقة مشغّل صوت تجريبي (بدون ملف صوتي حقيقي) - تُحاكي تشغيل اللحن/التسبحة
/// بشريط تقدّم متحرك يوضّح شكل التفاعل المستهدف.
class AudioPlayerCard extends StatefulWidget {
  final String title;
  final String duration;
  final Color color;

  const AudioPlayerCard(
      {super.key,
      required this.title,
      required this.duration,
      required this.color});

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 8));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isAnimating) {
      _controller.stop();
    } else {
      if (_controller.isCompleted) _controller.reset();
      _controller.forward();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(color: widget.color, shape: BoxShape.circle),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Icon(
                  _controller.isAnimating ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _controller.value,
                      minHeight: 5,
                      backgroundColor: widget.color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(widget.color),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(widget.duration,
              style:
                  const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
