import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RoomList extends StatefulWidget {
  @override
  _RoomListState createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController roomNo = new TextEditingController();
  TextEditingController roomType = new TextEditingController();
  var _firebaseRef = FirebaseDatabase().reference().child('rooms');
  final databaseRef = FirebaseDatabase.instance.reference();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Manage Rooms'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: databaseRef.child("rooms").onValue,
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
                    List<dynamic> room = [];
                    List<dynamic> type = [];
                    List<dynamic> booked = [];

                    data.forEach((key, value) {
                      room.add(value["Room Number"]);
                      type.add(value["room Type"]);
                      booked.add(value["booked"]);
                    });
                    return ListView.builder(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: keyss.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            title: Text(room[index]),
                            subtitle: Text(type[index]),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  databaseRef
                                      .child('rooms')
                                      .child(keyss[index])
                                      .remove();
                                });
                              },
                            ));
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
            Center(
              child: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: FloatingActionButton(
                    backgroundColor: Colors.indigo,
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Stack(
                                overflow: Overflow.visible,
                                children: <Widget>[
                                  Positioned(
                                    right: -40.0,
                                    top: -40.0,
                                    child: InkResponse(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: CircleAvatar(
                                        child: Icon(Icons.close),
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                  ),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                hintText: 'Room Number'),
                                            controller: roomNo,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                hintText: 'room Type'),
                                            controller: roomType,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RaisedButton(
                                            child: Text("Submit"),
                                            onPressed: () {
                                              setState(() {
                                                _firebaseRef.push().set({
                                                  "Room Number": roomNo.text,
                                                  "room Type": roomType.text,
                                                  "booked": false
                                                }).then((value) =>
                                                    Navigator.of(context)
                                                        .pop());
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                  )),
            )
          ],
        ),
      ),
    );
  }
}
