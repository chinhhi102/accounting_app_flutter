class Store {
  int CategoryID;
  int quantify;
  DateTime time;

  Store({this.CategoryID, this.quantify, this.time});
}

List<Store> stores = <Store>[
  Store(CategoryID: 1, quantify: 10, time: DateTime.now()),
  Store(CategoryID: 2, quantify: 11, time: DateTime.now()),
  Store(CategoryID: 3, quantify: 12, time: DateTime.now()),
  Store(CategoryID: 4, quantify: 13, time: DateTime.now()),
  Store(CategoryID: 5, quantify: 14, time: DateTime.now()),
  Store(CategoryID: 6, quantify: 15, time: DateTime.now()),
  Store(CategoryID: 7, quantify: 16, time: DateTime.now()),
  Store(CategoryID: 8, quantify: 17, time: DateTime.now()),
  Store(CategoryID: 9, quantify: 18, time: DateTime.now()),
  Store(CategoryID: 10, quantify: 20, time: DateTime.now()),
];