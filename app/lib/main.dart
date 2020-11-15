import 'package:flutter/material.dart';
import 'package:countdown_flutter/countdown_flutter.dart';

void main() {
  runApp(Premind());
}

class Premind extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Premind',
        theme: ThemeData(
          primarySwatch: Colors.blue,
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
