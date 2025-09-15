import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TimerWidget extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onTimeUp;
  final VoidCallback onTick;
  final bool isActive;

  const TimerWidget({
    super.key,
    required this.durationSeconds,
    required this.onTimeUp,
    required this.onTick,
    required this.isActive,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;

    _controller = AnimationController(
      duration: Duration(seconds: widget.durationSeconds),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTimeUp();
      }
    });

    _controller.addListener(() {
      final remaining =
          (widget.durationSeconds * (1 - _controller.value)).round();
      if (remaining != _remainingSeconds) {
        setState(() {
          _remainingSeconds = remaining;
        });
        widget.onTick();
      }
    });

    // Start timer if widget is active
    if (widget.isActive) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If duration changed, reset the controller
    if (widget.durationSeconds != oldWidget.durationSeconds) {
      _controller.dispose();
      _remainingSeconds = widget.durationSeconds;

      _controller = AnimationController(
        duration: Duration(seconds: widget.durationSeconds),
        vsync: this,
      );

      _animation = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ));

      _pulseAnimation = Tween<double>(
        begin: 1.0,
        end: 1.1,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onTimeUp();
        }
      });

      _controller.addListener(() {
        final remaining =
            (widget.durationSeconds * (1 - _controller.value)).round();
        if (remaining != _remainingSeconds) {
          setState(() {
            _remainingSeconds = remaining;
          });
          widget.onTick();
        }
      });

      // Start timer if widget is active
      if (widget.isActive) {
        _startTimer();
      }
    }

    // Handle active state changes
    if (widget.isActive && !oldWidget.isActive) {
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopTimer();
    }
  }

  void _startTimer() {
    _remainingSeconds = widget.durationSeconds;
    _controller.reset();
    _controller.forward();
  }

  void _stopTimer() {
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTimerColor() {
    if (_remainingSeconds <= 1) return AppTheme.error;
    if (_remainingSeconds <= 2) return AppTheme.warning;
    return AppTheme.success;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _remainingSeconds <= 2 ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.backgroundCard,
              boxShadow: [
                BoxShadow(
                  color: _getTimerColor().withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surfaceElevated,
                  ),
                ),
                // Progress indicator
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: _animation.value,
                    strokeWidth: 6,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
                  ),
                ),
                // Time text
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getTimerColor().withOpacity(0.1),
                  ),
                  child: Text(
                    '$_remainingSeconds',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _getTimerColor(),
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
