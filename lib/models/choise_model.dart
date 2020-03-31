import 'package:flutter/material.dart';


class Choice{
  final String title;
  final IconData icon;
  final String imageUrl;
  final String subtitle;
  const Choice({this.title, this.icon, this.imageUrl, this.subtitle});
}

const List<Choice> choices = <Choice>[
  Choice(title: 'Home', icon: Icons.home, imageUrl: 'assets/images/home.png', subtitle: 'Trang chủ ứng dụng'),
  Choice(title: 'Loại sản phẩm', icon: Icons.category, imageUrl: 'assets/images/category.png', subtitle: 'Thông tin các loại sản phẩm'),
  Choice(title: 'Kho', icon: Icons.domain, imageUrl: 'assets/images/kho.png', subtitle: 'Thông tin hàng còn lại trong kho'),
  Choice(title: 'Báo cáo', icon: Icons.pie_chart, imageUrl: 'assets/images/report.png', subtitle: 'Thống kê báo cáo danh mục sản phẩm'),
];