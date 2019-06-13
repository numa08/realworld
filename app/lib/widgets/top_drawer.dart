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
          child: DrawerAccountView(),
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
          return CircularProgressIndicator();
        }
        if (state is AccountLoading) {
          return CircularProgressIndicator();
        }
        if (state is AccountStream) {
          if (userWidget == null) {
            userWidget = StreamBuilder<User>(
              stream: state.userStream,
              builder: (BuildContext context, AsyncSnapshot<User> snapShot) {
                switch (snapShot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    if (snapShot.data == null) {
                      bloc.dispatch(LoginAnonymousAccount());
                      return Center(
                        child: Text('no account'),
                      );
                    } else {
                      return Center(
                        child: Text('has account ${snapShot.data.token}'),
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
