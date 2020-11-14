import 'package:flutter/material.dart';
import 'package:countdown_flutter/countdown_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Premind',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(title: Text("Premind")),
          body: TimerPage(),
        ));
  }
}

class Timer extends StatelessWidget {
  final CountdownFormatted _countdown;
  final String _name;

  Timer(this._name)
      : _countdown = CountdownFormatted(
            duration: Duration(hours: 1),
            builder: (BuildContext ctx, String remaining) {
              return Text(remaining); // 01:00:00
            });

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: [
        Expanded(child: _countdown),
        Text(_name),
      ],
    );
  }
}

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final _timers = <Timer>[];

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: _timers.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          return _buildRow(_timers[index]);
        });
  }

  Widget _buildRow(Timer timer) {
    return ListTile(
      title: timer,
    );
  }

  void _newTimer(String name) {
    setState(() {
      _timers.add(new Timer(name));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Timers'),
        ),
        body: _buildSuggestions(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            String name = '';
            return showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                title: new Text("name"),
                content: new TextField(
                    autofocus: true,
                    onChanged: (value) {
                      name = value;
                    }),
                actions: [
                  FlatButton(
                      child: Text('Ok'),
                      onPressed: () {
                        _newTimer(name);
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            );
          },
          child: Icon(Icons.add),
        ));
  }
}
