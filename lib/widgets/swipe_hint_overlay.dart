import 'package:flutter/material.dart';

/// A one-time, full-screen dimmed overlay that shows a swipe-gesture icon to
/// hint that the item above/behind it can be swiped to delete. Dismissed by
/// tapping anywhere.
class SwipeHintOverlay extends StatefulWidget {
  const SwipeHintOverlay({
    super.key,
    required this.onDismiss,
    this.topOffset = 220,
  });

  final VoidCallback onDismiss;

  /// Roughly how far down the screen the hinted card sits, so the icon lines up with it.
  final double topOffset;

  @override
  State<SwipeHintOverlay> createState() => _SwipeHintOverlayState();
}

class _SwipeHintOverlayState extends State<SwipeHintOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _offset = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -28.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -28.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_controller);
    _playLoop();
  }

  // Loops a bounded number of times (rather than repeating forever) so the
  // animation settles instead of ticking indefinitely in the background.
  Future<void> _playLoop() async {
    for (var i = 0; i < 4 && mounted; i++) {
      await _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onDismiss,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.black.withValues(alpha: 0.55),
          child: Padding(
            padding: EdgeInsets.only(top: widget.topOffset),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _offset,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(_offset.value, 0),
                        child: child,
                      ),
                      child: const Text('👆', style: TextStyle(fontSize: 40)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '왼쪽으로 스와이프하면 삭제가능!\n화면 아무데나 탭하면 사라져요',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
