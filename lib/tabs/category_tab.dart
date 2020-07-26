import 'dart:async';

import 'package:accountingapp/animation/loading_animation.dart';
import 'package:accountingapp/models/category_model.dart';
import 'file:///D:/Flutter/accounting_app/lib/screens/home/category_screen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryTab extends StatefulWidget {
  @override
  _CategoryTabState createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  Future<void> _question(BuildContext context, String id, int index) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bạn có chắc chắn xóa?'),
            content: Text('Tác vụ này không thể hoàn tác!'),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  setState(() {
                    deleteCate(id, index);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
            elevation: 24.0,
          );
        }
    );
  }

  List<Category> _cateList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  FirebaseStorage firebaseStorage;
  StorageReference _storage;

  StorageReference ref;

  StreamSubscription<Event> _onCateAddedSubscription;
  StreamSubscription<Event> _onCateChangedSubscription;

  Query _CateQuery;

  @override
  void initState() {
    super.initState();

    _cateList = new List();
    _CateQuery = _database.reference().child("Categories").orderByChild("name");
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
    setState(() {
      if(!event.snapshot.value['hiden']) {
        _cateList.add(Category.fromSnapshot(event.snapshot));
      }
    });
  }

  deleteCate(String CateId, int index) {
    _cateList[index].hiden = true;
    _database.reference().child("Categories").child(CateId).set(_cateList[index].toJson());
    print("Delete $CateId successful");
    setState(() {
      _cateList.removeAt(index);
    });
  }

  Widget showImg(String url) {
    print(url);
    if(url.length > 0){
      Image _image = new Image.network(url);
      bool _loading = true;
      
      _image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo image, bool synchronousCall){
        if(mounted){
          setState(() {
            _loading = false;
          });
        }
      }));

      return _loading ? Loading() : CircleAvatar(
        backgroundColor: Colors.blue[300],
        foregroundColor: Colors.blue[300],
        backgroundImage: NetworkImage(url),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.blue[300],
        foregroundColor: Colors.blue[300],
        backgroundImage: AssetImage('assets/images/rau_cau.jpg'),
      );
    }
  }

  Widget showCateList() {
    if (_cateList.length > 0) {
      return Column(
        children: _cateList.map((data) {
          return Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 5.0,
            ),
            child: Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Container(
                  color: Colors.indigo[50],
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 55.0,
                            height: 55.0,
//                                color: Colors.green,
                            child: showImg(data.imageUrl),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                data.name,
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: Colors.blue[900],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  data.description,
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                      color: Colors.blue[300],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              onPressed: () async {
                                bool check = await _checkInternetConnectivity();
                                if(check){
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      CategoryScreen(data)),
                                );
                              },
                              color: Colors.blue[900],
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () async {
                                bool check = await _checkInternetConnectivity();
                                if(check){
                                  return;
                                }
                                _question(
                                    context, data.id, _cateList.indexOf(data));
                              },
                              color: Colors.red,
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return Center(
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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FlatButton(
              onPressed: () async {
                bool check = await _checkInternetConnectivity();
                if(check){
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CategoryScreen(Category.empty())),
                );
              },
              color: Colors.blue[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Text('Thêm'),
            ),
            Text(
              'Danh sách loại',
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            showCateList(),
          ],
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
