import 'package:accountingapp/models/category_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StoreTab extends StatefulWidget {
  @override
  _StoreTabState createState() => _StoreTabState();
}

class _StoreTabState extends State<StoreTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          Category category = categories[index];
          return Stack(
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
                            width: 120.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  category.name,
                                  style: TextStyle(
                                      fontSize: 18.0, fontWeight: FontWeight.w600),
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
                                'per pax',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 5.0,),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'sold: 10 ',
                                      style: TextStyle(
                                        color: Colors.blue[300],
                                      ),
                                    ),
                                    SizedBox(width: 3.0,),
                                    Text(
                                      'left: 12',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          RaisedButton(
                            padding: EdgeInsets.all(5.0),
                            color: Colors.teal[500],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              'Nhập hàng',
                              style: TextStyle(color: Colors.white70),
                            ),
                            onPressed: () {},
                          ),
                          RaisedButton(
                            padding: EdgeInsets.all(5.0),
                            color: Colors.redAccent[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              'Bán hàng',
                              style: TextStyle(color: Colors.white70),
                            ),
                            onPressed: () {},
                          ),
                        ],
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
                  child: Image(
                    width: 110.0,
                    image: AssetImage(category.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
