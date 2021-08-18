import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AllEmployees extends StatefulWidget {
  @override
  _AllEmployeesState createState() => _AllEmployeesState();
}

class _AllEmployeesState extends State<AllEmployees> {
  final databaseRef = FirebaseDatabase.instance.reference();

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
          'All Employees',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: databaseRef.child("users").onValue,
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
              List<dynamic> email = [];
              List<dynamic> pass = [];
              List<dynamic> role = [];

              data.forEach((key, value) {
                name.add(value["name"]);
                email.add(value["email"]);
                pass.add(value["password"]);
                role.add(value["role"]);
              });
              return InteractiveViewer(
                constrained: false,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Email',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Password',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Role',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Delete',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  rows: data.values
                      .map(
                        ((element) => DataRow(
                              cells: <DataCell>[
                                DataCell(Text(element[
                                    "name"])), //Extracting from Map element the value
                                DataCell(Text(element["email"])),
                                DataCell(Text(element["password"])),
                                DataCell(Text(element["role"])),
                                DataCell(IconButton(
                                    onPressed: () {
                                      showAlertDialog(
                                          context, keyss, email, element);
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    )))
                              ],
                            )),
                      )
                      .toList(),
                ),
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
