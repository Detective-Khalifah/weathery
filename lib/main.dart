import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: Colors.blueGrey[600],
          elevation: 4,
          margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
        ),
      ),
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.amberAccent,
          appBar: AppBar(
            backgroundColor: Colors.lightBlueAccent[100],
            elevation: 8,
            leading: Icon(
              CupertinoIcons.cloud,
              color: Colors.blueGrey,
              size: 40,
            ),
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(
              'Weathery Home Page',
              style: GoogleFonts.rockSalt(color: Colors.blueGrey, fontSize: 20),
            ),
          ),
          body: MyHomePage(),
        ),
      ),
    );
  }
}
