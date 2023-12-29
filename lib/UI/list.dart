// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grapp/UI/showdata/show.dart';
import 'package:grapp/UI/showdata/show.image.dart';
import 'package:shimmer/shimmer.dart';

import 'const/const.dart';
import 'homepage.dart';

String sortBy = "Fullname";

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  static String id = "ListPage";

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  TextEditingController search2Controller = TextEditingController();
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          foregroundColor: Colors.blue[200],
          title: Row(
            children: [
              const Text(
                "Sort by: ",
                style: TextStyle(fontSize: 15),
              ),
              DropdownButton<String>(
                dropdownColor: Colors.blue[100],
                value: dropdownValue,
                icon: const Icon(Icons.sort),
                elevation: 15,
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
              Spacer(),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 40,
                width: search == "" ? 100 : 120,
                child: TextFormField(
                  controller: search2Controller,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) {
                    setState(() {
                      search = value;
                    });
                  },
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    focusColor: Colors.blue.shade50,
                    hintText: "Search...",
                    suffixIcon: search == ""
                        ? Icon(Icons.search)
                        : GestureDetector(
                            onTap: () {
                              search2Controller.clear();
                              setState(() {
                                search = "";
                              });
                            },
                            child: Icon(
                              Icons.cancel_outlined,
                              color: Colors.grey,
                            ),
                          ),
                    filled: true,
                    fillColor: Colors.blue.shade50,
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
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: StreamBuilder(
          stream: (search != "")
              ? FirebaseFirestore.instance
                  .collection("Records")
                  .where("Fullname", isGreaterThanOrEqualTo: search)
                  .where("Fullname", isLessThan: search + 'z')
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
              return Center(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("We couldn't find any records matching your search."),
              ));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) => Shimmer.fromColors(
                    baseColor: Colors.blue.shade50,
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
                                    color: Colors.blue.shade900,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      showimage = image;
                                      showfullname = fullname;
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ShowImage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  child: Image.asset(
                                    "assets/locationIcon.png",
                                    scale: 2.4,
                                    color: Colors.blue.shade900,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      showlat = lat;
                                      showlong = long;
                                      showfullname = fullname;
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Show(),
                                      ),
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
