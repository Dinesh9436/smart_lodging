import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lodging/pessengers.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = new TextEditingController();
  final databaseRef = FirebaseDatabase.instance.reference();

  // Get json result and convert it to model. Then add

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.indigo,
        title: new Text('Passengers'),
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
                    stream: databaseRef.child("passengers").onValue,
                    builder: (context, AsyncSnapshot<dynamic> snap) {
                      if (snap.hasData) {
                        Map<dynamic, dynamic> data = snap.data.snapshot.value;

                        if (data == null) {
                          return Center(
                            child: Text("No Data."),
                          );
                        } else {
                          Map<dynamic, dynamic> data = snap.data.snapshot.value;
                          print(data);
                          List<dynamic> keyss = data.keys.toList();
                          List<dynamic> name = [];
                          List<dynamic> name2 = [];
                          List<dynamic> time = [];
                          //List<dynamic> booked = [];

                          data.forEach((key, value) {
                            name.add(value["name"]);
                            name2.add(value["name2"]);
                            time.add(value["dateA"]);
                            //booked.add(value["booked"]);
                          });
                          return ListView.builder(
                            itemCount: _searchResult.length,
                            itemBuilder: (context, index) {
                              return new Card(
                                child: new ListTile(
                                  onTap: () {
                                    for (var i = 0; i < keyss.length; i++) {
                                      if (_searchResult[index]['name'] ==
                                          name[i]) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Pessangers(
                                                keys: keyss[i],
                                              ),
                                            ));
                                      }
                                    }
                                  },
                                  title: new Text(_searchResult[index]['name']),
                                  subtitle:
                                      new Text(_searchResult[index]['name2']),
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
                    stream: databaseRef.child("passengers").onValue,
                    builder: (context, AsyncSnapshot<dynamic> snap) {
                      if (snap.hasData && snap.data.snapshot.value != null) {
                        Map<dynamic, dynamic> data = snap.data.snapshot.value;

                        if (data == null) {
                          return Center(
                            child: Text("No Data."),
                          );
                        } else {
                          Map<dynamic, dynamic> data = snap.data.snapshot.value;
                          print(data);
                          List<dynamic> keyss = data.keys.toList();
                          List<dynamic> name = [];
                          List<dynamic> name2 = [];
                          List<dynamic> time = [];
                          //List<dynamic> booked = [];

                          data.forEach((key, value) {
                            name.add(value["name"]);
                            name2.add(value["name2"]);
                            time.add(value["dateA"]);
                            //booked.add(value["booked"]);
                          });
                          return ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: keyss.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Pessangers(
                                            keys: keyss[index],
                                          ),
                                        )),
                                    tileColor: Colors.white,
                                    title: Text(
                                      name[index],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(name2[index]),
                                    trailing: IconButton(
                                      icon: Icon(Icons.arrow_right_outlined),
                                      onPressed: () {},
                                    )),
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

    await databaseRef.child('passengers').once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        if (values['name'].contains(text) || values['name2'].contains(text))
          _searchResult.add(values);

        print(values["name"]);
      });
    });

    setState(() {});
  }
}

List<dynamic> _searchResult = [];
