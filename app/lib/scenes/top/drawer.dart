import 'package:app/bloc/bloc.dart';
import 'package:app/components/components.dart';
import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:app/scenes/scenes.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/material.dart';

class TopDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocProvider<TopBloc>(
        creator: (_context, _bag) =>
            TopBloc(AccountRepository(), ArticleRepository(), UserRepository()),
        child: Builder(
          builder: (context) {
            var bloc = BlocProvider.of<TopBloc>(context);
            bloc.fetchAccount.add(null);
            bloc.moveToSignIn.listen((_) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignInScreen(),
                      fullscreenDialog: true));
            });
            return Drawer(
              child: ListView(
                children: [
                  _TopDrawerHeader(
                    account: bloc.account,
                    onTapSignIn: () => bloc.signIn.add(null),
                    onTapSignOut: () => bloc.signOut.add(null),
                  )
                ],
              ),
            );
          },
        ),
      );
}

class _TopDrawerHeader extends StatelessWidget {
  final Stream<Account> account;
  final VoidCallback onTapSignIn;
  final VoidCallback onTapSignOut;

  const _TopDrawerHeader(
      {Key key, this.account, this.onTapSignIn, this.onTapSignOut})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
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
                AccountAvatar(
                  account: account,
                ),
                SizedBox(
                  width: 8,
                ),
                AccountNameLabel(
                  account: account,
                )
              ],
            ),
            _signInOutButton(context, account,
                onTapSignIn: onTapSignIn, onTapSignOut: onTapSignOut)
          ],
        )),
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
}
