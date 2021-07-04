import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:weathery/utilities/device_location.dart';

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
  late Uri requestUri = Uri.parse('');
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

  Future _requestAndParseWeatherData() async {
    Response rawResponse = await get(requestUri);
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

  @override
  void initState() {
    super.initState();
    getLocationAccess()
        .whenComplete(() => getDeviceLocation())
        .whenComplete(() {
      if (permissionGranted && req.isNotEmpty) {
        requestUri = Uri.parse(req);
        _requestAndParseWeatherData();
      }
    });
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
