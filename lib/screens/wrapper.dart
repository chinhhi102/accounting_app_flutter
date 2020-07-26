import 'package:accountingapp/models/user_model.dart';
import 'package:accountingapp/screens/home/homepage_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authenticate/authenticate_screen.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    print(user);
    // return either Home or Authenticate widget
    if(user == null) {
      return AuthenticateScreen();
    } else {
      return HomePageScreen();
    }
  }
}
