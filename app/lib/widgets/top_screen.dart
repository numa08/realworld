import 'package:app/bloc/bloc.dart';
import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('conduit'),
        ),
        drawer: Drawer(
          child: ListView(
            children: [_DrawerHeader()],
          ),
        ),
        body: Center(
          child: Text('test'),
        ),
      );
}

class _DrawerHeader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawerHeaderState();
}

class _DrawerHeaderState extends State<_DrawerHeader> {
  AccountBloc _accountBloc;
  SignInBloc _signInBloc;

  @override
  void initState() {
    super.initState();
    var repository = AccountRepository();
    _accountBloc = AccountBloc(accountRepository: repository);
    _signInBloc = SignInBloc(accountRepository: repository);
  }

  @override
  void dispose() {
    _accountBloc.dispose();
    _signInBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProviderTree(
        blocProviders: [
          BlocProvider<AccountBloc>(
            bloc: _accountBloc,
          )
        ],
        child: BlocListener(
          bloc: _accountBloc,
          listener: (context, state) {
            if (state is AccountNotLoaded) {
              _accountBloc.dispatch(FetchAccount());
            }
          },
          child: Container(
            height: 64,
            child: DrawerHeader(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _accountAvatar(context, _accountBloc.accountStream),
                    _accountNameLabel(context, _accountBloc.accountStream)
                  ],
                ),
                _signInOutButton(context, _accountBloc.accountStream,
                    onTapSignIn: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                            fullscreenDialog: true)),
                    onTapSignOut: () {})
              ],
            )),
          ),
        ),
      );
}

Widget _accountAvatarImage(Uri imageUri, String username) {
  if (imageUri == null) {
    return CircleAvatar(
      minRadius: 24,
      maxRadius: 24,
      backgroundColor: Colors.blue,
      child: Center(
        child: Text(
          username[0],
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
  return CircleAvatar(
    minRadius: 24,
    maxRadius: 24,
    backgroundImage: NetworkImage(imageUri.toString()),
  );
}

Widget _accountAvatar(BuildContext context, Stream<Account> account) =>
    StreamBuilder<Account>(
      stream: account,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Builder(
              builder: (context) => CircleAvatar(
                    minRadius: 24,
                    maxRadius: 24,
                    backgroundColor: Colors.grey,
                  ));
        } else {
          return _accountAvatarImage(
              snapshot.data.image, snapshot.data.username);
        }
      },
    );

Widget _accountNameLabel(BuildContext context, Stream<Account> account) =>
    StreamBuilder<Account>(
      stream: account,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Builder(
              builder: (context) => Container(
                    width: 100.0,
                    height: 12,
                    color: Colors.grey,
                  ));
        } else {
          return Center(child: Text(snapshot.data.username));
        }
      },
    );

Widget _signInOutButton(BuildContext context, Stream<Account> account,
        {VoidCallback onTapSignIn, VoidCallback onTapSignOut}) =>
    StreamBuilder<Account>(
        stream: account,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          }
          if (snapshot.data.isAnonymous) {
            return FlatButton(
              child: Text('Sign In/Up'),
              onPressed: onTapSignIn,
            );
          }
          return FlatButton(
            child: Text('Sign Out'),
            onPressed: onTapSignOut,
          );
        });
