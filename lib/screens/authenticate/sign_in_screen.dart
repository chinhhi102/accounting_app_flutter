import 'package:accountingapp/models/user_model.dart';
import 'package:accountingapp/screens/authenticate/register_screen.dart';
import 'package:accountingapp/screens/home/homepage_screen.dart';
import 'package:accountingapp/service/auth_service.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:accountingapp/api/constants.dart';
import 'package:flutter_icons/flutter_icons.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _auth = AuthService();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String username = "";
  String password = "";

  @override
  Future<void> initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildUsernameField() {
    return TextFormField(
      cursorColor: Colors.white,
      style: TextStyle(
        color: Colors.white,
        decorationColor: Colors.white,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          FontAwesome.user_o,
          color: Colors.white,
          size: 15,
        ),
        hintText: "Username",
        hintStyle: TextStyle(color: Colors.white, fontFamily: 'Sans'),
        labelStyle: TextStyle(color: Colors.white, fontFamily: 'Sans'),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.white)),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        fillColor: Colors.white,
      ),
      initialValue: username,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Username không được bỏ trống!';
        }
        if (value.length < 4) {
          return 'Số kí tự phải lớn hơn 4';
        }
        return null;
      },
      onSaved: (String value) {
        username = value;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      cursorColor: Colors.white,
      style: TextStyle(
        color: Colors.white,
        decorationColor: Colors.white,
      ),
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(
          FontAwesome.key,
          color: Colors.white,
          size: 15,
        ),
        hintText: "Password",
        hintStyle: TextStyle(color: Colors.white, fontFamily: 'Sans'),
        labelStyle: TextStyle(color: Colors.white, fontFamily: 'Sans'),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.white)),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        fillColor: Colors.white,
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password không được bỏ trống!';
        }
        if (value.length < 6) {
          return 'Số kí tự phải lớn hơn 6';
        }
        return null;
      },
      onSaved: (String value) {
        password = value;
      },
    );
  }

  Future<bool> _checkInternetConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      _showDialog('No internet', "You're not connected to a network");
      return true;
    }
    return false;
  }

  _showDialog(title, text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.0, 0.0, 1.0, 0.8],
                  colors: [color_5, color_4, color_3, color_2, color_1])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Center(
                    child: Text(
                  "Accouting App",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'billabong',
                      fontSize: 40),
                )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 70,
                  child: _buildUsernameField(),
                ),
              ),
              //

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 70,
                  child: _buildPasswordField(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  splashColor: Colors.grey,
                  onTap: () async {
                    bool check = await _checkInternetConnectivity();
                    if (check) {
                      return;
                    }
                    if (!_formKey.currentState.validate()) {
                      return;
                    }
                    await _formKey.currentState.save();
                    var status = await _auth.signInUsernamePassword(username, password);
                    if (status != null) {
                      _showDialog("Thông báo", "Đăng nhập thành công");
                    } else {
                      _showDialog("Thông báo",
                          "Đăng nhập thất bại bại, vui lòng thử lại sau!");
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Center(
                      child: Text(
                        "Log In",
                        style: TextStyle(
                            color: color_4,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "or",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),

              /*
              * This are here for decorational purposes so they dont actuslly work
              * */

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  splashColor: Colors.grey,
                  onTap: () async {
                    bool check = await _checkInternetConnectivity();
                    if (check) {
                      return;
                    }
                    var status = await _auth.googleSignIn();
                    if (status != null) {
                      _showDialog("Thông báo", "Đăng nhập thành công");
                    } else {
                      _showDialog("Thông báo",
                          "Đăng nhập thất bại bại, vui lòng thử lại sau!");
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            FontAwesome5Brands.google_plus,
                            color: Colors.red,
                          ),
                        ),
                        Expanded(
                          child: Center(
                              child: Text(
                            "Log In With Google",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ),
                        SizedBox(
                          width: 20,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Don't have an Account ? ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        GestureDetector(
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RegisterScreen(User.empty()),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
