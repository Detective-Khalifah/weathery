import 'package:geolocator/geolocator.dart';
import 'package:weathery/constants.dart';

late bool permissionGranted;
late double _latitude = 0, _longitude = 0;
late String req = '';

Future getLocationAccess() async {
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

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> getDeviceLocation() async {
  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low);
  _latitude = pos.latitude;
  _longitude = pos.longitude;
  req =
      'http://api.weatherstack.com/current?access_key=d1a39645995e0c8a2088f7be4c81da2c&query=$_latitude,$_longitude&units=$kUnitType';
  return pos;
}
