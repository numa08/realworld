import 'package:app/bloc/bloc.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/material.dart';

class ArticleScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final articleId = ModalRoute.of(context).settings.arguments as String;
    print('article id : $articleId');

    return BlocProvider(
      creator: (_context, _bag) => ArticleBloc(AccountRepository(),
          ArticleRepository(), UserRepository(), articleId),
      child: Container(),
    );
  }
}
