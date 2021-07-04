import 'package:flutter/material.dart';

import 'widgets/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of this application.
  @override
  Widget build(BuildContext contet) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weathery App',
      theme: ThemeData(
        // This is the theme of the Weathery application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        primarySwatch: Colors.blueGrey,
      ),
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text('Weathery Home Page'),
          ),
          body: MyHomePage(),
        ),
      ),
    );
  }
}
