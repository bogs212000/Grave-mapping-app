import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grapp/UI/const/const.dart';
import 'package:grapp/UI/homepage.dart';

class Show extends StatefulWidget {
  const Show({super.key});

  @override
  State<Show> createState() => _ShowState();
}

class _ShowState extends State<Show> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$showfullname'),
        foregroundColor: Color.fromARGB(255, 5, 44, 77),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    decoration:
                    BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    height:
                    500,
                    width: double
                        .infinity,
                    child:
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng(showlat!,
                              showlong!),
                          zoom:
                          30),
                      markers: (showlong !=
                          null)
                          ? {
                        Marker(
                          markerId: const MarkerId('graveMarker'),
                          position: LatLng(showlat!, showlong!),
                          infoWindow: InfoWindow(title: showfullname),
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
                    SizedBox(width: 10),
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
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
