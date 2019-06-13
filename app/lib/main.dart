import 'package:app/bloc/bloc.dart';
import 'package:app/repositories/repositories.dart';
import 'package:app/widgets/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var firestore = Firestore.instance;
    var firebaseAuth = FirebaseAuth.instance;
    var articleRepository = ArticleRepository(firestore: firestore);
    var accountRepository =
        AccountRepository(firebaseAuth: firebaseAuth, firestore: firestore);
    var articleBloc = ArticleBloc(articleRepository: articleRepository);
    var accountBloc = AccountBloc(accountRepository: accountRepository);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('conduit'),
        ),
        body: Articles(
          articleBloc: articleBloc,
        ),
        drawer: TopDrawer(accountBloc: accountBloc),
      ),
    );
  }
}
