import 'package:app/bloc/bloc.dart';
import 'package:app/repositories/repositories.dart';
import 'package:app/widgets/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
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
    var articleRepository = ArticleRepository(firestore: firestore);
    var articleBloc = ArticleBloc(articleRepository: articleRepository);
    return MaterialApp(
      home: Articles(
        articleBloc: articleBloc,
      ),
    );
  }
}
