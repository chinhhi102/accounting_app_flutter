import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingProcessAnimation extends StatefulWidget {
  @override
  _LoadingProcessAnimationState createState() => _LoadingProcessAnimationState();
}

class _LoadingProcessAnimationState extends State<LoadingProcessAnimation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SpinKitRing(
          size: 50.0,
          color: Colors.blueGrey,
        ),
      ),
    );;
  }
}
