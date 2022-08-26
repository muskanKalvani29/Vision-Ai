
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_ml_kit_example/VisionDetectorViews/object_detector_view.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({ Key? key }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ObjectDetectorView())));
  }
 @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: FractionalOffset.topLeft , end: FractionalOffset.bottomRight, colors: [
          Colors.deepOrangeAccent,
          Colors.redAccent
        ])
      ),
      // ignore: prefer_const_literals_to_create_immutables
      child: Center(
        child: Text('Vision AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              decoration: TextDecoration.none,
              color: Colors.white,
            )),
      ),
    );
  }
}