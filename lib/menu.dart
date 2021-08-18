import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FoodMenu extends StatefulWidget {
  @override
  _FoodMenuState createState() => _FoodMenuState();
}

class _FoodMenuState extends State<FoodMenu> {
  final _formKey = GlobalKey<FormState>();
  final databaseRef = FirebaseDatabase.instance.reference();
  var _firebaseRef = FirebaseDatabase().reference().child('food');
  TextEditingController itemName = new TextEditingController();
  TextEditingController itemPrice = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'My Menu Card',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder(
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
              print(data);
              List<dynamic> keyss = data.keys.toList();
              List<dynamic> name = [];
              List<dynamic> price = [];

              data.forEach((key, value) {
                name.add(value["name"]);
                price.add(value["price"]);
              });
              return SingleChildScrollView(
                child: Column(children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(20),
                    child: ListView.builder(
                      itemCount: keyss.length,
                      shrinkWrap: true,
                      itemBuilder: ((context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    padding: EdgeInsets.all(15),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(name[index],
                                          style: TextStyle(
                                              color: Colors.indigo,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(15),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text('₹' + price[index],
                                          style: TextStyle(
                                            color: Colors.indigo,
                                            fontSize: 18,
                                          )),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.grey[500]),
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
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: CircleAvatar(
                                                            child: Icon(
                                                                Icons.close),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                      Form(
                                                        key: _formKey,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  TextFormField(
                                                                decoration:
                                                                    InputDecoration(
                                                                        hintText:
                                                                            'Item Name'),
                                                                controller:
                                                                    itemName,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  TextFormField(
                                                                decoration:
                                                                    InputDecoration(
                                                                        hintText:
                                                                            'Item Price'),
                                                                controller:
                                                                    itemPrice,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  RaisedButton(
                                                                child: Text(
                                                                    "Submit"),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    _firebaseRef
                                                                        .child(keyss[
                                                                            index])
                                                                        .update({
                                                                      'name': itemName
                                                                          .text,
                                                                      'price':
                                                                          itemPrice
                                                                              .text
                                                                    }).then((value) =>
                                                                            Navigator.of(context).pop());
                                                                  });

                                                                  itemName
                                                                      .clear();
                                                                  itemPrice
                                                                      .clear();
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
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _firebaseRef
                                                .child(keyss[index])
                                                .remove();
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  Center(
                    child: FloatingActionButton(
                      onPressed: () async {
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
                                                  hintText: 'Item Name'),
                                              controller: itemName,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                  hintText: 'Item Price'),
                                              controller: itemPrice,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: RaisedButton(
                                              child: Text("Submit"),
                                              onPressed: () {
                                                setState(() {
                                                  _firebaseRef.push().set({
                                                    "name": itemName.text,
                                                    "price": itemPrice.text,
                                                  }).then((value) =>
                                                      Navigator.of(context)
                                                          .pop());
                                                });
                                                itemName.clear();
                                                itemPrice.clear();
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
                      backgroundColor: Colors.indigo,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ]),
              );
            }
          } else if (snap.hasError) {
            return Center(child: Text("Error occured..!"));
          } else if (snap.hasData == false) {
            return Center(child: Text("No data"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
