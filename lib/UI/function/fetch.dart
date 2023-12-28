import 'package:cloud_firestore/cloud_firestore.dart';

import '../const/const.dart';

void fetch() async {
  await FirebaseFirestore.instance
      .collection('App settings')
      .doc("Maintenance")
      .get()
      .then((ds) {
    maintenance = ds.data()!['maintenance'];
    termsAndConditions = ds.data()!['link terms and conditions'];
    feedback = ds.data()!['feedback'];
  }).catchError((e) {
    print(e);
  });
}