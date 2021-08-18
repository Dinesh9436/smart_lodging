import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lodging/home.dart';
import 'package:lodging/pessengers.dart';
import 'package:list_ext/list_ext.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewTransaction extends StatefulWidget {
  final String? orderKey;

  ViewTransaction({
    this.orderKey,
  });
  @override
  _ViewTransactionState createState() => new _ViewTransactionState();
}

class _ViewTransactionState extends State<ViewTransaction> {
  TextEditingController controller = new TextEditingController();
  final databaseRef = FirebaseDatabase.instance.reference();
  int total = 0;
  List<int> prices = [];
  SharedPreferences? prefs;
  String? roomId;

  // Get json result and convert it to model. Then add

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.indigo,
        title: new Text('View Transaction'),
        elevation: 0.0,
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: Column(
              children: [
                new StreamBuilder(
                  stream: databaseRef
                      .child("billing")
                      .child(widget.orderKey!)
                      .onValue,
                  builder: (context, AsyncSnapshot<dynamic> snap) {
                    if (snap.hasData) {
                      Map<dynamic, dynamic> data = snap.data.snapshot.value;

                      if (data == null) {
                        return Center(
                          child: Container(),
                        );
                      } else {
                        Map<dynamic, dynamic> data = snap.data.snapshot.value;
                        //print(data);
                        List<dynamic> keyss = data.keys.toList();
                        List<dynamic> name = [];
                        List<dynamic> price = [];

                        //List<dynamic> time = [];
                        //List<dynamic> booked = [];

                        data.forEach((key, value) {
                          name.add(value['name']);
                          price.add(value["price"]);
                          prices.add(int.parse(value['price']));

                          // time.add(value["dateA"]);
                          //booked.add(value["booked"]);
                        });

                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: keyss.length,
                                itemBuilder: (context, index) {
                                  // total += int.parse(price[index]);

                                  return Container(
                                    margin: EdgeInsets.all(15),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(name[index]),
                                              Text('₹' + price[index] + '/-'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Center(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height: 2,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(15),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '₹\t' +
                                            prices
                                                .reduce((a, b) => a + b)
                                                .toString() +
                                            '/-',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    } else if (snap.hasError) {
                      return Center(child: Text("Error occured..!"));
                    } else if (snap.hasData == false) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return Center(child: Text("No data"));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    await databaseRef.child('food').once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        if (values['name'].contains(text)) _searchResult.add(values);

        //print(values["name"]);
      });
    });

    setState(() {});
  }
}

List<dynamic> _searchResult = [];
