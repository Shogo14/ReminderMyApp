import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  Reminder(DocumentSnapshot doc) {
    uid = doc['uid'];
    address = doc.id;
    title = doc['title'];
    date = doc['date'];
    shop = doc['shop'];
  }
  String uid;
  String address;
  String title;
  DateTime date;
  String shop;
}
