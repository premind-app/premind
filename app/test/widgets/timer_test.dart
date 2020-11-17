import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:premind/widgets/timer.dart';

// We need to wrap the timer in a MaterialApp to set things like text direction.
Widget timerApp(Timer timer) {
  return MaterialApp(home: Scaffold(body: timer));
}

DateTime deadline(Duration d) {
  return clock.now().add(d);
}

// Flutter's testing framework interacts with time in a clever way. It stands up a fake async
// context (called FakeAsync), and allows time to be manually advanced. As long as clock.now() is
// used instead of DateTime.now(), this give full control of time during testing. These tests would
// be very flaky without that, but are instead perfectly reliable.
void main() {
  testWidgets('timer decrements', (WidgetTester tester) async {
    await tester
        .pumpWidget(timerApp(Timer(deadline: deadline(Duration(minutes: 1)))));

    await tester.runAsync(() async {
      expect(find.text('0:01:00'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('0:00:59'), findsOneWidget,
          reason: 'widget text must decrement as time passes');
    });
  });

  testWidgets('long timer', (WidgetTester tester) async {
    await tester
        .pumpWidget(timerApp(Timer(deadline: deadline(Duration(hours: 30)))));

    await tester.runAsync(() async {
      expect(find.text('30:00:00'), findsOneWidget,
          reason: 'long timers must be displayed correctly');
    });
  });

  testWidgets('timer wraps', (WidgetTester tester) async {
    await tester.pumpWidget(timerApp(Timer(deadline: deadline(Duration()))));

    await tester.runAsync(() async {
      expect(find.text('0:00:00'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('-0:00:01'), findsOneWidget,
          reason: 'widget text must wrap negative when it expires');
    });
  });

  testWidgets('timer fires callback once', (WidgetTester tester) async {
    var called = 0;
    await tester.pumpWidget(timerApp(Timer(
        deadline: deadline(Duration(seconds: 1)),
        onFinish: () {
          called++;
        })));

    await tester.runAsync(() async {
      expect(find.text('0:00:01'), findsOneWidget);
      expect(called, 0, reason: 'callback must not be fired before expiration');
      await tester.pump(Duration(seconds: 1));
      expect(called, 1, reason: 'callback must be fired on expiration');
      await tester.pump(Duration(seconds: 1));
      expect(called, 1, reason: 'callback must be fired only once');
    });
  });

  testWidgets('custom timer formatting', (WidgetTester tester) async {
    await tester.pumpWidget(timerApp(Timer(
        deadline: deadline(Duration(seconds: 15)),
        formatter: (d) {
          return d.inSeconds.toString();
        })));

    await tester.runAsync(() async {
      expect(find.text('15'), findsOneWidget,
          reason: 'custom formatter must be used');

      await tester.pump(Duration(seconds: 1));

      expect(find.text('14'), findsOneWidget,
          reason: 'custom formatter must be used');
    });
  });
}
