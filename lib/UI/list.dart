// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';

import 'homepage.dart';

String sortBy = "Fullname";

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  static String id = "ListPage";

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late TabController _tabController;
  final Completer<GoogleMapController> _controller = Completer();
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  late double long, lat;
  List<Marker> _marker = <Marker>[];
  String dropdownValue = "Name";
  List<String> list = ["Name", "Birth", "Death"];
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 5, 44, 77),
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                "Sort by: ",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              DropdownButton<String>(
                dropdownColor: const Color.fromARGB(255, 5, 44, 77),
                value: dropdownValue,
                icon: const Icon(
                  Icons.sort,
                  color: Colors.white,
                ),
                elevation: 16,
                style: const TextStyle(color: Colors.white),
                underline: Container(
                  height: 2,
                  color: Colors.white,
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownValue = value!;
                  });
                  if (value == "Birth") {
                    setState(() {
                      sortBy = "birth";
                    });
                  } else if (value == "Name") {
                    setState(() {
                      sortBy = "Fullname";
                    });
                  } else {
                    setState(() {
                      sortBy = "sortBydeath";
                    });
                  }
                },
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(width: 5),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 40,
                width: search == "" ? 100 : 120,
                child: TextFormField(
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) {
                    setState(() {
                      search = value;
                    });
                  },
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    focusColor: Colors.white,
                    hintText: "Search...",
                    suffixIcon: Image.asset(
                      'assets/searchIcon.png',
                      scale: 3,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: const BorderSide(color: Colors.white)),
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(40.0)),
                  ),
                ),
              )
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 5, 44, 77),
          elevation: 0,
          actions: [],
        ),
        body: StreamBuilder(
          stream: (search != "")
              ? FirebaseFirestore.instance
              .collection("Records")
              .where("Fullname", isGreaterThanOrEqualTo: search)
              .snapshots()
              : FirebaseFirestore.instance
              .collection('Records')
              .orderBy("$sortBy")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Somthing went wrong!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 231, 25, 25),
                    ),
                  )
                ],
              );
            } else if (snapshot.data?.size == 0) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Image.asset("assets/errorIcon.png")],
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) =>
                    Shimmer.fromColors(
                        baseColor: Color.fromARGB(255, 5, 44, 77),
                        highlightColor: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20)),
                            height: 100,
                            width: double.infinity,
                          ),
                        )),
              );
            }
            Row(children: const [
              TextField(
                decoration: InputDecoration(),
              )
            ]);
            return ListView(
              physics: const BouncingScrollPhysics(),
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
                String? image = data["image"];
                String? fullname = data["Fullname"];
                String? birth = data["Date of Birth"];
                String? death = data["Date of Death"];
                double lat = data["lat"];
                double long = data["long"];
                _marker.add(Marker(
                    markerId: const MarkerId(""),
                    position: LatLng(lat, long),
                    infoWindow: InfoWindow(title: "$fullname")));

                return Padding(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: Card(
                      shadowColor: const Color.fromARGB(255, 34, 34, 34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
                                          style: GoogleFonts.robotoMono(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Date of death: $death",
                                          style: GoogleFonts.robotoMono(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                            Text(
                              data['Fullname'],
                              style: GoogleFonts.poppins(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  child: Image.asset(
                                    "assets/imageIcon.png",
                                    scale: 2.4,
                                  ),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          Center(
                                              child: (Container(
                                                height: 400,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(20),
                                                    border: Border.all(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 69, 2, 124)),
                                                    image: DecorationImage(
                                                        image: CachedNetworkImageProvider(
                                                            image.toString()),
                                                        fit: BoxFit.cover)),
                                                child: Column(children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                          child: Image.asset(
                                                            "assets/cancelIcon.png",
                                                            scale: 3,
                                                          ),
                                                          onTap: () {
                                                            Navigator.of(context)
                                                                .pop();
                                                          })
                                                    ],
                                                  )
                                                ]),
                                              ))),
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
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          Center(
                                              child: (Container(
                                                padding: const EdgeInsets.all(10),
                                                height: 500,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(20),
                                                    border: Border.all(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 69, 2, 124)),
                                                    color: Colors.white),
                                                child: Column(children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                          child: Image.asset(
                                                            "assets/cancelIcon.png",
                                                            scale: 3,
                                                          ),
                                                          onTap: () {
                                                            Navigator.of(context)
                                                                .pop();
                                                          }),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                      height: 300,
                                                      width: double.infinity,
                                                      child: GoogleMap(
                                                          initialCameraPosition:
                                                          CameraPosition(
                                                              target: LatLng(
                                                                  lat, long),
                                                              zoom: 30),
                                                          markers: (lat != null &&
                                                              long != null) ? {
                                                            Marker(
                                                              markerId: const MarkerId(
                                                                  'graveMarker'),
                                                              position: LatLng(
                                                                  lat, long),

                                                              infoWindow: InfoWindow(
                                                                  title: fullname),
                                                            )
                                                          }
                                                              : Set(),
                                                          zoomControlsEnabled: true,
                                                          zoomGesturesEnabled: true,
                                                          tiltGesturesEnabled:
                                                          true,
                                                          scrollGesturesEnabled: true,
                                                          rotateGesturesEnabled: true,
                                                          mapType: mapType == "Satellite"
                                                          ? MapType.satellite
                                                          : MapType.normal,
                                                      trafficEnabled: true,
                                                      ),),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  SingleChildScrollView(
                                                    scrollDirection: Axis
                                                        .horizontal,
                                                    physics:
                                                    const BouncingScrollPhysics(),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                          decoration: BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255, 203, 232,
                                                                  255),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  20)),
                                                          height: 130,
                                                          width: 200,
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Image.asset(
                                                                    'assets/helpIcon.png',
                                                                    scale: 3,
                                                                  )
                                                                ],
                                                              ),
                                                              const Text(
                                                                "       Please make sure you have a strong internet connection to use the app properly.",
                                                                style: TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                        255, 5,
                                                                        44, 77)),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 20),
                                                        Container(
                                                          padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                          decoration: BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255, 203, 232,
                                                                  255),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  20)),
                                                          height: 130,
                                                          width: 200,
                                                          child: Column(
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
                                                                style: TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                        255, 5,
                                                                        44, 77)),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 20),
                                                        Container(
                                                          padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                          decoration: BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255, 203, 232,
                                                                  255),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  20)),
                                                          height: 130,
                                                          width: 200,
                                                          child: Column(
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
                                                                style: TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                        255, 5,
                                                                        44, 77)),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ]),
                                              ))),
                                    );
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      )),
                );
              }).toList(),
            );
          },
        ));
  }
}
