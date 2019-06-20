import 'package:app/models/models.dart';
import 'package:flutter/material.dart';

class AccountNameLabel extends StatelessWidget {
  final Stream<Account> account;

  const AccountNameLabel({Key key, this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<Account>(
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
}
