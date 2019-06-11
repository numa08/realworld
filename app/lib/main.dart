import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String name = 'numa-realworld';
  Future<void> _configure() async {
    final FirebaseApp app = FirebaseApp.instance;
    assert(app != null);
    print('Configured $app');
  }

  Future<void> _allApps() async {
    final List<FirebaseApp> apps = await FirebaseApp.allApps();
    print('Currently configured apps: $apps');
  }

  Future<void> _options() async {
    final FirebaseApp app = FirebaseApp.instance;
    final FirebaseOptions options = await app?.options;
    print('Current options for app $name: $options');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Core example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RaisedButton(
                  onPressed: _configure, child: const Text('initialize')),
              RaisedButton(onPressed: _allApps, child: const Text('allApps')),
              RaisedButton(onPressed: _options, child: const Text('options')),
            ],
          ),
        ),
      ),
    );
  }
}
