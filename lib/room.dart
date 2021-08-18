import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Room {
  String? roomNo;
  String? type;
  bool? isBooked;
  String? keys;

  Room(
      {required this.roomNo,
      required this.type,
      required this.isBooked,
      this.keys});
}
