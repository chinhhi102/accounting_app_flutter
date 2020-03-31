import 'dart:io';

import 'package:accountingapp/file_operations/file_utils.dart';
import 'package:accountingapp/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CategoryScreen extends StatefulWidget {
  Category _category = new Category();
  int id = -1;

//  CategoryScreen.empty();
//  CategoryScreen({this.id});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode myFocus = new FocusNode();
  File imageFile;

  Widget _buildNameField() {
    return TextFormField(
      cursorColor: Colors.black54,
      style: TextStyle(
        color: Colors.black54,
        decorationColor: Colors.black54,
      ),
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
      return Text('Chưa có hình nào');
    }else{
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
                  onPressed: () {
                    if (!_formKey.currentState.validate()) {
                      return;
                    }
                    if(imageFile != null){
                      FileUtils.readFromFile().then((value) => print(value));
                    }
                    _formKey.currentState.save();
                    widget._category.imageUrl = 'assets/images/rau_cau.jpg';
                    setState(() {
                      categories.add(widget._category);
                    });
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
}
