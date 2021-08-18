import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SMS extends StatefulWidget {
  const SMS({Key? key}) : super(key: key);

  @override
  _SMSState createState() => _SMSState();
}

class _SMSState extends State<SMS> {
  bool _validate = false;
  TextEditingController roomPrice = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final databaseRef = FirebaseDatabase.instance.reference();
  String number = "";

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

  Future<void> getSMSnum() async {
    var db = FirebaseDatabase.instance.reference().child("sms");
    db.once().then((DataSnapshot snapshot) {
      var value = snapshot.value;
      setState(() {
        number = value['number'];
      });
      print(value);
    });

    //print(existingList);
  }

  @override
  void initState() {
    super.initState();
    getSMSnum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text(
            'SMS setup',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              width: 20,
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Change SMS Number'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(height: 10),
                              Container(height: 10),
                              Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Form(
                                    key: _formKey,
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
                                        errorText: _validate
                                            ? 'Please Enter room price'
                                            : null,
                                        border: OutlineInputBorder(),
                                        labelText: 'Room Price',
                                        hintText: 'Enter Room Price',
                                      ),
                                    ),
                                  )),
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
                                    textColor: Colors.white,
                                    color: Colors.green,
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        showLoaderDialog(context);

                                        await databaseRef.child('sms').set({
                                          'number': roomPrice.text
                                        }).then((value) {
                                          setState(() {
                                            number = roomPrice.text;
                                          });
                                          Navigator.of(context).pop();
                                        });

                                        Navigator.of(context).pop();

                                        //               builder: (context) => CheckOut(keys: randomString, pessengerName: names[index], roomPrice: roomPrice.text, roomNo: room[index], roomType: type[index], name: names[index], book: booked[index], key2: keyss[index], number: index)),

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
                                    child: new Text("CHANGE"),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Change SMS recieving number ',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text("Current number:" + number),
              ),
            )
          ],
        ));
  }
}
