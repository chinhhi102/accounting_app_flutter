import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class Activity {
  String id;
  String categoryID;
  int type;
  int quantify;
  int createAt;

  Activity(this.categoryID, this.type, this.quantify, this.createAt);

  Activity.fromMap(Map<String, dynamic> map)
      : categoryID = map['categoryID'],
        type = map['type'],
        quantify = map['quantify'],
        createAt = map['createAt'];

  Activity.fromSnapshot(DataSnapshot snapshot)
      : id = snapshot.key,
        categoryID = snapshot.value['categoryID'],
        type = snapshot.value['type'],
        quantify = snapshot.value['quantify'],
        createAt = snapshot.value['createAt'];

  toJson() {
    return {
      'categoryID': categoryID,
      'type': type,
      'quantify': quantify,
      'createAt': createAt
    };
  }
}