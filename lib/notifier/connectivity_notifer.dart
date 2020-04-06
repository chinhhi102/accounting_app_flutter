import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class CheckConnectivity {

  BuildContext context;
  CheckConnectivity(this.context);

  _checkInternetConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if(result == ConnectivityResult.none) {
      _showDialog('No internet', "You're not connected to a network");
    }
  }
  _showDialog(title, text){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: (){
              Navigator.of(context).pop();
            },
          )
        ],
      );
    });
  }
}