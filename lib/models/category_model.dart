import 'package:firebase_database/firebase_database.dart';

class Category {
  String id;
  String name;
  String description;
  String imageUrl;
  int cost;
  int price;
  int quantify;
  bool hiden;

  Category(this.name, this.description, this.imageUrl, this.cost, this.price,
      this.quantify) : this.hiden = false;

  Category.empty()
      : id = '0',
        quantify = 0,
        imageUrl = '',
        hiden = false;

  Category.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        hiden = map['hiden'],
        description = map['description'],
        imageUrl = map['imageUrl'],
        cost = map['cost'],
        price = map['price'],
        quantify = map['quantify'];

  Category.fromSnapshot(DataSnapshot snapshot)
      : id = snapshot.key,
        name = snapshot.value['name'],
        hiden = snapshot.value['hiden'],
        description = snapshot.value['description'],
        imageUrl = snapshot.value['imageUrl'],
        cost = snapshot.value['cost'],
        price = snapshot.value['price'],
        quantify = snapshot.value['quantify'];

  toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'cost': cost,
      'hiden': hiden,
      'price': price,
      'quantify': quantify
    };
  }
}