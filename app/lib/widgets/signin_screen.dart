import 'package:app/bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInScreen extends StatelessWidget {
  final FirebaseAuth firebaseAuth;
  final Firestore firestore;

  const SignInScreen(
      {Key key, @required this.firebaseAuth, @required this.firestore})
      : assert(firebaseAuth != null),
        assert(firestore != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('conduit'),
        ),
        body: _Home(),
      );
}

class _Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  SignInBloc signInBloc;

  @override
  void initState() {
    signInBloc = SignInBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder(
        bloc: signInBloc,
        builder: (context, state) {
          if (state is SignInMode) {
            return SingleChildScrollView(
              child: _SignInForm(
                onTapSignUp: () => signInBloc.dispatch(ChangeSignUpMode()),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
            );
          }
          if (state is SignUpMode) {
            return SingleChildScrollView(
              child: _SignUpForm(
                onTapSignIn: () => signInBloc.dispatch(ChangeSignInMode()),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
            );
          }
          if (state is SignInProgress) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is SignInComplete) {
            return Center(
              child: Text('Completed!!'),
            );
          }
        },
      );

  @override
  void dispose() {
    signInBloc.dispose();
    super.dispose();
  }
}

class _SignUpForm extends StatelessWidget {
  final VoidCallback onTapSignIn;

  const _SignUpForm({this.onTapSignIn});

  @override
  Widget build(BuildContext context) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 24,
            ),
            TextFormField(
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  icon: Icon(Icons.person),
                  hintText: 'Your user name',
                  labelText: 'username'),
            ),
            SizedBox(
              height: 24,
            ),
            TextFormField(
              decoration: const InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  icon: Icon(Icons.email),
                  hintText: 'Your email address',
                  labelText: 'Email'),
            ),
            SizedBox(
              height: 24.0,
            ),
            PasswordField(
              helperText: 'Password',
              labelText: 'Password *',
            ),
            SizedBox(
              height: 24.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(onPressed: onTapSignIn, child: Text('Sign In')),
              ],
            )
          ]);
}

class _SignInForm extends StatelessWidget {
  final onTapSignUp;

  const _SignInForm({Key key, this.onTapSignUp}) : super(key: key);
  @override
  Widget build(BuildContext context) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 24,
            ),
            TextFormField(
              decoration: const InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  icon: Icon(Icons.email),
                  hintText: 'Your email address',
                  labelText: 'Email'),
            ),
            SizedBox(
              height: 24.0,
            ),
            PasswordField(
              helperText: 'Password',
              labelText: 'Password *',
            ),
            SizedBox(
              height: 24.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(onPressed: onTapSignUp, child: Text('Sign Up')),
              ],
            )
          ]);
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
  });

  final Key fieldKey;
  final String hintText;
  final String labelText;
  final String helperText;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;

  @override
  _PasswordFieldState createState() => new _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      key: widget.fieldKey,
      obscureText: _obscureText,
      maxLength: 8,
      onSaved: widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: new InputDecoration(
        border: const UnderlineInputBorder(),
        filled: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: new GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child:
              new Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}
