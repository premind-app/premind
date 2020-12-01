import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class Timer {
  final String id;
  final String name;
  final DateTime deadline;

  Timer({this.id, this.name, this.deadline});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'deadline': deadline.toString(),
    };
  }

  static Timer fromMap(Map<String, dynamic> map) {
    return Timer(
        id: map['id'],
        name: map['name'],
        deadline: DateTime.parse(map['deadline']));
  }
}

class TimerModel extends ChangeNotifier {
  Future<Database> _database = _openDatabase();
  Future<List<Timer>> _timers;

  TimerModel() {
    _timers = _loadTimers();
    _timers.then((_) {
      notifyListeners();
    });
  }

  static Future<Database> _openDatabase() async {
    var schema = '''CREATE TABLE timers(
											id STRING PRIMARY KEY,
											name TEXT,
											deadline TEXT
										)''';

    var dbPath = path.join(await getDatabasesPath(), 'timers.db');

    return openDatabase(dbPath, onCreate: (db, version) {
      return db.execute(schema);
    }, version: 1);
  }

  Future<List<Timer>> _loadTimers() async {
    var db = await _database;

    return db.query('timers').then((result) {
      return result.map((m) {
        return Timer.fromMap(m);
      }).toList();
    });
  }

  Future<void> add(Timer timer) async {
    var db = await _database;
    var timers = await _timers;

    timers.add(timer);
    db.insert('timers', timer.toMap());

    notifyListeners();
  }

  Future<UnmodifiableListView<Timer>> get timers {
    return _timers.then((t) {
      return UnmodifiableListView(t);
    });
  }
}
