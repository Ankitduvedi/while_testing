import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:quiver/async.dart';

class TimerDialog extends StatefulWidget {
  const TimerDialog({Key? key, required this.timePassed}) : super(key: key);
  final Duration timePassed;

  @override
  TimerDialogState createState() => TimerDialogState();
}

class TimerDialogState extends State<TimerDialog> {
  late CountdownTimer _timer;

  @override
  void initState() {
    super.initState();
    log(widget.timePassed.toString());
    _timer = CountdownTimer(
      Duration(seconds: 300 - widget.timePassed.inSeconds),
      const Duration(seconds: 1),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer.listen((CountdownTimer timer) {
      if (timer.remaining.inSeconds == 0) {
        Navigator.pop(context);
      }
      setState(() {}); // Update the UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('Lives Renew in: ${_formatDuration(_timer.remaining)}'),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
