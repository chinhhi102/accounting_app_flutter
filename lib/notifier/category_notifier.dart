import 'dart:collection';

import 'package:accountingapp/models/category_model.dart';
import 'package:flutter/cupertino.dart';

class CategoryNotifier with ChangeNotifier{
  List<Category> _cateList = [];
  Category _currentCate;

  UnmodifiableListView<Category> get cateList => UnmodifiableListView(_cateList);

  Category get currentCate => _currentCate;

  set cateList(List<Category> cateList){
    _cateList = cateList;
    notifyListeners();
  }

  set currentCate(Category cate){
    _currentCate = cate;
    notifyListeners();
  }
}