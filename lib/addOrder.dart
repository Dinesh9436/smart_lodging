import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lodging/home.dart';
import 'package:lodging/pessengers.dart';
import 'package:list_ext/list_ext.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddOrder extends StatefulWidget {
  final String? pessengerName, key2;

  AddOrder({
    this.pessengerName,
    this.key2,
  });
  @override
  _AddOrderState createState() => new _AddOrderState();
}

class _AddOrderState extends State<AddOrder> {
  TextEditingController controller = new TextEditingController();
  final databaseRef = FirebaseDatabase.instance.reference();
  int total = 0;
  List<int> prices = [];
  List<int> itemPrices = [];
  int add = 0;
  int remove = 0;

  SharedPreferences? prefs;
  late String roomId;

  // Get json result and convert it to model. Then add

  @override
  void initState() {
    super.initState();
  }

  Future<void> addItem(
      String? name, String? price, String keys, String quantity) async {
    int added = int.parse(quantity);
    setState(() {
      added++;
    });
    var db = FirebaseDatabase.instance.reference().child("food");

    await db.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> data = snapshot.value;

      data.forEach((key, value) {
        if (value['name'] == name) {
          int itemPrice = int.parse(value['price']);
          int billingPrice = int.parse(price!);
          int totalPrice = billingPrice + itemPrice;

          databaseRef.child('billing').child(widget.key2!).child(keys).update(
              {'price': totalPrice.toString(), 'quantity': added.toString()});
        }
      });
    });
  }

  Future<void> removeItem(
      String? name, String? price, String keys, String quantity) async {
    int added = int.parse(quantity);
    setState(() {
      added--;
    });
    var db = FirebaseDatabase.instance.reference().child("food");

    await db.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> data = snapshot.value;

      data.forEach((key, value) {
        if (value['name'] == name) {
          int itemPrice = int.parse(value['price']);
          int billingPrice = int.parse(price!);
          int totalPrice = billingPrice - itemPrice;

          // setState(() {
          //   itemPrice +=
          //       itemPrice;
          // });
          if (itemPrice < billingPrice) {
            databaseRef.child('billing').child(widget.key2!).child(keys).update(
                {'price': totalPrice.toString(), 'quantity': added.toString()});
          }
        }
      });
    });
  }

  Future<bool> _onWillPop() async {
    return (await (showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    databaseRef
                        .child('billing')
                        .child(roomId)
                        .remove()
                        .then((value) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                            ));
                  });
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        ) as FutureOr<bool>?)) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.indigo,
        title: new Text('Add Food Orders'),
        elevation: 0.0,
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            color: Colors.indigo,
            child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(
                    controller: controller,
                    decoration: new InputDecoration(
                        hintText: 'Search', border: InputBorder.none),
                    onChanged: onSearchTextChanged,
                  ),
                  trailing: new IconButton(
                    icon: new Icon(Icons.cancel),
                    onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
          ),
          new Expanded(
            child: _searchResult.length != 0 || controller.text.isNotEmpty
                ? new StreamBuilder(
                    stream: databaseRef.child("food").onValue,
                    builder: (context, AsyncSnapshot<dynamic> snap) {
                      if (snap.hasData) {
                        Map<dynamic, dynamic> data = snap.data.snapshot.value;

                        if (data == null) {
                          return Center(
                            child: Text("No Data."),
                          );
                        } else {
                          Map<dynamic, dynamic> data = snap.data.snapshot.value;

                          List<dynamic> keyss = data.keys.toList();
                          List<dynamic> name = [];
                          List<dynamic> price = [];

                          // List<dynamic> time = [];
                          //List<dynamic> booked = [];

                          data.forEach((key, value) {
                            name.add(value["name"]);
                            price.add(value["price"]);
                            //time.add(value["dateA"]);
                            //booked.add(value["booked"]);
                          });
                          return ListView.builder(
                            itemCount: _searchResult.length,
                            itemBuilder: (context, index) {
                              return new Card(
                                child: new ListTile(
                                  onTap: () async {
                                    for (var i = 0; i < keyss.length; i++) {
                                      if (_searchResult[index]['name'] ==
                                          name[i]) {
                                        total += int.parse(_searchResult[index]
                                                ['price']
                                            .toString());
                                        setState(() {});
                                        await databaseRef
                                            .child('billing')
                                            .child(widget.key2!)
                                            .push()
                                            .set({
                                          'name': _searchResult[index]['name'],
                                          'price': _searchResult[index]
                                              ['price'],
                                          'quantity': '1'
                                        }).then((value) {
                                          controller.clear();
                                          onSearchTextChanged('');

                                          // getTotal(
                                          //     _searchResult[index]['price']);
                                        });
                                      }
                                    }
                                  },
                                  title: new Text(_searchResult[index]['name']),
                                  subtitle:
                                      new Text(_searchResult[index]['price']),
                                ),
                                margin: const EdgeInsets.all(0.0),
                              );
                            },
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
                  )
                : new StreamBuilder(
                    stream: databaseRef
                        .child("billing")
                        .child(widget.key2!)
                        .onValue,
                    builder: (context, snap) {
                      if (snap.hasData) {
                        Map<dynamic, dynamic>? data = snap.data as Map?;

                        if (data == null) {
                          return Center(
                            child: Text("No Data."),
                          );
                        } else {
                          Map<dynamic, dynamic>? data = snap.data as Map?;
                          //print(data);
                          List<dynamic> keyss = data!.keys.toList();
                          List<dynamic> name = [];
                          List<dynamic> price = [];
                          List<dynamic> quantity = [];
                          //List<dynamic> booked = [];

                          data.forEach((key, value) {
                            name.add(value['name']);
                            price.add(value["price"]);
                            quantity.add(value["quantity"]);

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
                                    return Container(
                                      margin: EdgeInsets.all(15),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  name[index] +
                                                      '\t' +
                                                      '(' +
                                                      quantity[index] +
                                                      ')',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                        icon: Icon(
                                                          Icons.remove_circle,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () async {
                                                          await removeItem(
                                                              name[index],
                                                              price[index],
                                                              keyss[index],
                                                              quantity[index]);
                                                        }),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      '₹\t' +
                                                          price[index] +
                                                          '/-',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    IconButton(
                                                        icon: Icon(
                                                          Icons.add_circle,
                                                          color: Colors.green,
                                                        ),
                                                        onPressed: () async {
                                                          await addItem(
                                                              name[index],
                                                              price[index],
                                                              keyss[index],
                                                              quantity[index]);
                                                        }),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    IconButton(
                                                        icon: Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () async {
                                                          await databaseRef
                                                              .child('billing')
                                                              .child(
                                                                  widget.key2!)
                                                              .child(
                                                                  keyss[index])
                                                              .remove();
                                                        })
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
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
