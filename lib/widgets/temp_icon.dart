import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TempIcon extends StatelessWidget {
  final double temp;

  const TempIcon({Key? key, required this.temp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (temp.toInt()) {
      case 100:
        return Icon(FontAwesomeIcons.thermometerFull);
      case 75:
        return Icon(FontAwesomeIcons.thermometerThreeQuarters);
      case 50:
        return Icon(FontAwesomeIcons.thermometerHalf);
      case 25:
        return Icon(FontAwesomeIcons.thermometerQuarter);
      case 0:
        return Icon(FontAwesomeIcons.thermometerEmpty);
      default:
        if (temp >= 40)
          return Icon(FontAwesomeIcons.temperatureHigh);
        else if (temp < 40 && temp > 0)
          return Icon(FontAwesomeIcons.temperatureLow);
        else
          /*(temp < 0) */ return Icon(FontAwesomeIcons.thermometerEmpty);
    }
  }
}
