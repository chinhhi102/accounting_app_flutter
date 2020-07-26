import 'package:accountingapp/api/constants.dart';
import 'package:accountingapp/models/user_model.dart';
import 'package:accountingapp/service/auth_service.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class RegisterScreen extends StatefulWidget {
  User _user;

  RegisterScreen(this._user);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _pass = TextEditingController();

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
      initialValue: widget._user.username,
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
        widget._user.username = value;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _pass,
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
          return 'Mật khẩu chứa ít nhất 6 kí tự';
        }
        return null;
      },
      onSaved: (String value) {
        widget._user.password = value;
      },
    );
  }

  Widget _buildRepeatPasswordField() {
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
        hintText: "Repeat Password",
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
        if (value != _pass.text) {
          return 'Mật khẩu không trùng';
        }
        return null;
      },
    );
  }

  Widget _buildFullnameField() {
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
        hintText: "Fullname",
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
      initialValue: widget._user.fullName,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Tên không được bỏ trống!';
        }
        if (value.length < 4) {
          return 'Tên chứa ít nhất 4 kí tự';
        }
        return null;
      },
      onSaved: (String value) {
        widget._user.fullName = value;
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.0, 0.0, 1.0, 0.8],
                  colors: [color_1, color_2, color_3, color_4, color_5])),
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
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 70,
                  child: _buildPasswordField(),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 70,
                  child: _buildRepeatPasswordField(),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 70,
                  child: _buildFullnameField(),
                ),
              ),
              SizedBox(
                height: 10.0,
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
                    var status = await _auth.registerWithEmailAndPassword(widget._user.username, widget._user.password, widget._user.fullName);
                    if(status == null){
                      _showDialog("Lỗi", "Đăng kí thất bại");
                    } else {
                      Navigator.pop(context);
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
                        "Register",
                        style: TextStyle(
                            color: color_4,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
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
                          "Already have an Account ? ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        GestureDetector(
                          child: Text(
                            "Sign in",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
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
