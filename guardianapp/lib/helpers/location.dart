import 'dart:async';

import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' hide Location;

Future<LocationData> fetchLocation() async {
  Location location = Location();

  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;

  location.enableBackgroundMode(enable: true);

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {}
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {}
  }

  locationData = await location.getLocation();

  return locationData;
}

Future<List<Placemark>> getAddress(double? lat, double? lang) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lat!, lang!);
  return placemarks;
}

Future<List<Object>> obtainLocation() async {
  List<Object> address = [];
  LocationData locationData;
  List<Placemark> placemarks;
  Placemark placemark;
  String currentAddress;

  locationData = await fetchLocation();
  placemarks = await getAddress(locationData.latitude, locationData.longitude);
  placemark = placemarks.first;
  currentAddress =
      '${placemark.street}, ${placemark.subLocality}, ${placemark.locality},';

  address.add(locationData.latitude!);
  address.add(locationData.longitude!);
  address.add(currentAddress);

  return address;
}
