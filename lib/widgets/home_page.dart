import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:weathery/constants.dart';

import 'temp_icon.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of this application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double latitude = 0, longitude = 0;
  late bool permissionGranted;
  late Uri _req = Uri.parse('');
  late double humidity = 0,
      pressure = 0,
      temperature = 0,
      visibility = 0,
      windSpeed = 0;
  int weatherCode = 0;
  var country,
      isDay,
      locationName,
      localTime,
      position,
      region,
      timezone,
      weatherIconLink,
      weatherDescription,
      windDirection;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _getUserDeviceLocation() async {
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    latitude = pos.latitude;
    longitude = pos.longitude;
    _req = Uri.parse(
        'http://api.weatherstack.com/current?access_key=d1a39645995e0c8a2088f7be4c81da2c&query=$latitude,$longitude&units=$kUnitType');
    return pos;
  }

  Future _requestAndParseWeatherData() async {
    Response rawResponse = await get(_req);
    var weatherJSONResponse = jsonDecode(rawResponse.body);

    setState(() {
      // int variables
      temperature = weatherJSONResponse['current']['temperature'];
      visibility = weatherJSONResponse['current']['visibility'];
      weatherCode = weatherJSONResponse['current']['weather_code'];
      windSpeed = weatherJSONResponse['current']['wind_speed'];
      windDirection = weatherJSONResponse['current']['wind_dir'];

      // String variables
      country = weatherJSONResponse['location']['country'];
      isDay = weatherJSONResponse['current']['is_day'];
      locationName = weatherJSONResponse['location']['name'];
      localTime = weatherJSONResponse['location']['localtime'];
      region = weatherJSONResponse['location']['region'];
      position = weatherJSONResponse['request']['query'];
      timezone = weatherJSONResponse['location']['timezone_id'];
      var icon = [];
      icon.add(weatherJSONResponse['current']['weather_icons'][0].toString());
      weatherIconLink = icon.isNotEmpty
          ? weatherJSONResponse['current']['weather_icons'][0]
          : '';
      icon.add(weatherJSONResponse['current']['weather_descriptions'][0]);
      weatherDescription = icon[1] != null
          ? weatherJSONResponse['current']['weather_descriptions'][0]
          : '';
    });
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
    _getLocationAccess()
        .whenComplete(() => _getUserDeviceLocation())
        .whenComplete(() => _requestAndParseWeatherData());
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height / 5,
          width: MediaQuery.of(context).size.width,
          color: Colors.blueGrey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Text(locationName != null
                    ? 'The weather at $locationName ($position)'
                    : '...'),
              ),
              Expanded(
                flex: 1,
                child: Text(
                    localTime != null ? 'On $localTime ($timezone)' : '...'),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView(
            children: [
              ListTile(
                leading: weatherIconLink != null
                    ? Image.network(weatherIconLink)
                    : FaIcon(FontAwesomeIcons.cloud),
                title: Text('Weather'),
                subtitle: Text('Weather Code: $weatherCode'),
                trailing: Text('$weatherDescription'),
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.city),
                subtitle: Text('$region'),
                title: Text('Region'),
                trailing: Text('$country'),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.tachometerAlt),
                subtitle: Text('Air Humidity Level'),
                title: Text('Humidity'),
                trailing: Text('$humidity' + '%'),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.tachometerAlt),
                subtitle: Text('Air Pressure'),
                title: Text('Pressure'),
                trailing: Text('$pressure' + 'MB (millibar'),
              ),
              ListTile(
                leading: TempIcon(
                  temp: temperature,
                ),
                title: Text('Temperature'),
                trailing: Text('$temperature' + '\u00B0' + 'C'),
              ),
              ListTile(
                // TODO: Find icons & define conditions to use appropriate
                //  icon depending on visibility
                leading: Icon(FontAwesomeIcons.eye),
                title: Text('Visibility'),
                trailing: Text('$visibility KM'),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.directions),
                title: Text('Wind Direction'),
                trailing: Text('$windDirection'),
              ),
              ListTile(
                // TODO: Find icons & define conditions to use appropriate
                //  icon depending on visibility
                leading: Icon(FontAwesomeIcons.wind),
                title: Text('Wind Speed'),
                trailing: Text('$windSpeed KM/hr'),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: _requestAndParseWeatherData,
            child: Text(
              'Reload Data',
            ),
          ),
        ),
      ],
    );
  }
}
