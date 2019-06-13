import 'package:app/bloc/bloc.dart';
import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopScreen extends StatelessWidget {
  final FirebaseAuth firebaseAuth;
  final Firestore firestore;

  const TopScreen(
      {Key key, @required this.firebaseAuth, @required this.firestore})
      : assert(firebaseAuth != null),
        assert(firestore != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('conduit'),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              _DrawerHeader(firebaseAuth: firebaseAuth, firestore: firestore)
            ],
          ),
        ),
        body: Center(
          child: _Home(firebaseAuth: firebaseAuth, firestore: firestore),
        ),
      );
}

class _Home extends StatefulWidget {
  final FirebaseAuth firebaseAuth;
  final Firestore firestore;

  const _Home({Key key, @required this.firebaseAuth, @required this.firestore})
      : assert(firebaseAuth != null),
        assert(firestore != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  AccountBloc _accountBloc;

  @override
  void initState() {
    super.initState();
    var repository = AccountRepository(
        firebaseAuth: widget.firebaseAuth, firestore: widget.firestore);
    _accountBloc = AccountBloc(accountRepository: repository);
  }

  @override
  void dispose() {
    _accountBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    StreamBuilder<User> loginWithAnonymous;
    return BlocBuilder(
        bloc: _accountBloc,
        builder: (context, accountState) {
          if (accountState is AccountNotLoaded) {
            _accountBloc.dispatch(FetchAccount());
            return Center(child: CircularProgressIndicator());
          }
          if (accountState is AccountStream) {
            if (loginWithAnonymous == null) {
              loginWithAnonymous = StreamBuilder(
                  stream: accountState.userStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.active) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data == null) {
                      _accountBloc.dispatch(LoginAnonymousAccount());
                      return Center(child: CircularProgressIndicator());
                    }
                    return Text('login with ${snapshot.data.username}');
                  });
            }
            return loginWithAnonymous;
          }
        });
  }
}

class _DrawerHeader extends StatefulWidget {
  final FirebaseAuth firebaseAuth;
  final Firestore firestore;

  const _DrawerHeader(
      {Key key, @required this.firebaseAuth, @required this.firestore})
      : assert(firebaseAuth != null),
        assert(firestore != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _DrawerHeaderState();
}

class _DrawerHeaderState extends State<_DrawerHeader> {
  AccountBloc _accountBloc;

  @override
  void initState() {
    super.initState();
    var repository = AccountRepository(
        firestore: widget.firestore, firebaseAuth: widget.firebaseAuth);
    _accountBloc = AccountBloc(accountRepository: repository);
  }

  @override
  void dispose() {
    _accountBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder(
      bloc: _accountBloc,
      builder: (context, accountState) {
        if (accountState is AccountNotLoaded) {
          _accountBloc.dispatch(FetchAccount());
          return Builder(
            builder: _placeholderDrawerHeader,
          );
        }
        if (accountState is AccountStream) {
          return StreamBuilder(
            stream: accountState.userStream,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Builder(builder: _placeholderDrawerHeader);
              } else {
                return Builder(
                  builder: _accountDrawerHeader(snapshot.data),
                );
              }
            },
          );
        }
      });
}

WidgetBuilder _placeholderDrawerHeader = (context) => Container(
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Builder(builder: _accountAvatarImage(user.image, user.username)),
          Center(child: Text(user.username))
        ],
      )),
    );

WidgetBuilder _accountAvatarImage(Uri imageUri, String username) => (context) {
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
    };
