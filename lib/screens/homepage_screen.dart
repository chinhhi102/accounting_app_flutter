import 'dart:async';

import 'package:accountingapp/models/category_model.dart';
import 'package:accountingapp/models/choise_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'file:///D:/Flutter/accounting_app/lib/tabs/category_tab.dart' as category_tab;
import 'file:///D:/Flutter/accounting_app/lib/tabs/store_tab.dart' as store_tab;
import 'file:///D:/Flutter/accounting_app/lib/tabs/report_tab.dart' as report_tab;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  StreamSubscription<Event> _onCateAddedSubscription;
  Query _CateQuery;
  int total = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        new TabController(initialIndex: 0, vsync: this, length: choices.length);
    _CateQuery = _database.reference().child("Categories").orderByChild("name");
    _onCateAddedSubscription = _CateQuery.onChildAdded.listen(onEntryAdded);
  }

  onEntryAdded(Event event) {
    DataSnapshot snapshot = event.snapshot;
    if(!snapshot.value['hiden']) {
      setState(() {
        ++total;
      });
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Trang\'s Family',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: choices.map<Widget>(
            (Choice choice) {
              return Tab(
                text: choice.title,
                icon: Icon(
                  choice.icon,
                ),
              );
            },
          ).toList(),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: <Widget>[
          Column(
            children: <Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Welcome!',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                color: Colors.teal,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: 180,
                            child: Text(
                              'I hope your morning is as bright as your smile.!',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Total: ${total} products',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.teal,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: GridView.count(
                  childAspectRatio: 1.0,
                  padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  children: choices.map(
                    (data) {
                      return GestureDetector(
                        onTap: () {
                          _controller.index = choices.indexOf(data);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                data.imageUrl,
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(
                                height: 14,
                              ),
                              Text(
                                data.title,
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Container(
                                width: 120,
                                child: Text(
                                  data.subtitle,
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              SizedBox(
                                height: 14.0,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              )
            ],
          ),
          new category_tab.CategoryTab(),
          new store_tab.StoreTab(),
          new report_tab.ReportTab(),
        ],
      ),
    );
  }
}
