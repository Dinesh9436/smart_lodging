import 'dart:math';

import 'package:firebase_database/firebase_database.dart';

class BackendService {
  List<String> names = [];

  List<dynamic> getSuggestions(String query) {
    var db = FirebaseDatabase.instance.reference().child("passengers");
    db.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, val) {
        names=val["name"];
        print(val['name']);
      });
    });
    print(names);
    return names.where((user) {
      final userLower = user.toLowerCase();
      final queryLower = query.toLowerCase();

      return userLower.contains(queryLower);
    }).toList();
  }
}
