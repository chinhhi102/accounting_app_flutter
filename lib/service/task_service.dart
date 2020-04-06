import 'dart:async';

import 'package:accountingapp/models/activity_model.dart';
import 'package:accountingapp/models/category_model.dart';
import 'package:accountingapp/models/task_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:random_color/random_color.dart';

class Acti {
  int SLNhap;
  int SLBan;
  int SLHetHan;

  Acti.empty()
      : SLNhap = 0,
        SLBan = 0,
        SLHetHan = 0;
}

class TaskService {
  FirebaseDatabase database;
  DatabaseReference _categoryRef;
  DatabaseReference _activityRef;
  DatabaseReference _counterRef;
  StreamSubscription<Event> _onCateAddedSubscription;
  StreamSubscription<Event> _onActiAddedSubscription;
  StreamSubscription<Event> _counterSubscription;
  StreamSubscription<Event> _messagesSubscription;
  int _counter;
  DatabaseError error;

  List<Category> listCate;
  List<Task> listTask;
  RandomColor _randomColor = RandomColor();
  DateTime now;
  DateTime date1;
  DateTime date2;
  Map<String, Acti> listActi;

  static final TaskService _instance = new TaskService.internal();

  TaskService.internal();

  factory TaskService() {
    return _instance;
  }

  void initState() {
    database = new FirebaseDatabase();
    // Demonstrates configuring to the database using a file
    _counterRef = FirebaseDatabase.instance.reference().child('counter');
    // Demonstrates configuring the database directly

    _categoryRef = database.reference().child('Categories');
    _activityRef = database.reference().child('Activities');

    database.reference().child('counter').once().then((DataSnapshot snapshot) {
      print('Connected to second database and read ${snapshot.value}');
    });
    database.setPersistenceEnabled(true);
    _counterRef.keepSynced(true);

    _counterSubscription = _counterRef.onValue.listen((Event event) {
      error = null;
      _counter = event.snapshot.value ?? 0;
    }, onError: (Object o) {
      error = o;
    });

    listCate = new List();
    listActi = new Map();
    listTask = new List();

    listCate = getCategory();
    listActi = getActivity();
//    getActivity();
  }

  Future<List<Category>> onCateEntryAdded(Event event, List<Category> list) async {
    Category n = Category.fromSnapshot(event.snapshot);
    print("ADD: " + n.name);
    list.add(n);
    return list;
  }

  Future<Map<String, Acti>> onActiEntryAdded(Event event, Map<String, Acti> map) async {
    Activity n = Activity.fromSnapshot(event.snapshot);
    print("ADD: " + n.categoryID);
    String id = n.categoryID;
    if (!map.containsKey(n.categoryID)) map[id] = Acti.empty();
    if (n.type == 0) map[id].SLNhap += n.quantify;
    if (n.type == 1) map[id].SLBan += n.quantify;
    if (n.type == 2) map[id].SLHetHan += n.quantify;
    print(map);
    return map;
  }

  DatabaseError getError() {
    return error;
  }

  int getCounter() {
    return _counter;
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
    c.future.then((list){
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
    c.future.then((res){
      return res;
    });
  }

  addCategory(Category category) async {
    final TransactionResult transactionResult =
        await _counterRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? 0) + 1;

      return mutableData;
    });

    if (transactionResult.committed) {
      _categoryRef.push().set(<String, String>{
        "name": "" + category.name,
        "description": "" + category.description,
        "imageUrl": "" + category.imageUrl,
        "cost": "" + category.cost.toString(),
        "price": "" + category.price.toString(),
        "quantify": "" + category.quantify.toString(),
      }).then((_) {
        print('Transaction  committed.');
      });
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }

  void deleteCategory(Category category) async {
    await _categoryRef.child(category.id).remove().then((_) {
      print('Transaction  committed.');
    });
  }

  void updateCategory(Category category) async {
    await _categoryRef.child(category.id).update({
      "name": "" + category.name,
      "description": "" + category.description,
      "imageUrl": "" + category.imageUrl,
      "cost": "" + category.cost.toString(),
      "price": "" + category.price.toString(),
      "quantify": "" + category.quantify.toString(),
    }).then((_) {
      print('Transaction  committed.');
    });
  }

  void dispose() {
    _messagesSubscription.cancel();
    _counterSubscription.cancel();
  }

  getTask() {
    listTask.add(new Task('Hello', 10.0, _randomColor.randomColor()));
    print("List");
    print(listCate);
//    listActi.forEach((key, value) {
//      Category _c =
//          listCate[listCate.indexWhere((element) => element.id == key)];
//      listTask.add(new Task(
//          _c.name,
//          value.SLBan * _c.price * 1.0,
//          _randomColor.randomColor()));
//    });
    return listTask;
  }
}
