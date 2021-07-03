import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

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
      home: MyHomePage(title: 'Weathery Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of this application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double latitude = 0, longitude = 0;
  late bool permissionGranted;
  late Uri req = Uri.parse('');
  late final String region,
      country,
      locationName,
      timezone,
      localTime,
      temperature,
      weatherIcon,
      weatherDescription;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _getUserDeviceLocation() async {
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    setState(() {
      latitude = pos.latitude;
      longitude = pos.longitude;
      req = Uri.parse(
          'http://api.weatherstack.com/current?access_key=d1a39645995e0c8a2088f7be4c81da2c&query=$latitude,$longitude');
    });
    return pos;
  }

  Future _requestWeatherData() async {
    Response rawResponse = await get(req);
    var jSONResponse = jsonDecode(rawResponse.body);
    print(jSONResponse.toString());
  }

  Future _getLocationAccess() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    switch (permission) {
      case LocationPermission.denied:
        // TODO: Handle this case.
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          permissionGranted = false;
          return Future.error('Location permissions are denied');
        }
        break;
      case LocationPermission.deniedForever:
        // TODO: Permissions are denied forever, handle appropriately.
        permissionGranted = false;
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        permissionGranted = true;
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocationAccess().whenComplete(() => _getUserDeviceLocation());
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _requestWeatherData();
              },
              child: Text(
                'Device Location:: Latitude: $latitude, Longitude: $longitude\nQuery:: $req',
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
