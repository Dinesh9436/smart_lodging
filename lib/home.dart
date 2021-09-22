import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lodging/addOrder.dart';
import 'package:lodging/billing.dart';

import 'package:lodging/constants.dart';
import 'package:lodging/menu.dart';
import 'package:lodging/sms.dart';
import './constants.dart' as Constants;
import 'package:lodging/employees.dart';
import 'package:lodging/main.dart';
import 'package:lodging/search.dart';
import 'package:lodging/pessengers.dart';
import 'package:lodging/register.dart';
import 'package:lodging/room.dart';
import 'package:lodging/room_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final List<Room>? rooms, booked;

  HomeScreen({Key? key, this.rooms, this.booked}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

const _url = 'http://appyweb.tech';

class HomeScreenState extends State<HomeScreen> {
  var s;
  TextEditingController roomNo = new TextEditingController();
  TextEditingController roomType = new TextEditingController();
  TextEditingController roomPrice = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? role;
  String? randomString;
  dynamic data;
  bool book = false;
  bool _validate = false;

  CollectionReference? ref;
  var _firebaseRef = FirebaseDatabase().reference().child('rooms');
  final databaseRef = FirebaseDatabase.instance.reference();
  var uid;
  late SharedPreferences prefs;

  double height = 500.0;
  void _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: new Container(
                height: height,
                color: Colors
                    .transparent, //could change this to Color(0xFF737373),
                //so you don't have to change MaterialApp canvasColor
                child: new Container(
                  decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0))),
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "Питание",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 26.0),
                      ),
                      TextField(
                        maxLines: 1,

//                        controller: customcintroller,
                        style: TextStyle(
                            color: Colors.lightGreen[400], fontSize: 18.5),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 4.0),
                          labelText: "Возраст",
                          alignLabelWithHint: false,
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                      ),
                      TextField(
                        maxLines: 1,

//                        controller: customcintroller,
                        style: TextStyle(
                            color: Colors.lightGreen[400], fontSize: 18.5),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 4.0),
                          labelText: "Рост",
                          alignLabelWithHint: false,
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                      ),
                      TextField(
                        maxLines: 1,

//                        controller: customcintroller,
                        style: TextStyle(
                            color: Colors.lightGreen[400], fontSize: 18.5),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 4.0),
                          labelText: "Вес",
                          alignLabelWithHint: false,
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                      ),
                      TextField(
                        maxLines: 1,

//                        controller: customcintroller,
                        style: TextStyle(
                            color: Colors.lightGreen[400], fontSize: 18.5),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 4.0),
                          labelText: "Целевой вес",
                          alignLabelWithHint: false,
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  )),
                )),
          );
        });
  }

  void setTodo(Room todo) {
    widget.booked!.add(todo);
  }

  Future<Room> addRoom(Room room) async {
    widget.rooms!.remove(room);
    widget.booked!.add(room);
    print(widget.booked);
    return room;
  }

  void showSheet(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Colors.white,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Wrap(
              spacing: 60,
              children: <Widget>[
                Container(height: 10),
                Text(
                  "Roberts",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                Container(height: 10),
                Container(
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onChanged: (String val) {
                      setState(() {
                        _validate = false;
                      });
                    },
                    keyboardType: TextInputType.number,
                    controller: roomPrice,
                    decoration: InputDecoration(
                      errorText: _validate ? 'Please Enter room price' : null,
                      border: OutlineInputBorder(),
                      labelText: 'Room Price',
                      hintText: 'Enter Room Price',
                    ),
                  ),
                ),
                Container(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new FlatButton(
                      textColor: Colors.pink[500],
                      color: Colors.transparent,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: new Text("CLOSE"),
                    ),
                    new RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue[700],
                      onPressed: () {},
                      child: new Text("DETAILS"),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  Future<void> checkout(
      String? roomNo, bool? book, String? name, String keys) async {
    List<dynamic> dbkey;
    var db = FirebaseDatabase.instance.reference().child("passengers");
    var db1 = FirebaseDatabase.instance.reference().child("rooms");

    await db.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> data = snapshot.value;
      data.forEach((key, values) {
        if (values['roomNo'] == roomNo &&
            book == true &&
            values['name'] == name) {
          databaseRef
              .child('passengers')
              .child(key)
              .update({'checkOut': DateTime.now().toString()}).then(
                  (value) => Navigator.of(context).pop());
        }
      });
    });
  }

  void _launchURL() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  Future<dynamic> getData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
    });

    print('======$role');
  }

  setPrefs(int number) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    String getRandomString() => String.fromCharCodes(Iterable.generate(
        5, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

    await prefs.setString('room$number', 'room$number');
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  String? validatePrice(String val) {
    return val.length == 0 ? "Enter Name First" : null;
  }

  @override
  void dispose() {
    roomPrice.dispose();
    super.dispose();
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              ListTile(
                tileColor: Colors.indigo,
              ),

              ListTile(
                tileColor: Colors.indigo,
                title: Center(
                  child: Text(
                    'ARAV LODGING',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Audiowide",
                        fontSize: MediaQuery.of(context).size.width * 0.05),
                  ),
                ),
              ),
              ListTile(
                tileColor: Colors.indigo,
              ),
              if (role == 'admin')
                ListTile(
                  title: Text(
                    'Pessengers',
                    style: TextStyle(color: Colors.black),
                  ),
                  leading: Icon(Icons.person, color: Colors.black),
                  onTap: () async {
                    //push(context, LoginScreen());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
              if (role == 'admin')
                ListTile(
                  title: Text(
                    'Manage Rooms',
                    style: TextStyle(color: Colors.black),
                  ),
                  leading: Icon(Icons.home, color: Colors.black),
                  onTap: () async {
                    //push(context, LoginScreen());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RoomList()),
                    );
                  },
                ),
              if (role == 'admin')
                ListTile(
                  title: Text(
                    'Manage Employees',
                    style: TextStyle(color: Colors.black),
                  ),
                  leading: Icon(Icons.people, color: Colors.black),
                  onTap: () async {
                    //push(context, LoginScreen());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EmployeeScreen()),
                    );
                  },
                ),
              // if (role == 'admin')
              //   ListTile(
              //     title: Text(
              //       'Food',
              //       style: TextStyle(color: Colors.black),
              //     ),
              //     leading: Icon(Icons.fastfood, color: Colors.black),
              //     onTap: () async {
              //       //push(context, LoginScreen());
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (context) => FoodMenu()),
              //       );
              //     },
              //   ),
              if (role == 'admin')
                ListTile(
                  title: Text(
                    'Billing',
                    style: TextStyle(color: Colors.black),
                  ),
                  leading: Icon(Icons.account_balance, color: Colors.black),
                  onTap: () async {
                    //push(context, LoginScreen());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Billing()),
                    );
                  },
                ),
              if (role == 'admin')
                ListTile(
                  title: Text(
                    'SMS setup',
                    style: TextStyle(color: Colors.black),
                  ),
                  leading: Icon(Icons.mail, color: Colors.black),
                  onTap: () async {
                    //push(context, LoginScreen());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SMS()),
                    );
                  },
                ),
              ListTile(
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.black),
                ),
                leading: Transform.rotate(
                    angle: pi / 1,
                    child: Icon(Icons.exit_to_app, color: Colors.black)),
                onTap: () async {
                  prefs.remove('email');

                  await Navigator.of(context).pushNamedAndRemoveUntil(
                      '/signin', (Route<dynamic> route) => false);
                },
              ),
              // use this
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 5)),
                      Text('Copyright © 2021\t'),
                      TextButton(
                        onPressed: _launchURL,
                        child: Text(
                          'Appyweb Technologies',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(
            'Home',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.indigo,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20),
              ),
              Text('Rooms',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              StreamBuilder(
                stream: databaseRef.child("rooms").onValue,
                builder: (context, AsyncSnapshot<dynamic> snap) {
                  print("----####$snap");
                  if (snap.hasData && snap.data.snapshot.value != null) {
                    Map<dynamic, dynamic> data = snap.data.snapshot.value;

                    if (data == null) {
                      return Center(
                        child: Text("No Data."),
                      );
                    } else {
                      Map<dynamic, dynamic> data = snap.data.snapshot.value;
                      //print(data);
                      List<dynamic> keyss = data.keys.toList();
                      List<dynamic> room = [];
                      List<dynamic> type = [];
                      List<dynamic> booked = [];
                      List<dynamic> names = [];
                      data.forEach((key, value) {
                        room.add(value["Room Number"]);
                        type.add(value["room Type"]);
                        booked.add(value["booked"]);
                        names.add(value["name"]);
                      });
                      return ListView.builder(
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: keyss.length,
                        itemBuilder: (context, index) {
                          setPrefs(index);
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                                tileColor: Colors.white,
                                title: Text(
                                  room[index],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(type[index]),
                                trailing: !booked[index]
                                    ? MaterialButton(
                                        color: Colors.indigo,
                                        textColor: Colors.white,
                                        child: Text('Book'),
                                        onPressed: () {
                                          setState(() {
                                            book = true;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RegisterRoom(
                                                        room: Room(
                                                            roomNo: room[index],
                                                            type: type[index],
                                                            isBooked:
                                                                booked[index],
                                                            keys: keyss[index]),
                                                      )),
                                            );
                                          });
                                        })
                                    : MaterialButton(
                                        textColor: Colors.white,
                                        color: Colors.redAccent,
                                        child: Text("Booked"),
                                        onPressed: () async {
                                          print(
                                              '+++++++${prefs.getString('room$index')}');

                                          showDialog<void>(
                                            context: context,
                                            barrierDismissible:
                                                false, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Checkout'),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Container(height: 10),
                                                      Container(height: 10),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 15.0),
                                                        child: Text(
                                                          "Room price",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ),
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  15),
                                                          child: Form(
                                                            key: _formKey,
                                                            child:
                                                                TextFormField(
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                        null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return 'Please enter some text';
                                                                }
                                                                return null;
                                                              },
                                                              onChanged:
                                                                  (String val) {
                                                                setState(() {
                                                                  _validate =
                                                                      false;
                                                                });
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              controller:
                                                                  roomPrice,
                                                              decoration:
                                                                  InputDecoration(
                                                                errorText: _validate
                                                                    ? 'Please Enter room price'
                                                                    : null,
                                                                border:
                                                                    OutlineInputBorder(),
                                                                labelText:
                                                                    'Room Price',
                                                                hintText:
                                                                    'Enter Room Price',
                                                              ),
                                                            ),
                                                          )),
                                                      Container(height: 10),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: <Widget>[
                                                          new FlatButton(
                                                            textColor: Colors
                                                                .pink[500],
                                                            color: Colors
                                                                .transparent,
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: new Text(
                                                                "CLOSE"),
                                                          ),
                                                          // MaterialButton(
                                                          //   onPressed:
                                                          //       () async {
                                                          //     Navigator.push(
                                                          //       context,
                                                          //       MaterialPageRoute(
                                                          //           builder:
                                                          //               (context) =>
                                                          //                   AddOrder(
                                                          //                     pessengerName: names[index],
                                                          //                     key2: keyss[index],
                                                          //                   )),
                                                          //     );
                                                          //   },
                                                          //   color:
                                                          //       Colors.indigo,
                                                          //   child: Text(
                                                          //     'Add+',
                                                          //     style: TextStyle(
                                                          //         color: Colors
                                                          //             .white),
                                                          //   ),
                                                          // ),
                                                          Container(
                                                            width: 10,
                                                          ),
                                                          new RaisedButton(
                                                            textColor:
                                                                Colors.white,
                                                            color: Colors.green,
                                                            onPressed:
                                                                () async {
                                                              if (_formKey
                                                                  .currentState!
                                                                  .validate()) {
                                                                showLoaderDialog(
                                                                    context);
                                                                var date =
                                                                    new DateTime
                                                                            .now()
                                                                        .toString();

                                                                var dateParse =
                                                                    DateTime
                                                                        .parse(
                                                                            date);

                                                                var formattedDate =
                                                                    "${dateParse.day}-${dateParse.month}-${dateParse.year}";
                                                                await databaseRef
                                                                    .child(
                                                                        'checkout')
                                                                    .push()
                                                                    .set({
                                                                  'name': names[
                                                                      index],
                                                                  'key': keyss[
                                                                      index],
                                                                  'rent':
                                                                      roomPrice
                                                                          .text,
                                                                  'roomNo': room[
                                                                      index],
                                                                  'roomType':
                                                                      type[
                                                                          index],
                                                                  'date': formattedDate
                                                                      .toString(),
                                                                });
                                                                //               builder: (context) => CheckOut(keys: randomString, pessengerName: names[index], roomPrice: roomPrice.text, roomNo: room[index], roomType: type[index], name: names[index], book: booked[index], key2: keyss[index], number: index)),

                                                                await checkout(
                                                                        room[
                                                                            index],
                                                                        booked[
                                                                            index],
                                                                        names[
                                                                            index],
                                                                        keyss[
                                                                            index])
                                                                    .then(
                                                                        (value) {
                                                                  databaseRef
                                                                      .child(
                                                                          'rooms')
                                                                      .child(keyss[
                                                                          index])
                                                                      .update({
                                                                    'booked':
                                                                        false
                                                                  }).then((value) =>
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => HomeScreen()),
                                                                          ));
                                                                });
                                                                // Navigator.of(
                                                                //         context)
                                                                //     .pop();

                                                                // then((value) =>
                                                                //         Navigator
                                                                //             .push(
                                                                //           context,
                                                                //           MaterialPageRoute(
                                                                //               builder: (context) => CheckOut(keys: randomString, pessengerName: names[index], roomPrice: roomPrice.text, roomNo: room[index], roomType: type[index], name: names[index], book: booked[index], key2: keyss[index], number: index)),
                                                                //         ));
                                                              }
                                                            },
                                                            child: new Text(
                                                                "CHECKOUT"),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                          // showModalBottomSheet(
                                          //     isScrollControlled: true,
                                          //     context: context,
                                          //     builder: (BuildContext bc) {
                                          //       return SingleChildScrollView(
                                          //         child: Container(
                                          //           color: Colors.white,
                                          //           child:
                                          //         ),
                                          //       );
                                          //     });

                                          // showDialog<void>(
                                          //   context: context,
                                          //   barrierDismissible:
                                          //       false, // user must tap button!
                                          //   builder: (BuildContext context) {
                                          //     return AlertDialog(
                                          //       title: Text('Release?'),
                                          //       actions: <Widget>[
                                          //         TextButton(
                                          //           child: Text('Yes'),
                                          //           onPressed: () async {

                                          //             setState(() {
                                          //               checkout(
                                          //                       room[index],
                                          //                       booked[index],
                                          //                       names[index])
                                          //                   .then((value) =>
                                          //                       databaseRef
                                          //                           .child(
                                          //                               'rooms')
                                          //                           .child(keyss[
                                          //                               index])
                                          //                           .update({
                                          //                         'booked':
                                          //                             false
                                          //                       }));
                                          //             });
                                          //           },
                                          //         ),
                                          //         TextButton(
                                          //           child: Text('No'),
                                          //           onPressed: () {
                                          //             Navigator.of(context)
                                          //                 .pop();
                                          //           },
                                          //         ),
                                          //       ],
                                          //     );
                                          //   },
                                          // );
                                        })),
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
            ],
          ),
        )
        /* Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            displayCircleImage(user.profilePictureURL, 125, false),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user.firstName),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user.email),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user.phoneNumber),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user.userID),
            ),
          ],
        ),
      ),*/

        );
  }
}

/*Room(r
oomNo: '01', type: 'Delux Room', isBooked: false),
    Room(roomNo: '02', type: 'Delux Room', isBooked: false),
    Room(roomNo: '03', type: 'Delux Room', isBooked: false),
    Room(roomNo: '101', type: 'Delux Room', isBooked: false),
    Room(roomNo: '102', type: 'Delux Room', isBooked: false),
    Room(roomNo: '103', type: 'Delux Room', isBooked: false),
    Room(roomNo: '104', type: 'Delux Room', isBooked: false),
    Room(roomNo: '105', type: 'Semi-Delux Room', isBooked: false),
    Room(roomNo: '106', type: 'Semi-Delux Room', isBooked: false),
    Room(roomNo: '107', type: 'Semi-Delux Room', isBooked: false),
    Room(roomNo: '108', type: 'Semi-Delux Room', isBooked: false),
    Room(roomNo: '109', type: 'Semi-Delux Room', isBooked: false),
    Room(roomNo: '1', type: ' Room', isBooked: false),
    Room(roomNo: '2', type: ' Room', isBooked: false),
    Room(roomNo: '3', type: ' Room', isBooked: false),
    Room(roomNo: '4', type: ' Room', isBooked: false),
    Room(roomNo: '5', type: ' Room', isBooked: false),*/
