import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'generated/premind.pb.dart' as pb;
import 'generated/premind.pbgrpc.dart' as pbgrpc;
import 'models/timers.dart';
import 'widgets/countdown.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
      create: (context) => TimerModel(), child: Premind()));
}

class Premind extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return MaterialApp(
                home:
                    Text("Problem connecting to Firebase: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
                title: 'Premind',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                home: Scaffold(
                  appBar: AppBar(title: Text("Premind")),
                  body: Application(),
                ));
          }

          return MaterialApp(home: AlertDialog(title: Text("Loading")));
        });
  }
}

class Application extends StatefulWidget {
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  pbgrpc.PremindClient _client;
  String _fcmToken;
  String _userId;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      Provider.of<TimerModel>(context, listen: false).add(Timer(
        id: message.data["id"],
        name: message.data["name"],
        deadline: DateTime.fromMillisecondsSinceEpoch(
            int.parse(message.data["deadline"]) * 1000,
            isUtc: true),
      ));
    });

    _client = _getClient();
    _ensureUserCreated();
  }

  pbgrpc.PremindClient _getClient() {
    return pbgrpc.PremindClient(grpc.ClientChannel('192.168.1.223',
        port: 50051,
        options: const grpc.ChannelOptions(
            credentials: grpc.ChannelCredentials.insecure())));
  }

  Future<void> _loadSharedPreferences() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = (prefs.getString('user_id') ?? '');
      _fcmToken = (prefs.getString('fcm_token') ?? '');
    });
  }

  Future<void> _saveSharedPreferences(String userId, String fcmToken) async {
    var prefs = await SharedPreferences.getInstance();

    setState(() {
      _userId = userId;
      _fcmToken = fcmToken;
    });

    await prefs.setString('user_id', _userId);
    await prefs.setString('fcm_token', _fcmToken);
  }

  Future<void> _createUser(String fcmToken) async {
    var user = await _client.createUser(
        pb.CreateUserRequest()..user = (pb.User()..fcmToken = fcmToken));

    await _saveSharedPreferences(user.id, user.fcmToken);
  }

  Future<void> _updateUser(String id, String fcmToken) async {
    var user = await _client.updateUser(pb.UpdateUserRequest()
      ..user = (pb.User()
        ..id = _userId
        ..fcmToken = _fcmToken));

    await _saveSharedPreferences(user.id, user.fcmToken);
  }

  Future<void> _ensureUserCreated() async {
    await _loadSharedPreferences();

    var currentToken = await FirebaseMessaging.instance.getToken();

    if (_userId.isEmpty) {
      print('Creating user');
      await _createUser(currentToken);
    } else if (currentToken != _fcmToken) {
      print('Updating user');
      await _updateUser(_userId, currentToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      print('FCM token changed: $token');
      _updateUser(_userId, currentToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TimerPage();
  }
}

class TimerPage extends StatelessWidget {
  Widget _buildList(List<Timer> timers) {
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      itemCount: timers.length,
      separatorBuilder: (context, i) => Divider(),
      itemBuilder: (context, i) => _buildRow(timers[i]),
    );
  }

  Widget _buildRow(Timer timer) {
    return ListTile(
        title: Row(
      children: [
        Expanded(
            child: Countdown(key: Key(timer.id), deadline: timer.deadline)),
        Text(timer.name),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Timers'),
        ),
        body: Consumer<TimerModel>(builder: (context, timers, child) {
          return FutureBuilder(
              future: timers.timers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return _buildList(snapshot.data);
                }
                return SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                );
              });
        }),
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
                        Provider.of<TimerModel>(context, listen: false).add(
                            Timer(
                                id: "TODO",
                                name: name,
                                deadline:
                                    DateTime.now().add(Duration(minutes: 1))));
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
