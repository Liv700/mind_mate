import 'package:flutter/material.dart';
import 'package:mind_mate/pages/home.dart';
import 'package:mind_mate/pages/records.dart';
import 'package:mind_mate/pages/game.dart';
import 'package:mind_mate/pages/loading.dart';


void main() {

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/records': (context) => GameRecords(),
      '/home': (context) => Home(),
      '/game': (context) => PlayMate(),
      '/': (context) => Loading(),
    },
  ));
}





