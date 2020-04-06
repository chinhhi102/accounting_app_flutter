import 'dart:ui';

class Task {
  String task;
  double taskvalue;
  Color colorvalue;

  Task(this.task, this.taskvalue, this.colorvalue);
}

class LinearSales {
  DateTime time;
  int quantify;

  LinearSales(this.time, this.quantify);
}

class Acti {
  int SLNhap;
  int SLBan;
  int SLHetHan;

  Acti.empty()
      : SLNhap = 0,
        SLBan = 0,
        SLHetHan = 0;
}