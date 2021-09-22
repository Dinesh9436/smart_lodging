import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lodging/main.dart';
import 'package:lodging/room.dart';
import 'package:lodging/terms.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:telephony/telephony.dart';
import './constants.dart' as Constants;
import 'constants.dart';
import 'data/user_data.dart';
import 'home.dart';
import 'package:path/path.dart' as Path;
import 'package:date_field/date_field.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_typeahead/flutter_typeahead.dart';

File? _image;

class RegisterRoom extends StatefulWidget {
  RegisterRoom({this.room});
  final Room? room;

  @override
  RegisterRoomState createState() => RegisterRoomState();
}

class RegisterRoomState extends State<RegisterRoom> {
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey();
  List<Room> booked = [];
  String? _uploadedFileURL;
  DateTime? selectedDate;
  DateTime? selectedDate1;
  List<Widget> doc = [];
  List<dynamic> uploadedURL = [];
  List<String> names = [];
  List<String> names1 = [];
  dynamic existingList;
  bool? agree = false;
  bool existing = false;
  final pdf = pw.Document();
  CollectionReference? refs;
  String? keys;
  final databaseRef = FirebaseDatabase.instance.reference();
  final Telephony telephony = Telephony.instance;
  String smsNum = "";

  bool _autovalidate = false;
  var _firebaseRef = FirebaseDatabase().reference().child('passengers');

  Room? bookedRoom;
  List<String> passKey = [];

  String? name = '',
      name1 = '',
      nationality = '',
      address = '',
      dateA = '',
      place = '',
      reason = '',
      days = '',
      dateB = '',
      where = '',
      document = 'Aadhar';

  List<DropdownMenuItem<String>> items = [
    new DropdownMenuItem(
      child: new Text('Aadhar card'),
      value: 'Aadhar',
    ),
    new DropdownMenuItem(
      child: new Text('PAN card'),
      value: 'PAN',
    ),
    new DropdownMenuItem(
      child: new Text('Driving licence'),
      value: 'Licence',
    ),
    new DropdownMenuItem(
      child: new Text('Voter ID'),
      value: 'VoterID',
    ),
    new DropdownMenuItem(
      child: new Text('College ID'),
      value: 'CollegeID',
    ),
  ];
  final picker = ImagePicker();

  Future uploadFile() async {
    String url;
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('chats/${Path.basename(_image!.path)}}');
    UploadTask uploadTask = storageReference.putFile(_image!);
    _uploadedFileURL = await (await uploadTask).ref.getDownloadURL();

    uploadedURL.add(_uploadedFileURL);

    print('File Uploaded');
    Navigator.pop(context);
  }

  Future<void> getNameList() async {
    var db = FirebaseDatabase.instance.reference().child("passengers");
    db.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;

      values.forEach((key, val) {
        setState(() {
          names1.add(val["name"]);
        });
      });
    });

    //print(existingList);
  }

  Future<void> getsmsNumber() async {
    var db = FirebaseDatabase.instance.reference().child("sms");
    await db.once().then((DataSnapshot snapshot) {
      var value = snapshot.value;
      setState(() {
        smsNum = "+91" + value['number'];
      });
    });
  }

  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 10);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    bookedRoom = widget.room;
    keys = widget.room!.keys;

    getNameList().then((value) {
      getsmsNumber();
    });

    setState(() {});
  }

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        "Add document picture",
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text("Take a picture"),
          isDestructiveAction: false,
          onPressed: () async {
            await getImage();
            showLoaderDialog(context);
            await uploadFile();
            Navigator.pop(context);
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  Widget addDoc() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 170,
            height: 170,
            color: Colors.grey.shade400,
            child: SizedBox(
              child: _image == null
                  ? Image.asset(
                      'assets/download.png',
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        Positioned(
          left: 80,
          right: 0,
          child: FloatingActionButton(
              backgroundColor: Constants.COLOR_PRIMARY,
              child: Icon(Icons.camera_alt),
              mini: true,
              onPressed: _onCameraClick),
        )
      ],
    );
  }

  Widget formUI() {
    return new Column(
      children: <Widget>[
        new Align(
            alignment: Alignment.topLeft,
            child: Center(
              child: Text(
                'Passenger Registration',
                style: TextStyle(
                    color: Constants.COLOR_PRIMARY,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0),
              ),
            )),
        Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.all(5.0),
            width: MediaQuery.of(context).size.width * 0.40,
            child: Center(
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                    value: document,
                    items: items,
                    onChanged: (dynamic value) {
                      setState(() {
                        document = value;
                      });
                    }),
              ),
            )),
        existing
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: uploadedURL.length,
                        itemBuilder: (context, index) {
                          return Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(uploadedURL[index]),
                          ));
                        },
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Container(
                          width: 170,
                          height: 170,
                          color: Colors.grey.shade400,
                          child: SizedBox(
                            child: _image == null
                                ? Image.asset(
                                    'assets/download.png',
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Positioned(
                          left: 80,
                          right: 0,
                          child: FloatingActionButton(
                              backgroundColor: Constants.COLOR_PRIMARY,
                              child: Icon(Icons.camera_alt),
                              mini: true,
                              onPressed: _onCameraClick),
                        )
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: doc.length,
                        itemBuilder: (context, index) {
                          return Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: doc[index],
                          ));
                        },
                      ),
                    ),
                    FloatingActionButton(
                        heroTag: "btn12",
                        backgroundColor: Constants.COLOR_PRIMARY,
                        child: Icon(Icons.add),
                        mini: true,
                        onPressed: () {
                          setState(() {
                            doc.add(addDoc());
                          });
                        }),
                  ],
                ),
              ),

        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
              child: TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                    controller: _nameController,
                    onChanged: (String val) {
                      setState(() {
                        name = val;
                      });
                    },
                    autofocus: true,
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: existing && name!.isNotEmpty
                            ? name
                            : 'प्रवाशाचे संपूर्ण नाव ',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Constants.COLOR_PRIMARY, width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))),
                suggestionsCallback: (pattern) async {
                  return names1.where((user) {
                    final userLower = user.toLowerCase();
                    final queryLower = pattern.toLowerCase();

                    return userLower.contains(queryLower);
                  }).toList();

                  // Here you can call http call
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion.toString()),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  _nameController.value = _nameController.value.copyWith(
                    text: _nameController.text,
                    selection: TextSelection.collapsed(
                        offset: _nameController.value.selection.baseOffset),
                  );
                  // This when someone click the items
                  setState(() {
                    existing = true;
                  });
                  var db =
                      FirebaseDatabase.instance.reference().child("passengers");
                  db.once().then((DataSnapshot snapshot) {
                    Map<dynamic, dynamic> values = snapshot.value;

                    values.forEach((key, val) {
                      if (val["name"].toString().toLowerCase() ==
                          suggestion.toString().toLowerCase()) {
                        setState(() {
                          name = val['name'] ?? '';
                          nationality = val['phone no'] ?? '';
                          address = val['address'] ?? '';
                          where = val['where'] ?? '';
                          reason = val['reason'] ?? '';
                          days = val['days'] ?? '';
                          place = val['document'] ?? '';
                          uploadedURL = val['imageURL'].toList();

                          document = val['document'] ?? '';
                        });
                      }
                    });

                    print(values);
                  });
                  setState(() {});

                  print("---------$where");
                  print("---------$reason");
                  print("---------$place");
                  print("---------$nationality");
                  print("---------$days");
                  print("---------$address");
                },
              ),
            )),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    onChanged: (String val) {
                      setState(() {
                        name1 = val;
                        print(name);
                      });
                    },
                    //validator: validateName,
                    onSaved: (String? val) {
                      setState(() {
                        name1 = val;
                      });
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: 'प्रवाशाचे संपूर्ण नाव(2) ',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Constants.COLOR_PRIMARY, width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))))),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (String val) {
                      if (existing == false) {
                        setState(() {
                          nationality = val;
                          print(name);
                        });
                      } else if (existing == true && val.isNotEmpty) {
                        setState(() {
                          nationality = val;
                          print(nationality);
                        });
                      }
                    },
                    //validator: validateNationality,

                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: existing && nationality!.isNotEmpty
                            ? nationality
                            : 'फोन नं  ',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Constants.COLOR_PRIMARY, width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))))),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    onChanged: (String val) {
                      if (existing == false) {
                        setState(() {
                          address = val;
                          print(address);
                        });
                      } else if (existing == true && val.isNotEmpty) {
                        setState(() {
                          address = val;
                          print(address);
                        });
                      }
                    },
                    //validator: validateAddress,

                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: existing && address!.isNotEmpty
                            ? address
                            : 'पत्ता ',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Constants.COLOR_PRIMARY, width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))))),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: DateTimeField(
              lastDate: DateTime.now(),
              decoration: InputDecoration(hintText: 'तारीख आणि वेळ '),
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
              padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
              child: TextFormField(
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  controller: _passwordController,
                  onChanged: (String val) {
                    if (existing == false) {
                      setState(() {
                        where = val;
                        print(where);
                      });
                    } else if (existing == true && val.isNotEmpty) {
                      setState(() {
                        where = val;
                        print(where);
                      });
                    }
                  },
                  // validator: validateWhere,

                  style: TextStyle(height: 0.8, fontSize: 18.0),
                  cursorColor: Constants.COLOR_PRIMARY,
                  decoration: InputDecoration(
                      contentPadding:
                          new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      fillColor: Colors.white,
                      hintText:
                          existing && where!.isNotEmpty ? where : 'कोठून आला ?',
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                              color: Constants.COLOR_PRIMARY, width: 2.0)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ))),
            )),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
                textInputAction: TextInputAction.done,
                onChanged: (String val) {
                  if (existing == false) {
                    setState(() {
                      reason = val;
                      print(reason);
                    });
                  } else if (existing == true && val.isNotEmpty) {
                    setState(() {
                      reason = val;
                      print(reason);
                    });
                  }
                },
                // validator: validateReason,

                style: TextStyle(height: 0.8, fontSize: 18.0),
                cursorColor: Constants.COLOR_PRIMARY,
                decoration: InputDecoration(
                    contentPadding:
                        new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    fillColor: Colors.white,
                    hintText: existing && reason!.isNotEmpty
                        ? reason
                        : 'येण्याचे कारण ',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                            color: Constants.COLOR_PRIMARY, width: 2.0)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ))),
          ),
        ),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    //validator: validateDays,
                    onChanged: (String val) {
                      if (existing == false) {
                        setState(() {
                          days = val;
                          print(days);
                        });
                      } else if (existing == true && val.isNotEmpty) {
                        setState(() {
                          days = val;
                          print(days);
                        });
                      }
                    },
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: existing && days!.isNotEmpty
                            ? days
                            : 'किती दिवस राहणार ?',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Constants.COLOR_PRIMARY, width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))))),
        // ConstrainedBox(
        //     constraints: BoxConstraints(minWidth: double.infinity),
        //     child: Padding(
        //       padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //       child: DateTimeField(
        //         firstDate: DateTime.now(),
        //         lastDate: DateTime.now(),
        //         label: 'हॉटेलमधून जाण्याची तारीख आणि वेळ ',
        //         selectedDate: selectedDate1,
        //         onDateSelected: (DateTime date) {
        //           setState(() {
        //             selectedDate1 = date;
        //           });
        //         },
        //       ),
        //     )),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),

                    // validator: validateWhere,

                    onChanged: (String val) {
                      if (existing == false) {
                        setState(() {
                          place = val;
                          print(place);
                        });
                      } else if (existing == true && val.isNotEmpty) {
                        setState(() {
                          place = val;
                          print(place);
                        });
                      }
                    },
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: existing && place!.isNotEmpty
                            ? place
                            : 'कोठे जाणार तो पत्ता ',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Constants.COLOR_PRIMARY, width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))))),
        Row(
          children: [
            Material(
              child: Checkbox(
                value: agree,
                onChanged: (value) {
                  setState(() {
                    agree = value;
                  });
                },
              ),
            ),
            GestureDetector(
                child: Text(
                  'I have read and accept terms and conditions',
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Terms()),
                    )),
          ],
        ),
        // GestureDetector(
        //   child: Icon(
        //     Icons.picture_as_pdf_outlined,
        //     color: Colors.red,
        //   ),
        //   onTap: () async {
        //     print('****$name****');
        //     final dateString = DateFormat('EEE, M/d/y').format(selectedDate!);
        //     final timeString = DateFormat('K:mm:ss').format(selectedDate!);

        //     final font = await rootBundle.load('assets/Eczar-Regular.ttf');
        //     final ttf = pw.Font.ttf(font);
        //     var assetImage = pw.MemoryImage(
        //       (await rootBundle.load('assets/declaration.png'))
        //           .buffer
        //           .asUint8List(),
        //     );
        //     for (var i = 0; i < uploadedURL.length; i++) {
        //       var formatter = new DateFormat('dd-MM-yyyy kk:mm:a');
        //       // var parsedDate = DateTime.parse(selectedDate);
        //       String formattedDate = formatter.format(selectedDate!);

        //       if (uploadedURL.isNotEmpty) {
        //         await Printing.layoutPdf(
        //             onLayout: (PdfPageFormat format) async =>
        //                 await Printing.convertHtml(
        //                   format: format,
        //                   html:
        //                       '<html><body><p style="font-size:18;">नाव : $name<br>सोबत आलेल्या व्यक्तीचे नाव: $name1<br>रूम नं : ${widget.room!.roomNo.toString()}<br>फोन नं : $nationality<br>पत्ता : $address<br>तारीख आणि वेळ : $formattedDate<br>कोठून आला? :$place<br>कारण : $reason<br>किती दिवस राहणार? :$days<br>कोठे जाणार तो पत्ता ? :$where<br>ओळखपत्र : $document<br><br><br><img src="${uploadedURL[i]}" width="200" height="200" ><br><br>आम्ही दोघेही एकाच विचाराचे असलेने व सज्ञान असलेने एकमेकांचे पसंतीने आम्हापैकी कोणावरही  दडपण किंवा जोरजुलुम केलेला नाही . आम्ही लॉजची रूम भाड्याने घेत असतेवेळी व्यवस्थापक यांना वय पूर्ण असलेले ओळखपत्र दाखवलेले आहे. आम्ही एकमेकांच्या संमतीने लॉजमध्ये आलेलो आहोत .त्यामुळे या गोष्टीस लॉज मालक /चालक/व्यवस्थापक जबाबदार असणार नाहीत /त्यांचा काहीही दोष नाही .</p></body></html>', // pass generated html here
        //                 ));
        //       } else {
        //         Fluttertoast.showToast(
        //             msg: "please upload document",
        //             toastLength: Toast.LENGTH_SHORT,
        //             gravity: ToastGravity.BOTTOM,
        //             timeInSecForIosWeb: 1,
        //             backgroundColor: Colors.white,
        //             textColor: Colors.black,
        //             fontSize: 16.0);
        //       }
        //     }
        // pdf.addPage(
        //   pw.MultiPage(
        //     pageFormat: PdfPageFormat.a4,
        //     margin: pw.EdgeInsets.all(32),
        //     build: (pw.Context context) {
        //       return <pw.Widget>[
        //         pw.Header(level: 0, child: pw.Text('Omkar Lodging')),
        //         pw.Paragraph(
        //             text: 'Name :$name',
        //             style: pw.TextStyle(font: ttf, fontSize: 14)),
        //         pw.Paragraph(
        //             text: '2nd Person Name :$name1',
        //             style: pw.TextStyle(font: ttf, fontSize: 14)),
        //         pw.Paragraph(
        //             text: 'Room No. :${widget.room!.roomNo.toString()}',
        //             style: pw.TextStyle(font: ttf, fontSize: 14)),
        //         pw.Paragraph(
        //             text: 'Phone No.  :$nationality',
        //             style: pw.TextStyle(font: ttf, fontSize: 14)),
        //         pw.Paragraph(
        //             text: 'Address :$address',
        //             style: pw.TextStyle(font: ttf, fontSize: 14)),
        //         pw.Paragraph(
        //             text: 'Date:$dateString',
        //             style: pw.TextStyle(font: ttf, fontSize: 14)),
        //         pw.Paragraph(
        //             text: 'Time :$timeString',
        //             style: pw.TextStyle(font: ttf, fontSize: 14)),
        //         pw.Paragraph(
        //             text: 'From :$place',
        //             style: pw.TextStyle(font: ttf, fontSize: 14)),
        //         pw.Paragraph(
        //             text: 'Reason :$reason',
        //             style: pw.TextStyle(font: ttf, fontSize: 14)),
        //         pw.Paragraph(
        //             text: 'No.of Days :$days',
        //             style: pw.TextStyle(font: ttf, fontSize: 14)),
        //         pw.Paragraph(
        //             text: 'Where To Go  :$where',
        //             style: pw.TextStyle(font: ttf, fontSize: 14)),
        //         pw.Paragraph(
        //             text: 'Document:$document',
        //             style: pw.TextStyle(font: ttf, fontSize: 14)),
        //         pw.Image(assetImage),
        //       ];
        //     },
        //   ),
        // );

        // await Printing.layoutPdf(
        //     onLayout: (PdfPageFormat format) async => pdf.save());
        // Directory documentDirectory =
        //     await getApplicationDocumentsDirectory();
        // String documentPath = documentDirectory.path;
        // print("****$documentPath ******");

        // String fullPath = "$documentPath/pessenger.pdf";

        // await savePDF().then((value) => Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => PdfPreviewScreen(
        //               path: fullPath,
        //               fileUrl: _uploadedFileURL,
        //             ))));
        //   },
        // ),

        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: RaisedButton(
              color: Color(Constants.FACEBOOK_BUTTON_COLOR),
              child: Text(
                'Register',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              textColor: Colors.white,
              splashColor: Color(Constants.FACEBOOK_BUTTON_COLOR),
              onPressed: () async {
                print(uploadedURL);
                var formattedDate;
                String image1 = uploadedURL[0] ??
                    "https://upload.wikimedia.org/wikipedia/en/thumb/9/98/Blank_button.svg/1200px-Blank_button.svg.png";

                String image2 = uploadedURL.length > 1
                    ? uploadedURL[1]
                    : "https://upload.wikimedia.org/wikipedia/en/thumb/9/98/Blank_button.svg/1200px-Blank_button.svg.png";

                String image3 = uploadedURL.length > 2
                    ? uploadedURL[2]
                    : "https://upload.wikimedia.org/wikipedia/en/thumb/9/98/Blank_button.svg/1200px-Blank_button.svg.png";

                String image4 = uploadedURL.length > 3
                    ? uploadedURL[3]
                    : "https://upload.wikimedia.org/wikipedia/en/thumb/9/98/Blank_button.svg/1200px-Blank_button.svg.png";
                setState(() {});
                print('-----------$smsNum');
                if (agree! && uploadedURL.isNotEmpty) {
                  var formatter = new DateFormat('dd-MM-yyyy kk:mm:a');
                  // var parsedDate = DateTime.parse(selectedDate);
                  String formattedDate = formatter.format(selectedDate!);
                  final SmsSendStatusListener listener = (SendStatus status) {
                    print(status);

                    // Handle the status
                  };
                  telephony.sendSms(
                      to: smsNum,
                      statusListener: listener,
                      isMultipart: true,
                      message:
                          "रूम नं : ${bookedRoom!.roomNo} \n ग्राहकाचे नाव : $name \n वेळ : $formattedDate.");

                  await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async =>
                          await Printing.convertHtml(
                            format: format,
                            html:
                                '<html><body><p style="font-size:18;">नाव : $name<br>सोबत आलेल्या व्यक्तीचे नाव: $name1<br>रूम नं: ${widget.room!.roomNo.toString()}<br>फोन नं : $nationality<br>पत्ता : $address<br>तारीख आणि वेळ: $formattedDate<br>कोठून आला? :$where<br>कारण : $reason<br>किती दिवस राहणार? :$days<br>कोठे जाणार तो पत्ता ?:$place<br>ओळखपत्र : $document<br><br><br><img src="$image1" width="200" height="200" style="padding: 10px;" ><img src="$image2" width="200" height="200" style="padding: 10px;"><img src="$image3" width="200" height="200" style="padding: 10px;"><img src="$image4" width="200" height="200" style="padding: 10px;"><br><br>आम्ही दोघेही एकाच विचाराचे असलेने व सज्ञान असलेने एकमेकांचे पसंतीने आम्हापैकी कोणावरही  दडपण किंवा जोरजुलुम केलेला नाही . आम्ही लॉजची रूम भाड्याने घेत असतेवेळी व्यवस्थापक यांना वय पूर्ण असलेले ओळखपत्र दाखवलेले आहे. आम्ही एकमेकांच्या संमतीने लॉजमध्ये आलेलो आहोत .त्यामुळे या गोष्टीस लॉज मालक /चालक/व्यवस्थापक जबाबदार असणार नाहीत /त्यांचा काहीही दोष नाही .</p></body></html>', // pass generated html here
                          ));

                  showLoaderDialog(context);

                  await _sendToServer(context).then((value) {
                    _image = null;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home', (Route<dynamic> route) => false);
                  });
                } else {
                  uploadedURL.isEmpty
                      ? Fluttertoast.showToast(
                          msg: "please upload document",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 16.0)
                      : Fluttertoast.showToast(
                          msg: "please accept Terms & conditions!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 16.0);
                }
              },
              padding: EdgeInsets.only(top: 12, bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(
                      color: Color(Constants.FACEBOOK_BUTTON_COLOR))),
            ),
          ),
        ),
      ],
    );
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

  Future<void> _sendToServer(BuildContext context) async {
    if (_key.currentState!.validate()) {
      //No error in validator
      _key.currentState!.save();
      print("#############${where.toString()}");

      // if (_image != null) {
      //   await uploadFile();
      // }
      // FirebaseFirestore.instance
      //     .runTransaction((Transaction transaction) async {
      //   refs = FirebaseFirestore.instance.collection('passengers');

      await _firebaseRef.push().set({
        "name": name,
        "name2": name1,
        "phone no": nationality,
        "address": address,
        "dateA": selectedDate.toString(),
        "where": where,
        "reason": reason,
        "days": days,
        // "departureDate": selectedDate1,
        "place": place,
        'document': document,
        'imageURL': uploadedURL,
        'roomNo': bookedRoom!.roomNo
      }).then((value) {
        databaseRef
            .child('rooms')
            .child(keys!)
            .update({'name': name, 'booked': true});
      });

      // await refs.add({
      //   "name": name,
      //   "name2": name1,
      //   "phone no.": nationality,
      //   "address": address,
      //   "dateA": selectedDate,
      //   "where": where,
      //   "reason": reason,
      //   "days": days,
      //   // "departureDate": selectedDate1,
      //   "place": place,
      //   'document': document,
      //   'imageURL': uploadedURL,
      //   'roomNo': bookedRoom.roomNo
      // });
      // });
    } else {
      // validation error
      setState(() {
        _autovalidate = true;
      });
    }
    Navigator.of(context).pop();
  }

  String? validateName(String val) {
    return val.length == 0 ? "Enter Name First" : null;
  }

  String? validateNationality(String val) {
    return val.length == 0 ? "Enter Nationality First" : null;
  }

  String? validateAddress(String val) {
    return val.length == 0 ? "Enter Address First" : null;
  }

  String? validateDateA(String val) {
    return val.length == 0 ? "Enter Date First" : null;
  }

  String? validateWhere(String val) {
    return val.length == 0 ? "Enter place First" : null;
  }

  String? validateReason(String val) {
    return val.length == 0 ? "Enter Reason First" : null;
  }

  String? validateDays(String val) {
    return val.length == 0 ? "Enter Days First" : null;
  }

  String? validateDateB(String val) {
    return val.length == 0 ? "Enter Date First" : null;
  }

  @override
  void dispose() {
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Room No:${widget.room!.roomNo.toString()}',
            style: TextStyle(color: Colors.black),
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: new Container(
          margin: new EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
          child: new Form(
            key: _key,
            autovalidate: _autovalidate,
            child: formUI(),
          ),
        ),
      ),
    );
  }
}
