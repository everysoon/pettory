import 'package:flutter/material.dart';

import '../theme.dart';

/// A small dark tooltip bubble hinting that the card below can be swiped.
class SwipeHintBubble extends StatelessWidget {
  const SwipeHintBubble({super.key, this.text = '왼쪽으로 밀면 삭제할 수 있어요'});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Wraps a card + its swipe-to-delete background and, once, nudges the card
/// left (peeking the red background behind it) and back to demonstrate that
/// it's swipeable — without blocking the rest of the screen. Calls
/// [onFinished] once the demo completes so the caller can swap back to a
/// real [Dismissible].
class SwipeHintCard extends StatefulWidget {
  const SwipeHintCard({
    super.key,
    required this.background,
    required this.child,
    required this.onFinished,
  });

  final Widget background;
  final Widget child;
  final VoidCallback onFinished;

  @override
  State<SwipeHintCard> createState() => _SwipeHintCardState();
}

class _SwipeHintCardState extends State<SwipeHintCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _offset = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 15),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -56.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(tween: ConstantTween(-56.0), weight: 25),
      TweenSequenceItem(
        tween: Tween(
          begin: -56.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 15),
    ]).animate(_controller);
    _play();
  }

  Future<void> _play() async {
    for (var i = 0; i < 2 && mounted; i++) {
      await _controller.forward(from: 0);
    }
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: widget.background),
        AnimatedBuilder(
          animation: _offset,
          builder: (context, child) => Transform.translate(
            offset: Offset(_offset.value, 0),
            child: child,
          ),
          child: widget.child,
        ),
      ],
    );
  }
}
