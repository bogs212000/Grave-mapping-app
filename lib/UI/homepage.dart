// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:grapp/UI/List.dart';
import 'package:grapp/UI/onbording.dart';
import 'package:grapp/UI/usersGuide_onboarding.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

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
  late Position position;
  late double long, lat;
  final List<Marker> _marker = <Marker>[];
  String email = 'maricelatienza405@gmail.com';
  String subject = 'User Feedback';
  String body = 'Hi!';
  bool? maintenance;
  double? iconSize;
  double optionSizeH = 100;
  double optionSizeW = 150;
  double searchSize = 150;
  String search = "";

  @override
  void initState() {
    super.initState();
    checkGps();
    _fetch();
  }

  _fetch() async {
    await FirebaseFirestore.instance
        .collection('App settings')
        .doc("Maintenance")
        .get()
        .then((ds) {
      maintenance = ds.data()!['maintenance'];
    }).catchError((e) {
      print(e);
    });
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
          "Share your feedback about your Grapp App experience; it helps us improve our services."),
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
        backgroundColor: const Color.fromARGB(255, 5, 44, 77),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: 40),
            Padding(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  children: [
                    Text(
                      'Grapp App',
                      style: GoogleFonts.righteous(
                          fontSize: 30, color: Colors.white),
                    ),
                    const Text('Version 1.0.0',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 83, 125, 214))),
                  ],
                )),
            ListTile(
              contentPadding: EdgeInsets.only(left: 15),
              leading: Image.asset(
                "assets/drawer.png",
                scale: 2.8,
              ),
              title: Row(
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
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
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Onbording(),
                  ),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 20),
              leading: const Icon(
                Icons.star,
                color: Color.fromARGB(255, 198, 212, 1),
              ),
              title: Row(
                children: const [
                  Text('Rate us',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
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
              leading: Icon(
                Icons.map,
                color: Colors.white,
              ),
              title: Row(
                children: [
                  Text(
                    'Map type',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
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
                var snackBar =
                    SnackBar(content: Text('Map change to $mapType'));
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
              leading: Icon(
                Icons.book,
                color: Colors.white,
              ),
              title: Row(
                children: [
                  Text(
                    'Terms and Conditions',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Spacer(),
                ],
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showTermsAndConditions(context);
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
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Grave Mapping',
          style: GoogleFonts.righteous(),
        ),
        backgroundColor: const Color.fromARGB(255, 5, 44, 77),
        elevation: 0,
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          GestureDetector(
            child: const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 5, 44, 77),
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 1),
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 5, 44, 77)),
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              height:
                                  search == "" ? optionSizeH : optionSizeH = 50,
                              width: search == ""
                                  ? optionSizeW
                                  : optionSizeH = 100,
                              duration: const Duration(milliseconds: 300),
                              child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  child: Image.asset("assets/listIcon.png")),
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              height:
                                  search == "" ? optionSizeH : optionSizeH = 50,
                              width: search == ""
                                  ? optionSizeW
                                  : optionSizeH = 100,
                              child: AnimatedContainer(
                                  duration: Duration(milliseconds: 400),
                                  child:
                                      Image.asset("assets/feedbackIcon.png")),
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
                          focusColor: Colors.white,
                          hintText: "Search...",
                          suffixIcon: search == ""
                              ? Image.asset(
                                  'assets/searchIcon.png',
                                  scale: 3,
                                )
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
                          fillColor: Colors.white,
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
                                  Image.asset('assets/ghostIcon.png'),
                                  const Text(
                                    'Search now!',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color:
                                            Color.fromARGB(255, 167, 152, 255)),
                                  )
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              height: 550,
                              width: double.infinity,
                              child: StreamBuilder(
                                stream: (search != "")
                                    ? FirebaseFirestore.instance
                                        .collection("Records")
                                        .where("Fullname",
                                            isGreaterThanOrEqualTo: search)
                                        .snapshots()
                                    : FirebaseFirestore.instance
                                        .collection('Recors')
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
                                              baseColor: const Color.fromARGB(
                                                  255, 5, 44, 77),
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
                                              baseColor: const Color.fromARGB(
                                                  255, 5, 44, 77),
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
                                        color: Colors.white,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/graveIcon.png",
                                                    scale: 2.5,
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
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              border: Border.all(
                                                                  color: const Color
                                                                          .fromARGB(
                                                                      255,
                                                                      69,
                                                                      2,
                                                                      124)),
                                                              image:
                                                                  DecorationImage(
                                                                      image:
                                                                          CachedNetworkImageProvider(
                                                                        image
                                                                            .toString(),
                                                                      ),
                                                                      fit: BoxFit
                                                                          .cover),
                                                            ),
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
                                                    ),
                                                    onTap: () {
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
                                                                const SizedBox(
                                                                    height: 5),
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                  height: 300,
                                                                  width: double
                                                                      .infinity,
                                                                  child:
                                                                      GoogleMap(
                                                                    initialCameraPosition: CameraPosition(
                                                                        target: LatLng(
                                                                            lat,
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
                                                                    rotateGesturesEnabled:
                                                                        true,
                                                                    mapType: mapType ==
                                                                            "Satellite"
                                                                        ? MapType
                                                                            .satellite
                                                                        : MapType
                                                                            .normal,
                                                                    trafficEnabled:
                                                                        true,
                                                                  ),
                                                                ),
                                                                const SizedBox(
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

  Future<String> _fetchPage() async {
    // Simulating a delay to fetch the page
    await Future.delayed(Duration(seconds: 2));
    return "https://en.wikipedia.org/";
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
                          initialUrl:
                              'https://www.freeprivacypolicy.com/live/075d8ff8-1760-49b7-878d-d94ee0aac06d',
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
