import 'package:flutter/material.dart';

import 'widgets/timer.dart';

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

class TimerRow extends StatelessWidget {
  final Timer _timer;
  final String _name;

  TimerRow(this._name)
      : _timer = Timer(deadline: DateTime.now().add(Duration(minutes: 1)));

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: [
        Expanded(child: _timer),
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
  final _timers = <TimerRow>[];

  Widget _buildSuggestions() {
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      itemCount: _timers.length,
      separatorBuilder: (context, i) => Divider(),
      itemBuilder: (context, i) => _buildRow(_timers[i]),
    );
  }

  Widget _buildRow(TimerRow timer) {
    return ListTile(
      title: timer,
    );
  }

  void _newTimer(String name) {
    setState(() {
      _timers.add(new TimerRow(name));
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
