import 'dart:async';

import 'package:accountingapp/animation/loading_animation.dart';
import 'package:accountingapp/models/activity_model.dart';
import 'package:accountingapp/models/category_model.dart';
import 'package:accountingapp/models/task_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class ReportTab extends StatefulWidget {
  @override
  _ReportTabState createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {
  List<List<charts.Series<Task, String>>> _seriesPieData;
  List<List<charts.Series<LinearSales, DateTime>>> _seriesLineData;

  FirebaseDatabase database;
  DatabaseReference _categoryRef;
  DatabaseReference _activityRef;

  List<Category> listCate;
  List<Task> listTask;
  RandomColor _randomColor = RandomColor();
  Map<String, Acti> listActi;
  int indexed = 0;

  _generateLine(lineChart, id, color) {
    _seriesLineData[indexed].add(charts.Series(
      data: lineChart,
      id: id,
      colorFn: (_, __) => color,
      domainFn: (LinearSales sales, _) => sales.time,
      measureFn: (LinearSales sales, _) => sales.quantify,
      labelAccessorFn: (LinearSales row, _) => '${row.quantify}',
    ));
  }

  _generateData(pieChart, id) {
    if (_seriesPieData.length > id)
      _seriesPieData[id].clear();
    else
      _seriesPieData.add(new List<charts.Series<Task, String>>());
    _seriesPieData[id].add(
      charts.Series(
        data: pieChart,
        domainFn: (Task task, _) => task.task,
        measureFn: (Task task, _) => task.taskvalue,
        colorFn: (Task task, _) =>
            charts.ColorUtil.fromDartColor(task.colorvalue),
        id: 'Doanh Thu',
        labelAccessorFn: (Task row, _) => '${row.taskvalue}',
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _seriesPieData = List<List<charts.Series<Task, String>>>();
    _seriesLineData = List<List<charts.Series<LinearSales, DateTime>>>();
    database = new FirebaseDatabase();

    _categoryRef = database.reference().child('Categories');
    _activityRef = database.reference().child('Activities');

    listCate = new List();
    listActi = new Map();
    listTask = new List();
  }

  Future<List<Category>> onCateEntryAdded(
      Event event, List<Category> list) async {
    Category n = Category.fromSnapshot(event.snapshot);
//    print("ADD: " + n.name);
    list.add(n);
    return list;
  }

  Future<Map<String, Acti>> onActiEntryAdded(
      Event event, Map<String, Acti> map) async {
    Activity n = Activity.fromSnapshot(event.snapshot);
//    print("ADD: " + n.categoryID);
    String id = n.categoryID;
    if (!map.containsKey(n.categoryID)) map[id] = Acti.empty();
    if (n.type == 0) map[id].SLNhap += n.quantify;
    if (n.type == 1) map[id].SLBan += n.quantify;
    if (n.type == 2) map[id].SLHetHan += n.quantify;
    return map;
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Category> getCategory() {
    Completer c = new Completer<List<Category>>();
    List<Category> list = new List<Category>();
    Stream<Event> sse = _categoryRef.onChildAdded;

    sse.listen((Event event) {
      onCateEntryAdded(event, list).then((List<Category> newsList) {
        return new Future.delayed(new Duration(seconds: 0), () => newsList);
      }).then((_) {
        if (!c.isCompleted) {
          c.complete(list);
        }
      });
    });
    c.future.then((list) {
      listCate = list;
      return list;
    });
  }

  Map<String, Acti> getActivity() {
    Completer c = new Completer<Map<String, Acti>>();
    Map<String, Acti> res = new Map<String, Acti>();
    Stream<Event> sse = _activityRef.onChildAdded;

    sse.listen((Event event) {
      onActiEntryAdded(event, res).then((Map<String, Acti> newMap) {
        return new Future.delayed(new Duration(seconds: 0), () => newMap);
      }).then((_) {
        if (!c.isCompleted) {
          c.complete(res);
        }
      });
    });
    c.future.then((res) {
      listActi = res;
      listActi.forEach((key, value) {
        Category _c =
            listCate[listCate.indexWhere((element) => element.id == key)];
        setState(() {
          listTask.add(new Task(_c.name, value.SLBan * _c.price * 1.0,
              _randomColor.randomColor()));
        });
      });
      print(res);
      return res;
    });
  }

  Widget _buildChildLineChart(title, _key, context, snapshot) {
    DateTime now = DateTime.now();

    listActi = new Map();
    List<LinearSales> type0 = new List();
    List<LinearSales> type1 = new List();
    List<LinearSales> type2 = new List();
    if (_seriesLineData.length > indexed)
      _seriesLineData[indexed].clear();
    else
      _seriesLineData.add(new List<charts.Series<LinearSales, DateTime>>());

    for (int i = 7; i > 0; --i) {
      DateTime date1 = DateTime(now.year, now.month, now.day);
      date1 = date1.subtract(Duration(days: i - 1));
      DateTime date2 = date1.add(Duration(days: 1));
      type0.add(new LinearSales(date1, 0));
      type1.add(new LinearSales(date1, 0));
      type2.add(new LinearSales(date1, 0));
      snapshot.data.snapshot.value.forEach((key, value) {
        Activity n = Activity.fromMap(Map<String, dynamic>.from(value));
        n.id = key;
        String id = n.categoryID;
        if (id == _key) {
          if (n.createAt > date1.toUtc().millisecondsSinceEpoch &&
              n.createAt < date2.toUtc().millisecondsSinceEpoch) {
            // date1.day.toString() + '/' + date1.month.toString()
            if (n.type == 0) type0.last.quantify += n.quantify;
            if (n.type == 1) type1.last.quantify += n.quantify;
            if (n.type == 2) type2.last.quantify += n.quantify;
          }
        }
      });
    }
//    print(_key);
//    print("type 0: ");
//    type0.forEach((element) {print(element.quantify);});
//    print("type 1: ");
//    type1.forEach((element) {print(element.quantify);});
//    print("type 2: ");
//    type2.forEach((element) {print(element.quantify);});
    _generateLine(
        type0, 'Số hàng nhập', charts.MaterialPalette.green.shadeDefault);
    _generateLine(
        type1, 'Số hàng bán', charts.MaterialPalette.red.shadeDefault);
    _generateLine(
        type2, 'Số hàng hết hạn', charts.MaterialPalette.yellow.shadeDefault);
    return SizedBox(
      height: 250.0,
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: charts.TimeSeriesChart(
              _seriesLineData[indexed],
              animate: true,
              animationDuration: Duration(seconds: 2),
              behaviors: [
                new charts.ChartTitle('Days',
                    behaviorPosition: charts.BehaviorPosition.bottom,
                    titleOutsideJustification:
                        charts.OutsideJustification.middleDrawArea),
                new charts.ChartTitle('Sales',
                    behaviorPosition: charts.BehaviorPosition.start,
                    titleOutsideJustification:
                        charts.OutsideJustification.middleDrawArea),
              ],
              defaultRenderer: new charts.LineRendererConfig(),
              customSeriesRenderers: [
                new charts.PointRendererConfig(
                  customRendererId: 'customPoint',
                ),
              ],
              dateTimeFactory: const charts.LocalDateTimeFactory(),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLinerChart(context, snapshot) {
    List<Widget> res = new List();
    res = listCate.map((data) {
      var title = data.name + " 7 ngày";
      indexed = listCate.indexOf(data);
      return _buildChildLineChart(title, data.id, context, snapshot);
    }).toList();
    return res;
  }

  Widget _buildPieChart(title, context, snapshot, num, id) {
    DateTime now = DateTime.now();
    DateTime date1 = DateTime(now.year, now.month, now.day);
    date1.subtract(Duration(days: num - 1));
    DateTime date2 = date1.add(Duration(days: num));
    listActi = new Map();
    listTask = new List();
    snapshot.data.snapshot.value.forEach((key, value) {
      Activity n = Activity.fromMap(Map<String, dynamic>.from(value));
      n.id = key;
      String id = n.categoryID;
      if (n.createAt > date1.toUtc().millisecondsSinceEpoch &&
          n.createAt < date2.toUtc().millisecondsSinceEpoch) {
        if (!listActi.containsKey(n.categoryID)) listActi[id] = Acti.empty();
        if (n.type == 0) listActi[id].SLNhap += n.quantify;
        if (n.type == 1) listActi[id].SLBan += n.quantify;
        if (n.type == 2) listActi[id].SLHetHan += n.quantify;
      }
    });
    listActi.forEach((key, value) {
      int index = listCate.indexWhere((element) => element.id == key);
      if (index >= 0) {
        Category _c =
            listCate[listCate.indexWhere((element) => element.id == key)];
        listTask.add(new Task(
            _c.name, value.SLBan * _c.price * 1.0, _randomColor.randomColor()));
      }
    });
    _generateData(listTask, id);
    return Flexible(
      child: SizedBox(
        height: 250.0,
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: charts.PieChart(
                _seriesPieData[id],
                animate: true,
                animationDuration: Duration(seconds: 2),
                behaviors: [
                  new charts.DatumLegend(
                    outsideJustification:
                        charts.OutsideJustification.endDrawArea,
                    horizontalFirst: false,
                    desiredMaxRows: 2,
                    cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                    entryTextStyle: charts.TextStyleSpec(
                      color: charts.MaterialPalette.purple.shadeDefault,
                      fontFamily: 'Georgia',
                      fontSize: 11,
                    ),
                  )
                ],
                defaultRenderer: new charts.ArcRendererConfig(
                  arcWidth: 100,
                  arcRendererDecorators: [
                    new charts.ArcLabelDecorator(
                      labelPosition: charts.ArcLabelPosition.outside,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(context) {
    return StreamBuilder(
      stream: _categoryRef.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        } else {
          listCate = new List();
          snapshot.data.snapshot.value.forEach((key, value) {
            Category cate = Category.fromMap(Map<String, dynamic>.from(value));
            cate.id = key;
            listCate.add(cate);
          });
          return StreamBuilder(
            stream: _activityRef.onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _buildPieChart(
                              'Doanh thu 7 ngày qua', context, snapshot, 7, 0),
                          SizedBox(
                            height: 20.0,
                          ),
                          _buildPieChart(
                              'Doanh thu hôm nay', context, snapshot, 1, 1),
                          SizedBox(
                            height: 20.0,
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10.0,
                                      width: 10.0,
                                      child: DecoratedBox(
                                        decoration: const BoxDecoration(
                                            color: Colors.green),
                                      ),
                                    ),
                                    Text(
                                      'Nhập hàng',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10.0,
                                      width: 10.0,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                            color: Colors.red),
                                      ),
                                    ),
                                    Text(
                                      'Bán hàng',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10.0,
                                      width: 10.0,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                            color: Colors.yellow[700]),
                                      ),
                                    ),
                                    Text(
                                      'Hết hạn',
                                      style: TextStyle(color: Colors.yellow[700]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Column(
                            children: _buildLinerChart(context, snapshot),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraint.maxHeight),
          child: IntrinsicHeight(
            child: _buildBody(context),
          ),
        ),
      );
    });
  }
}
