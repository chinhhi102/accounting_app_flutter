import 'dart:async';

import 'package:accountingapp/animation/loading_animation.dart';
import 'package:accountingapp/models/activity_model.dart';
import 'package:accountingapp/models/category_model.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class StoreTab extends StatefulWidget {
  int _quantify = 1;

  @override
  _StoreTabState createState() => _StoreTabState();
}

class _StoreTabState extends State<StoreTab> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Category> _cateList;

  Map<String, int> solds;
  Map<String, Image> images;
  Map<String, bool> loads;

  int indexed = -1;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  StreamSubscription<Event> _onCateAddedSubscription;
  StreamSubscription<Event> _onCateChangedSubscription;

  Query _CateQuery;

  @override
  void initState() {
    super.initState();

    _cateList = new List();
    _CateQuery = _database.reference().child("Categories").orderByChild("name");

    solds = new Map();
    images = new Map();
    loads = new Map();

    DateTime now = new DateTime.now();
    DateTime date1 = new DateTime(now.year, now.month, now.day);
    DateTime date2 = date1.add(Duration(days: 1));
    _database.reference().child("Activities").orderByKey().once().then((
        DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if(values != null) {
        values.forEach((key, value) {
          int _t = value['createAt'];
          String _h = value['categoryID'];
          if (_t > date1
              .toUtc()
              .millisecondsSinceEpoch && _t < date2
              .toUtc()
              .millisecondsSinceEpoch) {
            if (value['type'] == 1) {
              solds.containsKey(_h)
                  ? solds[_h] += value['quantify']
                  : solds[_h] =
              value['quantify'];
            }
          }
        });
      }
    });

    _onCateAddedSubscription = _CateQuery.onChildAdded.listen(onEntryAdded);
    _onCateChangedSubscription =
        _CateQuery.onChildChanged.listen(onEntryChanged);
  }

  @override
  void dispose() {
    _onCateAddedSubscription.cancel();
    _onCateChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _cateList.singleWhere((entry) {
      return entry.id == event.snapshot.key;
    });

    setState(() {
      _cateList[_cateList.indexOf(oldEntry)] =
          Category.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    DataSnapshot snapshot = event.snapshot;
    if(!snapshot.value['hiden']) {
      if (snapshot.value['imageUrl'] != '') {
        if (!loads.containsKey(snapshot.key)) loads[snapshot.key] = true;
        if (!images.containsKey(snapshot.key)) {
          images[snapshot.key] = new Image.network(snapshot.value['imageUrl']);
          images[snapshot.key].image.resolve(ImageConfiguration()).addListener(
              ImageStreamListener((ImageInfo image, bool synchronousCall) {
                if (mounted) {
                  setState(() {
                    loads[snapshot.key] = false;
                  });
                }
              }));
        }
      }
      setState(() {
        _cateList.add(Category.fromSnapshot(event.snapshot));
      });
    }
  }

  addActivity(String _id, int _nChoice) {
    Activity activity = new Activity(_id, _nChoice, widget._quantify, DateTime
        .now()
        .toUtc()
        .millisecondsSinceEpoch);
    _database.reference().child("Activities").push().set(activity.toJson());
    int diff = 0;
    int diff2 = 0;
    print(_cateList[indexed].quantify);
    switch (_nChoice) {
      case 0:
        {
          diff = widget._quantify;
        }
        break;
      case 1:
        {
          diff = -widget._quantify;
          diff2 = widget._quantify;
        }
        break;
      case 2:
        {
          diff = -widget._quantify;
        }
        break;
    }
    setState(() {
      _cateList[indexed].quantify == 0
          ? _cateList[indexed].quantify = diff
          : _cateList[indexed].quantify += diff;
      solds.containsKey(_cateList[indexed].id) ?
      solds[_cateList[indexed].id] += diff2 : solds[_cateList[indexed].id] =
          diff2;
    });
    _database.reference().child("Categories").child(_cateList[indexed].id).set(
        _cateList[indexed].toJson());
  }

  Widget _buildQuantifyField(int _nChoice) {
    return TextFormField(
      cursorColor: Colors.black54,
      style: TextStyle(
        color: Colors.black54,
        decorationColor: Colors.black54,
      ),
      initialValue: widget._quantify.toString(),
      decoration: InputDecoration(
        labelText: 'Số lượng',
        hintText: 'Nhập số lượng',
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
        if (value.isEmpty) {
          return 'Số lượng không được bỏ trống!';
        }
      },
      onSaved: (String value) {
        int num = int.tryParse(value);
        if (_nChoice != 0) {
          if (num > _cateList[indexed].quantify) {
            num = _cateList[indexed].quantify;
          }
        }
        widget._quantify = num;
      },
    );
  }

  Widget showImg(Category category) {
    if (category.imageUrl.length > 0) {
      return loads[category.id] ? Loading() : Image(
        width: 110.0,
        image: images[category.id].image,
        fit: BoxFit.cover,
      );;
    } else {
      return Image(
        width: 110.0,
        image: AssetImage('assets/images/rau_cau.jpg'),
        fit: BoxFit.cover,
      );
    }
  }

  _showChoiceDialog(BuildContext context, String _id,
      int _nChoice) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Số lượng lựa chọn', style: TextStyle(fontSize: 20.0,),),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListBody(
                  children: <Widget>[
                    _buildQuantifyField(_nChoice),
                    SizedBox(
                      height: 10.0,
                    ),
                    RaisedButton(
                      color: Colors.indigo,
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            color: Colors.blue[50],
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600),
                      ),
                      onPressed: () async {
                        bool check = await _checkInternetConnectivity();
                        if (check) {
                          return;
                        }
                        if (!_formKey.currentState.validate()) {
                          return;
                        }
                        _formKey.currentState.save();
                        addActivity(_id, _nChoice);
                        widget._quantify = 1;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  showListCate() {
    if (_cateList.length > 0) {
      return Column(
        children: _cateList.map((category) {
          return Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
            child: Stack(
              overflow: Overflow.clip,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(40.0, 5.0, 20.0, 5.0),
                  height: 170.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(100.0, 20.0, 20.0, 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 100.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: 5.0,),
                                  Text(
                                    category.description,
                                    style: TextStyle(color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  '${category.price} ₫',
                                  style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'per pro',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 5.0,),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        'sold: ${solds.containsKey(category.id)
                                            ? solds[category.id]
                                            : 0}',
                                        style: TextStyle(
                                          color: Colors.blue[300],
                                        ),
                                      ),
                                      SizedBox(width: 3.0,),
                                      Text(
                                        'left: ${category.quantify}',
                                        style: TextStyle(
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              SizedBox(
                                width: 70.0,
                                child: RaisedButton(
                                  padding: EdgeInsets.all(5.0),
                                  color: Colors.teal[500],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Text(
                                    'Nhập',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  onPressed: () async {
                                    bool check = await _checkInternetConnectivity();
                                    if (check) {
                                      return;
                                    }
                                    indexed = _cateList.indexOf(category);
                                    _showChoiceDialog(context, category.id, 0);
                                  },
                                ),
                              ),
                              SizedBox(width: 5.0,),
                              SizedBox(
                                width: 70.0,
                                child: RaisedButton(
                                  padding: EdgeInsets.all(5.0),
                                  color: Colors.redAccent[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Text(
                                    'Bán',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  onPressed: () async {
                                    bool check = await _checkInternetConnectivity();
                                    if (check) {
                                      return;
                                    }
                                    indexed = _cateList.indexOf(category);
                                    _showChoiceDialog(context, category.id, 1);
                                  },
                                ),
                              ),
                              SizedBox(width: 5.0,),
                              SizedBox(
                                width: 70.0,
                                child: RaisedButton(
                                  padding: EdgeInsets.all(5.0),
                                  color: Colors.yellow[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Text(
                                    'Hết hạn',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  onPressed: () async {
                                    bool check = await _checkInternetConnectivity();
                                    if (check) {
                                      return;
                                    }
                                    indexed = _cateList.indexOf(category);
                                    _showChoiceDialog(context, category.id, 2);
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20.0,
                  top: 15.0,
                  bottom: 15.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: showImg(category),
                  ),
                )
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Text(
                "Welcome. Your list is empty",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0),
              ),
              Loading(),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            showListCate(),
          ],
        ),
      ),
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
    showDialog(context: context, builder: (context) {
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
}
