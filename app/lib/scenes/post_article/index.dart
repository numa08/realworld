import 'package:app/bloc/bloc.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/material.dart';

class PostScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocProvider<PostBloc>(
        creator: (_context, _bag) =>
            PostBloc(AccountRepository(), ArticleRepository()),
        child: Builder(builder: (context) {
          final bloc = BlocProvider.of<PostBloc>(context);
          bloc.inputTitle.add("test title");
          bloc.inputDescription.add("test description");
          bloc.inputBody.add("test body");
          bloc.inputTag.add("test tag");
          return Scaffold(
            appBar: AppBar(
              title: Text('conduit'),
            ),
            body: Container(),
            floatingActionButton: FloatingActionButton(
              onPressed: () => bloc.postArticle.add(null),
              child: Icon(Icons.add),
            ),
          );
        }),
      );
}
