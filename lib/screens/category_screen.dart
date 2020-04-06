import 'dart:async';
import 'dart:io';

import 'package:accountingapp/animation/loading_animation.dart';
import 'package:accountingapp/models/category_model.dart';
import 'package:accountingapp/notifier/connectivity_notifer.dart';
import 'package:accountingapp/service/auth_service.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class CategoryScreen extends StatefulWidget {
  Category _category;

  CategoryScreen(this._category);

//  CategoryScreen.empty();
//  CategoryScreen({this.id});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {

  final AuthService authService = AuthService();

  FocusNode myFocus = new FocusNode();
  File imageFile;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Future<void> initState() {
    super.initState();

    //_checkEmailVerification();
  }

  @override
  void dispose() {
    super.dispose();
  }

  addNewCate() {
    Category cate = new Category(
        widget._category.name, widget._category.description,
        widget._category.imageUrl,
        widget._category.cost, widget._category.price,
        widget._category.quantify);
    _database.reference().child("Categories").push().set(cate.toJson());
  }

  updateCate() {
    //Toggle completed
    _database.reference().child("Categories").child(widget._category.id).set(
        widget._category.toJson());
  }

  Widget _buildNameField() {
    return TextFormField(
      cursorColor: Colors.black54,
      style: TextStyle(
        color: Colors.black54,
        decorationColor: Colors.black54,
      ),
      initialValue: widget._category.name,
      decoration: InputDecoration(
        labelText: 'Tên loại',
        hintText: 'Nhập tên loại sản phẩm',
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightGreen)),
        border: OutlineInputBorder(borderSide: BorderSide()),
        icon: Icon(Icons.nature),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Tên loại không được bỏ trống!';
        }
      },
      onSaved: (String value) {
        widget._category.name = value;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      cursorColor: Colors.black54,
      style: TextStyle(
        color: Colors.black54,
        decorationColor: Colors.black54,
      ),
      initialValue: widget._category.description,
      decoration: InputDecoration(
        labelText: 'Mô tả',
        hintText: 'Mô tả loại sản phẩm',
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightGreen)),
        border: OutlineInputBorder(borderSide: BorderSide()),
        icon: Icon(Icons.description),
      ),
      onSaved: (String value) {
        widget._category.description = value;
      },
    );
  }

  Widget _buildCostField() {
    return TextFormField(
      cursorColor: Colors.black54,
      style: TextStyle(
        color: Colors.black54,
        decorationColor: Colors.black54,
      ),
      initialValue: widget._category.cost == null ? '' : widget._category.cost
          .toString(),
      decoration: InputDecoration(
        labelText: 'Chi phí',
        hintText: 'Chi phí sản xuất 1 sản phẩm',
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightGreen)),
        border: OutlineInputBorder(borderSide: BorderSide()),
        icon: Icon(Icons.add_shopping_cart),
      ),
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      keyboardType: TextInputType.number,
      validator: (String value) {
        int _cost = int.tryParse(value);
        if (_cost == null || _cost <= 0) {
          return 'Chi phí sản phẩm không hợp lệ';
        }
      },
      onSaved: (String value) {
        int _cost = int.tryParse(value);
        widget._category.cost = _cost;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      cursorColor: Colors.black54,
      style: TextStyle(
        color: Colors.black54,
        decorationColor: Colors.black54,
      ),
      initialValue: widget._category.price == null ? '' : widget._category.price
          .toString(),
      decoration: InputDecoration(
        labelText: 'Gía bán',
        hintText: 'Giá của 1 sản phẩm',
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightGreen)),
        border: OutlineInputBorder(borderSide: BorderSide()),
        icon: Icon(Icons.attach_money),
      ),
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      keyboardType: TextInputType.number,
      validator: (String value) {
        int _cost = int.tryParse(value);
        if (_cost == null || _cost <= 0) {
          return 'Giá sản phẩm không hợp lệ';
        }
      },
      onSaved: (String value) {
        int _price = int.tryParse(value);
        widget._category.price = _price;
      },
    );
  }

  _openGallary(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Make a choice'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Thư viện'),
                  onTap: () {
                    _openGallary(context);
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(15.0),
                ),
                GestureDetector(
                  child: Text('Chụp ảnh'),
                  onTap: () {
                    _openCamera(context);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _decideImageView(){
    if(imageFile == null){
      if (widget._category.imageUrl != '') {
        Image _image = new Image.network(widget._category.imageUrl);
        bool _loading = true;

        _image.image.resolve(ImageConfiguration()).addListener(
            ImageStreamListener((ImageInfo image, bool synchronousCall) {
              if (mounted) {
                setState(() {
                  _loading = false;
                });
              }
            }));

        return _loading ? Loading() : Image(
          image: NetworkImage(widget._category.imageUrl),
          width: 200.0,
          height: 200.0,);
      } else {
        return Text('Chưa có hình nào');
      }
    } else {
      return Image.file(imageFile, width: 200.0, height: 200.0,);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm loại sản phẩm'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildNameField(),
                SizedBox(
                  height: 10.0,
                ),
                _buildDescriptionField(),
                SizedBox(
                  height: 10.0,
                ),
                _buildCostField(),
                SizedBox(
                  height: 10.0,
                ),
                _buildPriceField(),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  margin: EdgeInsets.only(right: 20.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            'Chọn hình ảnh',
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              size: 30.0,
                            ),
                            onPressed: () {
                              _showChoiceDialog(context);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      _decideImageView(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                RaisedButton(
                  color: Colors.indigo,
                  child: Text(
                    'Submit',
                    style: TextStyle(
                        color: Colors.blue[50],
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () async {
                    bool check = await _checkInternetConnectivity();
                    if(check){
                      return;
                    }
                    if (!_formKey.currentState.validate()) {
                      return;
                    }
                    dynamic result = await authService.signInAnon();
                    if (result != null) {
                      if (imageFile != null) {
                        String fileName = path.basename(imageFile.path);
                        final StorageReference ref = firebaseStorageRef.child(
                            fileName);
                        final StorageUploadTask task = ref.putFile(imageFile);
                        widget._category.imageUrl =
                        await ref.getDownloadURL() as String;
                      }
                      await _formKey.currentState.save();
                      if (widget._category.id == '0') {
                        await addNewCate();
                      } else {
                        await updateCate();
                      }
                    }
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

    Future<bool> _checkInternetConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if(result == ConnectivityResult.none) {
      _showDialog('No internet', "You're not connected to a network");
      return true;
    }
    return false;
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
