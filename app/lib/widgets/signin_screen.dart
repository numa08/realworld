import 'package:app/bloc/bloc.dart';
import 'package:app/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('conduit')),
        body: _Home(),
      );
}

class _Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  SignInBloc _signInBloc;

  @override
  void initState() {
    _signInBloc = SignInBloc(AccountRepository());
    super.initState();
  }

  @override
  Widget build(BuildContext context) => BlocProviderTree(
        blocProviders: [
          BlocProvider<SignInBloc>(
            bloc: _signInBloc,
          )
        ],
        child: BlocListener(
          bloc: _signInBloc,
          listener: (context, state) {
            if (state is SignInComplete) {
              Navigator.of(context).pop();
            }
          },
          child: Builder(
            builder: (context) => Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _progressInLoading(context),
                        _signUpWithGoogleButton(context),
                        _showError(context)
                      ]),
                ),
          ),
        ),
      );

  @override
  void dispose() {
    _signInBloc.dispose();
    super.dispose();
  }
}

Widget _progressInLoading(BuildContext context) => BlocBuilder(
      bloc: BlocProvider.of<SignInBloc>(context),
      builder: (context, state) {
        if (state is SignInProgress) {
          return CircularProgressIndicator();
        }
        return Container();
      },
    );

Widget _signUpWithGoogleButton(BuildContext context) => BlocBuilder(
      bloc: BlocProvider.of<SignInBloc>(context),
      builder: (context, state) {
        if (state is SignUp) {
          final SignInBloc bloc = BlocProvider.of<SignInBloc>(context);
          return FlatButton(
            onPressed: () => bloc.dispatch(SignInWithGoogle()),
            child: Text('Sign Up With Google'),
          );
        } else {
          return Container();
        }
      },
    );

Widget _showError(BuildContext context) => BlocBuilder(
    bloc: BlocProvider.of<SignInBloc>(context),
    builder: (context, state) {
      if (state is SignInError) {
        return Text(
          'Error ${state.error}',
          style: TextStyle(color: Theme.of(context).errorColor),
        );
      }
      return Container();
    });

bool notNull(Object any) {
  return any != null;
}
