
import 'package:flutter/material.dart';
import 'package:mqttttt/pages/HomePage.dart';
import 'package:mqttttt/state/MQTTAppState.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: ChangeNotifierProvider<MQTTAppState>(child: HomePage(),
      create: (_)=>MQTTAppState(),)
    );
  }
}