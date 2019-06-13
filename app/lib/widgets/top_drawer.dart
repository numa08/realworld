import 'package:app/bloc/bloc.dart';
import 'package:app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopDrawer extends StatelessWidget {
  final AccountBloc accountBloc;

  const TopDrawer({Key key, @required this.accountBloc})
      : assert(accountBloc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => BlocProviderTree(
        blocProviders: [
          BlocProvider<AccountBloc>(
            bloc: accountBloc,
          )
        ],
        child: Drawer(
          child: ListView(children: [DrawerAccountView()]),
        ),
      );
}

class DrawerAccountView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawerAccountViewState();
}

class _DrawerAccountViewState extends State<DrawerAccountView> {
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AccountBloc>(context);
    // firestore の stream を表示する widget
    // StreamBuilder 内で bloc に event を送るため StreamBuilder が再生成されてしまう。
    // 再生成を防ぐためにキャッシュをする。
    StreamBuilder<User> userWidget;
    assert(bloc != null);
    return BlocBuilder(
      bloc: bloc,
      builder: (BuildContext context, AccountState state) {
        if (state is AccountNotLoaded) {
          bloc.dispatch(FetchAccount());
          return DrawerHeader(
            child: CircularProgressIndicator(),
          );
        }
        if (state is AccountLoading) {
          return DrawerHeader(
            child: CircularProgressIndicator(),
          );
        }
        if (state is AccountStream) {
          if (userWidget == null) {
            userWidget = StreamBuilder<User>(
              stream: state.userStream,
              builder: (BuildContext context, AsyncSnapshot<User> snapShot) {
                switch (snapShot.connectionState) {
                  case ConnectionState.waiting:
                    return DrawerHeader(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    if (snapShot.data == null) {
                      bloc.dispatch(LoginAnonymousAccount());
                      return DrawerHeader(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return DrawerHeader(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              child: Text(
                                'G',
                                style: TextStyle(fontSize: 28),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              snapShot.data.username,
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                      );
                    }
                }
              },
            );
          }
          return userWidget;
        }
      },
    );
  }
}
