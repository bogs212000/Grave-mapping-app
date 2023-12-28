// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, duplicate_ignore

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grapp/UI/List.dart';
import 'package:grapp/UI/onbording.dart';
import 'package:grapp/UI/usersGuide_onboarding.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';
import 'const/const.dart';
import 'function/fetch.dart';

bool animate = false;
double? la, lo;
String? name;
String? mapType = "Satellite";
final TextEditingController searchController = TextEditingController();

class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  Position? _currentPosition;
  late final double long;
  late final double lat;
  final List<Marker> _marker = <Marker>[];
  late List<LatLng> polylineCoordinates = [];
  String email = 'maricelatienza405@gmail.com';
  String subject = 'User Feedback';
  String body = 'Hi!';
  double? iconSize;
  double optionSizeH = 100;
  double optionSizeW = 150;
  double searchSize = 150;
  String search = "";
  String? address;
  late Position position;
  double? userLat;
  double? userlong;

  @override
  void initState() {
    super.initState();
    _getPolylineCoordinates();
    checkGps();
    fetch();
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457

    userlong = position.longitude as double;
    userLat = position.latitude as double;

    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best, //accuracy of the location data
      distanceFilter: 50, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude as double;
      lat = position.latitude as double;
      lat as double;
      long as double;
    });
    List<Placemark> newPlace =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      Placemark placeMark = newPlace[0];
      String? name = placeMark.name.toString();
      String? subLocality = placeMark.subLocality.toString();
      String? locality = placeMark.locality.toString();
      String? administrativeArea = placeMark.administrativeArea.toString();
      String? postalCode = placeMark.postalCode.toString();
      String? baranggay = placeMark.isoCountryCode.toString();
      address =
          "${name}, ${subLocality}, ${locality}, ${administrativeArea}, ${postalCode}";
    });
  }

  Future<void> _getPolylineCoordinates() async {
    try {
      const apiKey =
          'AIzaSyCUegYnMbLnRL8dpNiQpRZoATOc6e-W3GA'; // Replace with your actual API key
      final start = '${userLat},${userlong}';
      final end = '$lat,$long';

      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=$start&destination=$end&key=$apiKey';

      Response response = await Dio().get(url);

      if (response.statusCode == 200) {
        List<PointLatLng> result = PolylinePoints().decodePolyline(
            response.data['routes'][0]['overview_polyline']['points']);
        List<LatLng> points = result
            .map((PointLatLng point) => LatLng(point.latitude, point.longitude))
            .toList();

        setState(() {
          polylineCoordinates = points;
        });
      } else {
        throw Exception('Failed to load polyline coordinates');
      }
    } catch (e) {
      print('Error fetching polyline coordinates: $e');
    }
  }


  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () async {
        String emailUrl = "mailto:$email?subject=$subject&body=$body";

        if (await canLaunch(emailUrl)) {
          await launch(emailUrl);
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          throw "Error occured sending an email";
        }
      },
    );
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Feedback"),
      content: Text(
          "Share your feedback about your Grave Mapping App experience; it helps us to improve our service."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: 40),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Image.asset('assets/cemetery.png',
                      scale: 3, color: Colors.blue[900]),
                  const Text(
                    'Grave Mapping',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Column(
                    children: [
                      Icon(Icons.dark_mode, color: Colors.white),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  )
                ],
              ),
            ),

            ListTile(
              contentPadding: EdgeInsets.only(left: 20),
              leading: Icon(Icons.map, color: Colors.blue[800]),
              title: Row(
                children: [
                  Text('Map type'),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      mapType.toString(),
                      style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey),
                    ),
                  ),
                ],
              ),
              onTap: () {
                var snackBar = SnackBar(content: Text('Map type changed'));
                if (mapType == "Satellite") {
                  setState(() {
                    mapType = "Normal";
                  });

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  Navigator.of(context).pop();
                } else if (mapType == "Normal") {
                  setState(() {
                    mapType = "Satellite";
                  });
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  Navigator.of(context).pop();
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 20),
              leading: Icon(Icons.book, color: Colors.blue[800]),
              title: Row(
                children: [
                  Text(
                    'Terms and Conditions',
                  ),
                  Spacer(),
                ],
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showTermsAndConditions(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 20),
              leading: const Icon(
                Icons.star,
                color: Colors.yellow,
              ),
              title: Row(
                children: const [
                  Text('Rate us'),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      "Coming soon!",
                      style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey),
                    ),
                  ),
                ],
              ),
              onTap: () {},
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 20),
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: Row(
                children: const [
                  Text('Sign out'),
                  Spacer(),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Sign out?'),
                      content: Text(
                          'Are you sure you want to Sign out?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {

                            Navigator.pop(context);
                          },
                          child: Text('cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                          },
                          child: Text('ok'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            // ListTile(
            //   contentPadding: EdgeInsets.only(left: 20),
            //   leading: Icon(
            //     Icons.dark_mode,
            //     color: Colors.white,
            //   ),
            //   title: Row(
            //     children: [
            //       Text(
            //         'Dark Mode',
            //         style: TextStyle(
            //             fontWeight: FontWeight.bold, color: Colors.white),
            //       ),
            //       Spacer(),Padding(
            //         padding: EdgeInsets.only(right: 20),
            //         child: Text(
            //          "Coming soon!",
            //           style: TextStyle(
            //               fontSize: 10,
            //               fontStyle: FontStyle.italic,
            //               color: Colors.grey),
            //         ),
            //       ),
            //     ],
            //   ),
            //   onTap: () {},
            // ),
          ],
        ),
      ),
      appBar: AppBar(
        foregroundColor: Color.fromARGB(255, 5, 44, 77),
        title: Text(
          'Grave Mapping',
          style: GoogleFonts.righteous(color: Color.fromARGB(255, 5, 44, 77),),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          GestureDetector(
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Center(
                child: Icon(
                  Ionicons.help_circle_outline,
                  size: 30,
                ),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => UsersGuideOnbording(),
                ),
              );
            },
          )
        ],
      ),
      body: maintenance != true
          ? Container(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 1),
              decoration: const BoxDecoration(color: Colors.white),
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                physics: search == ""
                    ? BouncingScrollPhysics()
                    : NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          GestureDetector(
                            child: AnimatedContainer(
                              curve: Curves.easeIn,
                              decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(20)),
                              height: search == ""
                                  ? optionSizeH = 100
                                  : optionSizeW = 0,
                              width: search == ""
                                  ? optionSizeH = 150
                                  : optionSizeW = 0,
                              duration: const Duration(milliseconds: 300),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.blue.shade100,
                                        Colors.blue.shade800,
                                      ],
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.srcATop,
                                  child: Image.asset(
                                    "assets/cemetery.png",
                                    width: 200,
                                    height: 200,
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                animate = true;
                              });
                              Navigator.of(context).pushAndRemoveUntil(
                                  _listPage(), (route) => true);
                            },
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(20)),
                              height: search == ""
                                  ? optionSizeH = 100
                                  : optionSizeH = 0,
                              width: search == ""
                                  ? optionSizeH = 150
                                  : optionSizeW = 0,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 400),
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.blue.shade100,
                                        Colors.blue.shade800,
                                      ],
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.srcATop,
                                  child: Image.asset(
                                    "assets/feedbackIcon.png",
                                    width: 200,
                                    height: 200,
                                  ),
                                ),
                              ),
                            ),
                            onTap: () async {
                              showAlertDialog(context);
                            },
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      height: search == "" ? 40 : 50,
                      width: double.infinity,
                      child: TextFormField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            search = value;
                          });
                        },
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          focusColor: Colors.blue[200],
                          hintText: "Search...",
                          suffixIcon: search == ""
                              ? Icon(Icons.search)
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      searchController.clear();
                                      search = "";
                                    });
                                  },
                                  child: Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                          filled: true,
                          fillColor: Colors.blue[50],
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:
                                  const BorderSide(color: Colors.white)),
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    search == ""
                        ? SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 20,
                                        right: 20,
                                        bottom: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                'assets/icons8-place-marker-96.png',
                                                scale: 3),
                                            SizedBox(width: 5),
                                            Text('Search Now!')
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        const Text(
                                          "       Please make sure you have a strong internet connection to use the app properly.",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 5, 44, 77)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              height: 600,
                              width: double.infinity,
                              child: StreamBuilder(
                                stream: (search != "")
                                    ? FirebaseFirestore.instance
                                        .collection("Records")
                                        .where("Fullname",
                                            isGreaterThanOrEqualTo: search)
                                        .snapshots()
                                    : FirebaseFirestore.instance
                                        .collection('Records')
                                        .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          "Somthing went wrong!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        )
                                      ],
                                    );
                                  } else if (snapshot.hasData == false) {
                                    return ListView.builder(
                                      itemCount: 5,
                                      itemBuilder: (context, index) =>
                                          Shimmer.fromColors(
                                              baseColor: Colors.blue.shade50,
                                              highlightColor: Colors.white,
                                              child: Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  height: 100,
                                                  width: double.infinity,
                                                ),
                                              )),
                                    );
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return ListView.builder(
                                      itemCount: 5,
                                      itemBuilder: (context, index) =>
                                          Shimmer.fromColors(
                                              baseColor: Colors.blue.shade50,
                                              highlightColor: Colors.white,
                                              child: Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  height: 100,
                                                  width: double.infinity,
                                                ),
                                              )),
                                    );
                                  } else if (!snapshot.hasData) {
                                    return SizedBox(
                                      height: 200,
                                      width: double.infinity,
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Image.asset('assets/ghostIcon.png'),
                                            const Text(
                                              'Search now!',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Color.fromARGB(
                                                    255, 167, 152, 255),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.data?.size == 0) {
                                    return Column(
                                      children: [
                                        Image.asset("assets/errorIcon.png")
                                      ],
                                    );
                                  }
                                  Row(children: const [
                                    TextField(
                                      decoration: InputDecoration(),
                                    )
                                  ]);
                                  return ListView(
                                    physics: BouncingScrollPhysics(),
                                    children: snapshot.data!.docs
                                        .map((DocumentSnapshot document) {
                                      Map<String, dynamic> data = document
                                          .data()! as Map<String, dynamic>;
                                      String? image = data["image"];
                                      String? fullname = data["Fullname"];
                                      String? birth = data["Date of Birth"];
                                      String? death = data["Date of Death"];
                                      double lat = data["lat"];
                                      double long = data["long"];

                                      // bool isMatch = search.isNotEmpty &&
                                      //     fullname != null &&
                                      //     fullname
                                      //         .toLowerCase()
                                      //         .contains(search.toLowerCase());

                                      // TextSpan nameSpan = TextSpan(
                                      //   text: fullname ?? '',
                                      //   style: GoogleFonts.poppins(
                                      //     fontSize: 20,
                                      //     fontWeight: FontWeight.bold,
                                      //     backgroundColor: isMatch
                                      //         ? Colors.yellow.withOpacity(
                                      //             0.3) // Highlight color for the matched text
                                      //         : null,
                                      //   ),
                                      // );

                                      _marker.add(
                                        Marker(
                                          markerId: const MarkerId(""),
                                          position: LatLng(lat, long),
                                          infoWindow:
                                              InfoWindow(title: "$fullname"),
                                        ),
                                      );

                                      return Card(
                                        shadowColor: const Color.fromARGB(
                                            255, 34, 34, 34),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        color: Colors.blue.shade50,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/graveIcon.png",
                                                    scale: 2.5,
                                                    color: Colors.blue.shade900,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Date of birth: $birth",
                                                            style: GoogleFonts
                                                                .robotoMono(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Date of death: $death",
                                                            style: GoogleFonts
                                                                .robotoMono(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              // RichText(
                                              //   text: TextSpan(
                                              //     children: [nameSpan],
                                              //   ),
                                              // ),
                                              Text(
                                                data['Fullname'],
                                                style: GoogleFonts.poppins(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const Divider(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  GestureDetector(
                                                    child: Image.asset(
                                                      "assets/imageIcon.png",
                                                      scale: 2.4,
                                                      color:
                                                          Colors.blue.shade900,
                                                    ),
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (context) =>
                                                            Center(
                                                          child: (Container(
                                                            height: 400,
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: const Color
                                                                              .fromARGB(
                                                                          255,
                                                                          69,
                                                                          2,
                                                                          124),
                                                                    ),
                                                                    image: DecorationImage(
                                                                        image: CachedNetworkImageProvider(
                                                                          image
                                                                              .toString(),
                                                                        ),
                                                                        fit: BoxFit.cover)),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    GestureDetector(
                                                                        child: Image
                                                                            .asset(
                                                                          "assets/cancelIcon.png",
                                                                          color: Colors
                                                                              .blue
                                                                              .shade900,
                                                                          scale:
                                                                              3,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          navigatorKey
                                                                              .currentState!
                                                                              .popUntil((route) => route.isFirst);
                                                                        })
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          )),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 10),
                                                  GestureDetector(
                                                    child: Image.asset(
                                                      "assets/locationIcon.png",
                                                      scale: 2.4,
                                                      color:
                                                          Colors.blue.shade900,
                                                    ),
                                                    onTap: () {
                                                      _getPolylineCoordinates();
                                                      showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (context) =>
                                                            Center(
                                                          child: (Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            height: 500,
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: const Color
                                                                              .fromARGB(
                                                                          255,
                                                                          69,
                                                                          2,
                                                                          124),
                                                                    ),
                                                                    color: Colors
                                                                        .white),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    GestureDetector(
                                                                        child: Image
                                                                            .asset(
                                                                          "assets/cancelIcon.png",
                                                                          scale:
                                                                              3,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          navigatorKey
                                                                              .currentState!
                                                                              .popUntil((route) => route.isFirst);
                                                                        }),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    height: 5),
                                                                Stack(
                                                                  children: [
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                      ),
                                                                      height:
                                                                          300,
                                                                      width: double
                                                                          .infinity,
                                                                      child:
                                                                          GoogleMap(
                                                                        initialCameraPosition: CameraPosition(
                                                                            target: LatLng(lat,
                                                                                long),
                                                                            zoom:
                                                                                30),
                                                                        markers: (long !=
                                                                                null)
                                                                            ? {
                                                                                Marker(
                                                                                  markerId: const MarkerId('graveMarker'),
                                                                                  position: LatLng(lat, long),
                                                                                  infoWindow: InfoWindow(title: fullname),
                                                                                )
                                                                              }
                                                                            : Set(),
                                                                        zoomControlsEnabled:
                                                                            true,
                                                                        zoomGesturesEnabled:
                                                                            true,
                                                                        tiltGesturesEnabled:
                                                                            true,
                                                                        scrollGesturesEnabled:
                                                                            true,
                                                                        myLocationEnabled:
                                                                            true,
                                                                        rotateGesturesEnabled:
                                                                            true,
                                                                        mapType: mapType ==
                                                                                "Satellite"
                                                                            ? MapType.satellite
                                                                            : MapType.normal,
                                                                        trafficEnabled:
                                                                            true,
                                                                        polylines: {
                                                                          Polyline(
                                                                            polylineId:
                                                                                PolylineId('polyline_id'),
                                                                            color:
                                                                                Colors.blue,
                                                                            width:
                                                                                5,
                                                                            points:
                                                                                polylineCoordinates,
                                                                          ),
                                                                        },
                                                                      ),
                                                                    ),
                                                                    // GestureDetector(
                                                                    //   onTap:
                                                                    //       () async {
                                                                    //         final Uri _url = Uri.parse('https://www.google.com/maps/dir//$lat,$long/17z');
                                                                    //         if (!await launchUrl(_url)) {
                                                                    //         throw Exception('Could not launch $_url');
                                                                    //         }
                                                                    //       },
                                                                    //   child:
                                                                    //       Row(
                                                                    //     mainAxisAlignment:
                                                                    //         MainAxisAlignment.end,
                                                                    //     children: [
                                                                    //       Padding(
                                                                    //         padding:
                                                                    //             EdgeInsets.all(5),
                                                                    //         child:
                                                                    //             Icon(Icons.directions, size: 30, color: Colors.blue),
                                                                    //       ),
                                                                    //     ],
                                                                    //   ),
                                                                    // )
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  physics:
                                                                      const BouncingScrollPhysics(),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        padding:
                                                                            const EdgeInsets.all(10),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: const Color.fromARGB(
                                                                              255,
                                                                              203,
                                                                              232,
                                                                              255),
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                        ),
                                                                        height:
                                                                            130,
                                                                        width:
                                                                            200,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Image.asset(
                                                                                  'assets/helpIcon.png',
                                                                                  scale: 3,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            const Text(
                                                                              "       Please make sure you have a strong internet connection to use the app properly.",
                                                                              style: TextStyle(color: Color.fromARGB(255, 5, 44, 77)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              20),
                                                                      Container(
                                                                        padding:
                                                                            const EdgeInsets.all(10),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: const Color.fromARGB(
                                                                              255,
                                                                              203,
                                                                              232,
                                                                              255),
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                        ),
                                                                        height:
                                                                            130,
                                                                        width:
                                                                            200,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Image.asset(
                                                                                  'assets/locationIcon.png',
                                                                                  scale: 3,
                                                                                )
                                                                              ],
                                                                            ),
                                                                            const Text(
                                                                              "       To navigate to the grave, click the location icon on the Google map and then the direction icon at the bottom.",
                                                                              style: TextStyle(color: Color.fromARGB(255, 5, 44, 77)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              20),
                                                                      Container(
                                                                        padding:
                                                                            const EdgeInsets.all(10),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: const Color.fromARGB(
                                                                              255,
                                                                              203,
                                                                              232,
                                                                              255),
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                        ),
                                                                        height:
                                                                            130,
                                                                        width:
                                                                            200,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Image.asset(
                                                                                  'assets/imageIcon.png',
                                                                                  scale: 3,
                                                                                )
                                                                              ],
                                                                            ),
                                                                            const Text(
                                                                              "       View the provided grave image for more details.",
                                                                              style: TextStyle(color: Color.fromARGB(255, 5, 44, 77)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            )
          : Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 5, 44, 77),
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/errorIcon.png"),
                    Text(
                      "Under maintenance!",
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        color: Color.fromARGB(255, 165, 192, 250),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Route _listPage() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, anotherAnimation) => const ListPage(),
      transitionDuration: const Duration(milliseconds: 1000),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, anotherAnimation, child) {
        animation = CurvedAnimation(
            parent: animation,
            reverseCurve: Curves.fastOutSlowIn,
            curve: Curves.fastLinearToSlowEaseIn);

        return SlideTransition(
          position: Tween(
            begin: const Offset(1.0, 0.0),
            end: const Offset(0.0, 0.0),
          ).animate(animation),
          child: const ListPage(),
        );
      },
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.cancel_outlined))
                  ],
                ),
                SizedBox(height: 20.0),
                Container(
                  height: 400,
                  child: FutureBuilder(
                    future: Future.delayed(Duration(seconds: 2), () {}),
                    // Simulate a delay
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // While fetching the web page, display a loading screen
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return WebView(
                          initialUrl: termsAndConditions ??
                              'https://www.freeprivacypolicy.com/live/e7a77442-c30d-4e94-a27c-4bfda170cba2',
                          // Set the URL you want to display
                          javascriptMode: JavascriptMode.unrestricted,
                          onWebResourceError:
                              (WebResourceError webResourceError) {
                            // Handle the error here, e.g., display an error message.
                            print('Web Error: ${webResourceError.description}');
                          }, // Enable JavaScript
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
