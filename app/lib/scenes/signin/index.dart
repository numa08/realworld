import 'package:app/bloc/bloc.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocProvider<SignInBloc>(
        creator: (_context, _bag) => SignInBloc(AccountRepository()),
        child: Builder(builder: (context) {
          final bloc = BlocProvider.of<SignInBloc>(context);
          bloc.signInComplete.listen((_) {
            Navigator.pop(context);
          });
          return Scaffold(
            appBar: AppBar(
              title: const Text('conduit'),
            ),
            body: _Home(
                isSignInProgress: bloc.isSignInProgress,
                onTapSignInWithGoogle: () => bloc.signInWithGoogle.add(null)),
          );
        }),
      );
}

class _Home extends StatelessWidget {
  const _Home({Key key, this.isSignInProgress, this.onTapSignInWithGoogle})
      : super(key: key);

  final Stream<bool> isSignInProgress;
  final VoidCallback onTapSignInWithGoogle;

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
        stream: isSignInProgress,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data) {
            return Center(
              child: const CircularProgressIndicator(),
            );
          } else {
            return Center(
                child: MaterialButton(
              onPressed: onTapSignInWithGoogle,
              child: const Text('Sign in with google'),
            ));
          }
        },
      );
}
