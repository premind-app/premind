import 'dart:async' as dart_async;

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

/// A simple deadline-based timer widget.
class Timer extends StatefulWidget {
  /// The time at which the timer will expire.
  final DateTime deadline;

  /// An optional callback triggered when the timer expires.
  final void Function() onFinish;

  /// How frequently the timer display should refresh.
  final Duration refreshInterval;

  /// A function to format the time display
  final String Function(Duration) formatter;

  // Duration's toString() function formats time well, but includes milliseconds after a '.'
  static final _millisRegex = new RegExp(r"\.[0-9]*");
  static String _defaultFormat(Duration d) =>
      d.toString().replaceFirst(_millisRegex, "");

  const Timer({
    Key key,
    @required this.deadline,
    this.onFinish,
    this.refreshInterval = const Duration(seconds: 1),
    this.formatter = _defaultFormat,
  }) : super(key: key);

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  // Interval-based async callback timer
  dart_async.Timer _asyncTimer;

  // The deadline at which the timer expires
  DateTime _deadline;

  // The current formatted remaining time
  String _remaining;

  // Has the completion callback fired?
  bool _hasNotifiedFinish;

  @override
  initState() {
    _deadline = widget.deadline;
    _hasNotifiedFinish = false;

    _startTimer();
    super.initState();
  }

  @override
  dispose() {
    _asyncTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    var update = () {
      setState(() {
        // We must use clock.now() to allow the test framework to control the current time
        var now = clock.now();
        _remaining = widget.formatter(_deadline.difference(now));

        if (!_hasNotifiedFinish && now.compareTo(_deadline) >= 0) {
          _hasNotifiedFinish = true;
          if (widget.onFinish != null) widget.onFinish();
        }
      });
    };

    // Update once before running the timer to initialize
    update();

    _asyncTimer = dart_async.Timer.periodic(widget.refreshInterval, (timer) {
      update();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_remaining);
  }
}
