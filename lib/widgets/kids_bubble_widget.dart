import 'package:flutter/material.dart';

class KidsBubbleWidget extends StatefulWidget {
  final String speechText;
  final double? size;
  final Color? bubbleColor;
  final bool isAnimating;
  final bool showFace;
  final double? breathingScale;

  const KidsBubbleWidget({
    super.key,
    required this.speechText,
    this.size = 200,
    this.bubbleColor,
    this.isAnimating = false,
    this.showFace = true,
    this.breathingScale,
  });

  @override
  State<KidsBubbleWidget> createState() => _KidsBubbleWidgetState();
}

class _KidsBubbleWidgetState extends State<KidsBubbleWidget>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _faceExpressionController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _expressionAnimation;

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _faceExpressionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _expressionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _faceExpressionController,
      curve: Curves.elasticOut,
    ));

    if (widget.isAnimating) {
      _breathingController.repeat(reverse: true);
    }
    
    _faceExpressionController.forward();
  }

  @override
  void didUpdateWidget(KidsBubbleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.isAnimating != widget.isAnimating) {
      if (widget.isAnimating) {
        _breathingController.repeat(reverse: true);
      } else {
        _breathingController.stop();
        _breathingController.reset();
      }
    }
    
    if (oldWidget.speechText != widget.speechText) {
      _faceExpressionController.reset();
      _faceExpressionController.forward();
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _faceExpressionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = widget.bubbleColor ?? Theme.of(context).colorScheme.primary;
    final bubbleSize = widget.size ?? 200;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Speech bubble
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Text(
                widget.speechText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: bubbleColor,
                ),
                textAlign: TextAlign.center,
              ),
              // Speech bubble tail
              Positioned(
                bottom: -10,
                left: 20,
                child: CustomPaint(
                  size: const Size(20, 10),
                  painter: SpeechBubbleTailPainter(Colors.white),
                ),
              ),
            ],
          ),
        ),
        
        // Animated breathing bubble with face
        AnimatedBuilder(
          animation: Listenable.merge([_breathingAnimation, _expressionAnimation]),
          builder: (context, child) {
            final currentSize = bubbleSize * (widget.breathingScale ?? (widget.isAnimating ? _breathingAnimation.value : 1.0));
            
            return SizedBox(
              width: currentSize,
              height: currentSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Bubble background
                  Container(
                    width: currentSize,
                    height: currentSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          bubbleColor.withValues(alpha: 0.8),
                          bubbleColor.withValues(alpha: 0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: bubbleColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: widget.isAnimating ? 5 : 2,
                        ),
                      ],
                    ),
                  ),
                  
                  // Face
                  if (widget.showFace)
                    _buildFace(currentSize),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFace(double bubbleSize) {
    final eyeSize = bubbleSize * 0.08;
    final mouthSize = bubbleSize * 0.15;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Eyes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left eye
            Container(
              width: eyeSize,
              height: eyeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: bubbleSize * 0.15),
            // Right eye
            Container(
              width: eyeSize,
              height: eyeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: bubbleSize * 0.1),
        
        // Mouth (smile)
        AnimatedBuilder(
          animation: _expressionAnimation,
          builder: (context, child) {
            return Container(
              width: mouthSize,
              height: mouthSize * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(mouthSize),
                  bottomRight: Radius.circular(mouthSize),
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_expressionAnimation.value * 0.1),
            );
          },
        ),
      ],
    );
  }
}

class SpeechBubbleTailPainter extends CustomPainter {
  final Color color;

  SpeechBubbleTailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
