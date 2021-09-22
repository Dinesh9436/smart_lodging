import 'package:date_field/date_field.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lodging/viewTransaction.dart';
import 'package:dateable/dateable.dart';

class Billing extends StatefulWidget {
  @override
  _BillingState createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  final databaseRef = FirebaseDatabase.instance.reference();
  int _currentSortColumn = 0;
  bool _isAscending = true;
  DateTime? selectedDate, selectedDate1;

  List<int> totals = [];

  showAlertDialog(BuildContext context, List<dynamic> keys,
      List<dynamic> emails, dynamic elements) {
    // Create button

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete?"),
      content: Text("Do you really want to delete user ${elements['name']}?"),
      actions: [
        TextButton(
            onPressed: () {
              for (var i = 0; i < keys.length; i++) {
                if (emails[i] == elements["email"])
                  setState(() {
                    databaseRef
                        .child('users')
                        .child(keys[i])
                        .remove()
                        .then((value) => Navigator.of(context).pop());
                  });
              }
            },
            child: Text('yes')),
        TextButton(
            onPressed: () => Navigator.of(context).pop(), child: Text('no'))
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'Billing',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: DateTimeField(
                  dateFormat: DateFormat('dd-MM-yyyy'),
                  lastDate: DateTime.now(),
                  decoration: InputDecoration(hintText: "From Date"),
                  selectedDate: selectedDate,
                  onDateSelected: (DateTime date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: DateTimeField(
                  dateFormat: DateFormat('dd-MM-yyyy'),
                  lastDate: DateTime.now(),
                  decoration: InputDecoration(hintText: "To Date"),
                  selectedDate: selectedDate1,
                  onDateSelected: (DateTime date) {
                    setState(() {
                      selectedDate1 = date;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: StreamBuilder(
                stream: databaseRef.child("checkout").onValue,
                builder: (context, AsyncSnapshot<dynamic> snap) {
                  if (snap.hasData && snap.data.snapshot.value != null) {
                    Map<dynamic, dynamic> data = snap.data.snapshot.value;
                    DateFormat format = DateFormat("dd-MM-yyyy");

                    if (data == null) {
                      return Center(
                        child: Text("No Data."),
                      );
                    } else {
                      List<dynamic> keyss = data.keys.toList();
                      List<dynamic> name = [];
                      List<dynamic> rent = [];
                      List<dynamic> roomNo = [];
                      List<dynamic> roomType = [];
                      List<dynamic> date = [];
                      List<dynamic> orderKey = [];

                      data.forEach((key, value) {
                        name.add(value["name"]);
                        orderKey.add(value["key"]);
                        roomNo.add(value["roomNo"]);
                        roomType.add(value["roomType"]);
                        date.add(value["date"]);
                      });
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            sortColumnIndex: _currentSortColumn,
                            sortAscending: _isAscending,
                            columns: <DataColumn>[
                              DataColumn(
                                label: Text(
                                  'Date',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Name',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Room No.',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Room Type',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Rent',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                              // DataColumn(
                              //   label: Text(
                              //     'View',
                              //     style: TextStyle(fontStyle: FontStyle.italic),
                              //   ),
                              // ),
                            ],
                            rows: selectedDate != null && selectedDate1 != null
                                ? data.values.where((element) {
                                    return format
                                            .parse(element['date'])
                                            .isAfter(selectedDate!) &&
                                        format
                                            .parse(element['date'])
                                            .isBefore(selectedDate1!);
                                  }).map(
                                    ((element) {
                                      int totalAmount = 0;
                                      // totals.add(int.parse(element['rent']));
                                      // totalAmount =
                                      //     totals.reduce((a, b) => a + b);
                                      // print('------$totalAmount');
                                      return DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text(element[
                                              "date"])), //Extracting from Map element the value
                                          DataCell(Text(element["name"])),
                                          DataCell(Text(element["roomNo"])),
                                          DataCell(Text(element["roomType"])),

                                          DataCell(Column(
                                            children: [
                                              Text(
                                                '₹\t' + element["rent"] + '/-',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                          // DataCell(IconButton(
                                          //   onPressed: () {
                                          //     Navigator.push(
                                          //       context,
                                          //       MaterialPageRoute(
                                          //           builder: (context) =>
                                          //               ViewTransaction(
                                          //                 orderKey:
                                          //                     element['key'],
                                          //               )),
                                          //     );
                                          //   },
                                          //   icon: Icon(
                                          //     Icons.remove_red_eye,
                                          //     color: Colors.indigo,
                                          //   ),
                                          // )),
                                        ],
                                      );
                                    }),
                                  ).toList()
                                : data.values.map(
                                    ((element) {
                                      int totalAmount = 0;
                                      //  totals.add(int.parse(element['rent']));
                                      // totalAmount =
                                      //     totals.reduce((a, b) => a + b);
                                      // print('------$totalAmount');
                                      return DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text(element[
                                              "date"])), //Extracting from Map element the value
                                          DataCell(Text(element["name"])),
                                          DataCell(Text(element["roomNo"])),
                                          DataCell(Text(element["roomType"])),

                                          DataCell(
                                            Text(
                                              '₹\t' + element["rent"] + '/-',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          // DataCell(IconButton(
                                          //   onPressed: () {
                                          //     Navigator.push(
                                          //       context,
                                          //       MaterialPageRoute(
                                          //           builder: (context) =>
                                          //               ViewTransaction(
                                          //                 orderKey:
                                          //                     element['key'],
                                          //               )),
                                          //     );
                                          //   },
                                          //   icon: Icon(
                                          //     Icons.remove_red_eye,
                                          //     color: Colors.indigo,
                                          //   ),
                                          // )),
                                        ],
                                      );
                                    }),
                                  ).toList(),
                          ),
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
      ),
    );
  }
}
