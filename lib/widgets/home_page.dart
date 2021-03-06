import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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
      _latitude = 0,
      _longitude = 0,
      _pressure = 0,
      _temperature = 0,
      _visibility = 0,
      _utcOffset,
      _windSpeed = 0;
  int _weatherCode = 0;
  var _clarity,
      _country,
      _isDay,
      _localTime,
      _region,
      _timezone,
      _weatherIconLink,
      _weatherDescription,
      _windDirection;
  late Color? _deetCardsColour = Colors.white;
  late Color? _highlightCardColour = Colors.white;

  Future _requestAndParseWeatherData() async {
    Response rawResponse = await get(_requestUri);
    var weatherJSONResponse = jsonDecode(rawResponse.body);

    setState(() {
      // num variables
      _humidity = weatherJSONResponse['current']['humidity'];
      _latitude = double.parse(weatherJSONResponse['location']['lat']);
      _longitude = double.parse(weatherJSONResponse['location']['lon']);
      _pressure = weatherJSONResponse['current']['pressure'];
      _temperature = weatherJSONResponse['current']['temperature'];
      _utcOffset = double.parse(weatherJSONResponse['location']['utc_offset']);
      _visibility = weatherJSONResponse['current']['visibility'];
      _weatherCode = weatherJSONResponse['current']['weather_code'];
      _windSpeed = weatherJSONResponse['current']['wind_speed'];
      _windDirection = weatherJSONResponse['current']['wind_dir'];

      // String variables
      _country = weatherJSONResponse['location']['country'];
      _isDay = weatherJSONResponse['current']['is_day'];
      _localTime = weatherJSONResponse['location']['localtime'];
      _region = weatherJSONResponse['location']['region'];
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

      switch (_isDay.toString()) {
        case "no": // nighttime
          _highlightCardColour = Color(0xFF3864B2);
          Color(0xFF1C82FF);
          _deetCardsColour = Color(0xFF8996C4);
          break;
        case "yes": // daytime
          _highlightCardColour = Color(0xFFE6830C);
          _deetCardsColour = Color(0xFFECB425);
          break;
      }

      if (_visibility > 5)
        _clarity = 'clear';
      else if (_visibility <= 5 && _visibility >= 2)
        _clarity = 'haze';
      else if (_visibility <= 2 && _visibility >= 1)
        _clarity = 'mist';
      else
        _clarity = 'fog';
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
        Card(
          color: _highlightCardColour,
          elevation: 6,
          margin: EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Container(
            height: MediaQuery.of(context).size.height / 5,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _latitude.toString().isNotEmpty &&
                          _longitude.toString().isNotEmpty
                      ? 'The weather conditions at your location: ($_latitude, $_longitude)'
                      : '...',
                  style: GoogleFonts.acme(
                      fontSize: 32, fontStyle: FontStyle.normal),
                ),
                Text(
                  _localTime != null
                      ? "On $_localTime ($_timezone) UTC ${_utcOffset > 0 ? '+$_utcOffset' : '-$_utcOffset'}"
                      : '...',
                  style: GoogleFonts.acme(
                      fontSize: 20, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView(
            children: [
              Card(
                child: ListTile(
                  leading: _weatherIconLink != null
                      ? Image.network(_weatherIconLink)
                      : FaIcon(FontAwesomeIcons.cloud),
                  title: Text('Weather'),
                  subtitle: Text('Weather Code: $_weatherCode'),
                  trailing: Text('$_weatherDescription'),
                ),
                color: _deetCardsColour,
              ),
              Card(
                child: ListTile(
                  leading: FaIcon(FontAwesomeIcons.city),
                  subtitle: Text('$_region'),
                  title: Text('Region'),
                  trailing: Text('$_country'),
                ),
                color: _deetCardsColour,
              ),
              Card(
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.tachometerAlt),
                  subtitle: Text('Air Humidity Level'),
                  title: Text('Humidity'),
                  trailing: Text('$_humidity' + '%'),
                ),
                color: _deetCardsColour,
              ),
              Card(
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.tachometerAlt),
                  subtitle: Text('Air Pressure'),
                  title: Text('Pressure'),
                  trailing: Text('$_pressure' + 'MB (millibar)'),
                ),
                color: _deetCardsColour,
              ),
              Card(
                child: ListTile(
                  leading: TempIcon(
                    temp: _temperature,
                  ),
                  title: Text('Temperature'),
                  trailing: Text('$_temperature' + '\u00B0' + 'C'),
                ),
                color: _deetCardsColour,
              ),
              Card(
                child: ListTile(
                  // TODO: Find icons & define conditions to use appropriate
                  //  icon depending on visibility
                  leading: Icon(FontAwesomeIcons.eye),
                  title: Text('Visibility'),
                  subtitle: Text('$_clarity'),
                  trailing: Text('$_visibility KM'),
                ),
                color: _deetCardsColour,
              ),
              Card(
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.directions),
                  title: Text('Wind Direction'),
                  trailing: Text('$_windDirection'),
                ),
                color: _deetCardsColour,
              ),
              Card(
                child: ListTile(
                  // TODO: Find icons & define conditions to use appropriate
                  //  icon depending on visibility
                  leading: Icon(FontAwesomeIcons.wind),
                  title: Text('Wind Speed'),
                  trailing: Text('$_windSpeed KM/hr'),
                ),
                color: _deetCardsColour,
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _requestAndParseWeatherData,
                child: Text(
                  'Reload',
                  style: GoogleFonts.rockSalt(
                      color: Colors.blueGrey, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
