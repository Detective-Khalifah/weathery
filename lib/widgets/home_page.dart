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
  late Uri _requestUri = Uri.parse('');
  late double _humidity = 0,
      _pressure = 0,
      _temperature = 0,
      _visibility = 0,
      _windSpeed = 0;
  int _weatherCode = 0;
  var _country,
      _isDay,
      _locationName,
      _localTime,
      _position,
      _region,
      _timezone,
      _weatherIconLink,
      _weatherDescription,
      _windDirection;

  Future _requestAndParseWeatherData() async {
    Response rawResponse = await get(_requestUri);
    var weatherJSONResponse = jsonDecode(rawResponse.body);

    setState(() {
      // int variables
      _temperature = weatherJSONResponse['current']['temperature'];
      _visibility = weatherJSONResponse['current']['visibility'];
      _weatherCode = weatherJSONResponse['current']['weather_code'];
      _windSpeed = weatherJSONResponse['current']['wind_speed'];
      _windDirection = weatherJSONResponse['current']['wind_dir'];

      // String variables
      _country = weatherJSONResponse['location']['country'];
      _isDay = weatherJSONResponse['current']['is_day'];
      _locationName = weatherJSONResponse['location']['name'];
      _localTime = weatherJSONResponse['location']['localtime'];
      _region = weatherJSONResponse['location']['region'];
      _position = weatherJSONResponse['request']['query'];
      _timezone = weatherJSONResponse['location']['timezone_id'];
      var icon = [];
      icon.add(weatherJSONResponse['current']['weather_icons'][0].toString());
      _weatherIconLink = icon.isNotEmpty
          ? weatherJSONResponse['current']['weather_icons'][0]
          : '';
      icon.add(weatherJSONResponse['current']['weather_descriptions'][0]);
      _weatherDescription = icon[1] != null
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
        _requestUri = Uri.parse(req);
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
                child: Text(_locationName != null
                    ? 'The weather at $_locationName ($_position)'
                    : '...'),
              ),
              Expanded(
                flex: 1,
                child: Text(
                    _localTime != null ? 'On $_localTime ($_timezone)' : '...'),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView(
            children: [
              ListTile(
                leading: _weatherIconLink != null
                    ? Image.network(_weatherIconLink)
                    : FaIcon(FontAwesomeIcons.cloud),
                title: Text('Weather'),
                subtitle: Text('Weather Code: $_weatherCode'),
                trailing: Text('$_weatherDescription'),
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.city),
                subtitle: Text('$_region'),
                title: Text('Region'),
                trailing: Text('$_country'),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.tachometerAlt),
                subtitle: Text('Air Humidity Level'),
                title: Text('Humidity'),
                trailing: Text('$_humidity' + '%'),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.tachometerAlt),
                subtitle: Text('Air Pressure'),
                title: Text('Pressure'),
                trailing: Text('$_pressure' + 'MB (millibar'),
              ),
              ListTile(
                leading: TempIcon(
                  temp: _temperature,
                ),
                title: Text('Temperature'),
                trailing: Text('$_temperature' + '\u00B0' + 'C'),
              ),
              ListTile(
                // TODO: Find icons & define conditions to use appropriate
                //  icon depending on visibility
                leading: Icon(FontAwesomeIcons.eye),
                title: Text('Visibility'),
                trailing: Text('$_visibility KM'),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.directions),
                title: Text('Wind Direction'),
                trailing: Text('$_windDirection'),
              ),
              ListTile(
                // TODO: Find icons & define conditions to use appropriate
                //  icon depending on visibility
                leading: Icon(FontAwesomeIcons.wind),
                title: Text('Wind Speed'),
                trailing: Text('$_windSpeed KM/hr'),
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
