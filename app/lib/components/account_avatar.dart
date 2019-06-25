import 'package:app/models/models.dart';
import 'package:flutter/material.dart';

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({Key key, this.account}) : super(key: key);
  final Stream<Account> account;

  @override
  Widget build(BuildContext context) => StreamBuilder<Account>(
        stream: account,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Builder(
                builder: (context) => const CircleAvatar(
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

  Widget _accountAvatarImage(Uri imageUri, String username) {
    if (imageUri == null) {
      return CircleAvatar(
        radius: 16,
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
      radius: 16,
      backgroundImage: NetworkImage(imageUri.toString()),
      backgroundColor: Colors.transparent,
    );
  }
}
