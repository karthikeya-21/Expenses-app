import 'package:flutter/material.dart';
import 'package:dreamproject/screens/loginscreen.dart';
import 'package:dreamproject/screens/registerscreen.dart';
import 'package:dreamproject/screens/homescreen.dart';

void main() {
  runApp(
    MaterialApp(
      initialRoute: 'home',
      routes: {
        'home':(context)=>homescreen(),
        'login':(context)=>loginscreen(),
        'register':(context)=>registerscreen(),
      },
    ),
  );
}


