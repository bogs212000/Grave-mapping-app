import 'package:geolocator/geolocator.dart';

bool? maintenance;
String? termsAndConditions;
String? feedback;
bool servicestatus = false;
bool haspermission = false;
late LocationPermission permission;
Position? _currentPosition;
double? showlat;
double? showlong;
String? showfullname;
String? showimage;