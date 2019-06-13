import 'package:app/bloc/bloc.dart';
import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Top extends StatelessWidget {
  final ArticleRepository articleRepository;
  final AccountRepository accountRepository;

  const Top(
      {Key key,
      @required this.articleRepository,
      @required this.accountRepository})
      : assert(articleRepository != null),
        assert(accountRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final AccountBloc accountBloc =
        AccountBloc(accountRepository: accountRepository);
    accountBloc.dispatch(FetchAccount());
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<AccountBloc>(
          bloc: accountBloc,
        )
      ],
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: [_TopDrawerHeader()],
          ),
        ),
      ),
    );
  }
}

class _TopDrawerHeader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TopDrawerHeaderState();
}

class _TopDrawerHeaderState extends State<_TopDrawerHeader> {
  @override
  Widget build(BuildContext context) {
    StreamBuilder<User> userWidget;
    var bloc = BlocProvider.of<AccountBloc>(context);
    assert(bloc != null);
    return BlocBuilder(
        bloc: bloc,
        builder: (context, accountState) {
          if (accountState is AccountNotLoaded) {
            return Builder(builder: _placeholderDrawerHeader);
          }
          if (accountState is AccountStream) {
            if (userWidget == null) {
              userWidget = StreamBuilder(
                  stream: accountState.userStream,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Builder(builder: _placeholderDrawerHeader);
                      default:
                        if (snapshot.data == null) {
                          bloc.dispatch(LoginAnonymousAccount());
                          return Builder(
                            builder: _placeholderDrawerHeader,
                          );
                        } else {
                          return Builder(
                              builder: _accountDrawerHeader(snapshot.data));
                        }
                    }
                  });
            }
            return userWidget;
          }
        });
  }
}

Widget _placeholderDrawerHeader(BuildContext context) => Container(
      height: 64,
      child: DrawerHeader(
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        CircleAvatar(
          minRadius: 24,
          maxRadius: 24,
          backgroundColor: Colors.grey,
        ),
        Container(
          width: 100.0,
          height: 12,
          color: Colors.grey,
        )
      ])),
    );

WidgetBuilder _accountDrawerHeader(User user) => (context) => Container(
      height: 64,
      child: DrawerHeader(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Builder(builder: _accountAvatarImage(user.image, user.username)),
          Text(user.username)
        ],
      )),
    );

WidgetBuilder _accountAvatarImage(Uri imageUri, String username) => (context) {
      if (imageUri == null) {
        return CircleAvatar(
          minRadius: 24,
          maxRadius: 24,
          backgroundColor: Colors.blue,
          child: Text(
            username[0],
            style: TextStyle(fontSize: 20),
          ),
        );
      }
      return CircleAvatar(
        minRadius: 24,
        maxRadius: 24,
        backgroundImage: NetworkImage(imageUri.toString()),
      );
    };
