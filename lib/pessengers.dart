import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Pessangers extends StatefulWidget {
  final String? keys;
  Pessangers({this.keys});
  @override
  _TableExample createState() => _TableExample();
}

class _TableExample extends State<Pessangers> {
  final databaseRef = FirebaseDatabase.instance.reference();
  final _formKey = GlobalKey<FormState>();
  TextEditingController edit = new TextEditingController();

  String? address,
      dateA,
      days,
      document,
      imageURL,
      name,
      name2,
      phone,
      place,
      reason,
      roomNo,
      where;
  final pdf = pw.Document();

  displaydialog(String type) {
    return showDialog(
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
                          decoration: InputDecoration(hintText: ''),
                          controller: edit,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text("Submit"),
                          onPressed: () {
                            setState(() {
                              databaseRef
                                  .child('passengers')
                                  .child(widget.keys!)
                                  .update({type: edit.text}).then(
                                      (value) => Navigator.of(context).pop());
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pessenger Details'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder(
        stream: databaseRef.child("passengers").child(widget.keys!).onValue,
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

              return Center(
                  child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Table(
                      //defaultColumnWidth: FixedColumnWidth(120.0),
                      border: TableBorder.all(
                          color: Colors.black,
                          style: BorderStyle.solid,
                          width: 2),
                      children: [
                        TableRow(children: [
                          Column(children: [
                            Text('Name', style: TextStyle(fontSize: 20.0))
                          ]),
                          Column(children: [
                            Text('Details', style: TextStyle(fontSize: 20.0))
                          ]),
                          Column(children: [
                            Text('Edit', style: TextStyle(fontSize: 20.0))
                          ]),
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [Text('Name')]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              Text(data['name'] == null ? '' : data['name'])
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: IconButton(
                                    onPressed: () {
                                      displaydialog('name');
                                    },
                                    icon: Icon(Icons.edit))),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [Text('2nd name')]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              Text(data['name2'] == null ? '' : data['name2'])
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: IconButton(
                                    onPressed: () {
                                      displaydialog('name2');
                                    },
                                    icon: Icon(Icons.edit))),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [Text('Address')]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              Text(data['address'] == null
                                  ? ''
                                  : data['address'])
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: IconButton(
                                    onPressed: () {
                                      displaydialog('address');
                                    },
                                    icon: Icon(Icons.edit))),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [Text('contact no.')]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              Text(data['phone no'] == null
                                  ? ''
                                  : data['phone no'])
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: IconButton(
                                    onPressed: () {
                                      displaydialog('phone no');
                                    },
                                    icon: Icon(Icons.edit))),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [Text('check in')]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              Text(data['dateA'] == null ? '' : data['dateA'])
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: IconButton(
                                    onPressed: () {
                                      displaydialog('dateA');
                                    },
                                    icon: Icon(Icons.edit))),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [Text('check out')]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              Text(data['checkOut'] == null
                                  ? ''
                                  : data['checkOut'])
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: IconButton(
                                    onPressed: () {
                                      displaydialog('checkOut');
                                    },
                                    icon: Icon(Icons.edit))),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [Text('place')]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              Text(data['place'] == null ? '' : data['place'])
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: IconButton(
                                    onPressed: () {
                                      displaydialog('place');
                                    },
                                    icon: Icon(Icons.edit))),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [Text('reason')]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              Text(data['reason'] == null ? '' : data['reason'])
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: IconButton(
                                    onPressed: () {
                                      displaydialog('reason');
                                    },
                                    icon: Icon(Icons.edit))),
                          )
                        ]),

                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [Text('room no.')]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              Text(data['roomNo'] == null ? '' : data['roomNo'])
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: IconButton(
                                    onPressed: () {
                                      displaydialog('roomNo');
                                    },
                                    icon: Icon(Icons.edit))),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [Text('document')]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              Text(data['document'] == null
                                  ? ''
                                  : data['document'])
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: IconButton(
                                    onPressed: () {
                                      displaydialog('document');
                                    },
                                    icon: Icon(Icons.edit))),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [Text('where')]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              Text(data['where'] == null ? '' : data['where'])
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: IconButton(
                                    onPressed: () {
                                      displaydialog('where');
                                    },
                                    icon: Icon(Icons.edit))),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [Text('image')]),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: data['imageURL'].length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () => Navigator.push(context,
                                            MaterialPageRoute(builder: (_) {
                                          return DetailScreen(
                                            url: data['imageURL'][index],
                                          );
                                        })),
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          child: Image.network(
                                              data['imageURL'][index]),
                                        ),
                                      );
                                    }),
                              )),
                          Container()
                        ]),
                        // TableRow(children: [
                        //   Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Column(children: [Text('room no.')]),
                        //   ),
                        //   Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Column(children: [Text(data['roomNo'])]),
                        //   ),
                        //   Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Center(child: Icon(Icons.edit)),
                        //   )
                        // ]),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Icon(
                          Icons.picture_as_pdf_outlined,
                          color: Colors.red,
                        ),
                        onTap: () async {
                          var assetImage = pw.MemoryImage(
                            (await rootBundle.load('assets/declaration.png'))
                                .buffer
                                .asUint8List(),
                          );
                          final font = await rootBundle
                              .load('assets/NotoSans-Regular.ttf');
                          final ttf1 = pw.Font.ttf(font);
                          final font1 = await PdfGoogleFonts.khandRegular();

                          PdfDocument document = PdfDocument();

                          pdf.addPage(
                            pw.MultiPage(
                              pageFormat: PdfPageFormat.a4,
                              margin: pw.EdgeInsets.all(32),
                              build: (pw.Context context) {
                                return <pw.Widget>[
                                  pw.Header(
                                      level: 0,
                                      child: pw.Text('Omkar Lodging')),
                                  // pw.Text('दिनेश  :${data['name']}',
                                  //     style: pw.TextStyle(
                                  //         fontSize: 14, font: font1)),
                                  // pw.Paragraph(
                                  //     text:
                                  //         'second person name :${data['name2']}',
                                  //     style: pw.TextStyle(
                                  //         font: ttf, fontSize: 14)),
                                  // pw.Paragraph(
                                  //     text: 'Room No :${data['roomNo']}',
                                  //     style: pw.TextStyle(
                                  //         font: ttf, fontSize: 14)),
                                  // pw.Paragraph(
                                  //     text: 'Phone no.  :${data['phone no']}',
                                  //     style: pw.TextStyle(
                                  //         font: ttf, fontSize: 14)),
                                  // pw.Paragraph(
                                  //     text: 'Address :${data['address']}',
                                  //     style: pw.TextStyle(
                                  //         font: ttf, fontSize: 14)),
                                  // pw.Paragraph(
                                  //     text: 'Date:${data['dateA']}',
                                  //     style: pw.TextStyle(
                                  //         font: ttf, fontSize: 14)),
                                  // pw.Paragraph(
                                  //     text: 'From :${data['place']}',
                                  //     style: pw.TextStyle(
                                  //         font: ttf, fontSize: 14)),
                                  // pw.Paragraph(
                                  //     text: 'Reason:${data['reason']}',
                                  //     style: pw.TextStyle(
                                  //         font: ttf, fontSize: 14)),
                                  // pw.Paragraph(
                                  //     text: 'Days :${data['days']}',
                                  //     style: pw.TextStyle(
                                  //         font: ttf, fontSize: 14)),
                                  // pw.Paragraph(
                                  //     text: 'Where to go :${data['where']}',
                                  //     style: pw.TextStyle(
                                  //         font: ttf, fontSize: 14)),
                                  // pw.Paragraph(
                                  //     text: 'Document:${data['document']}',
                                  //     style: pw.TextStyle(
                                  //         font: ttf, fontSize: 14)),
                                  pw.Image(assetImage),
                                ];
                              },
                            ),
                          );
                          for (var i = 0; i < data['imageURL'].length; i++) {
                            var formatter =
                                new DateFormat('dd-MM-yyyy kk:mm:a');
                            var parsedDate = DateTime.parse(data['dateA']);
                            String formattedDate = formatter.format(parsedDate);
                            await Printing.layoutPdf(
                                onLayout: (PdfPageFormat format) async =>
                                    await Printing.convertHtml(
                                      format: format,
                                      html:
                                          '<html><body><p style="font-size:18;">नाव : ${data['name']}<br>सोबत आलेल्या व्यक्तीचे नाव: ${data['name2']}<br>रूम नं : ${data['roomNo']}<br>फोन नं : ${data['phone no']}<br>पत्ता : ${data['address']}<br>तारीख आणि वेळ : $formattedDate<br>कोठून आला? :${data['place']}<br>कारण : ${data['reason']}<br>किती दिवस राहणार? :${data['days']}<br>कोठे जाणार तो पत्ता ? :${data['where']}<br>ओळखपत्र : ${data['document']}<br><br><br><img src="${data['imageURL'][i]}" width="200" height="200" ><br><br>आम्ही दोघेही एकाच विचाराचे असलेने व सज्ञान असलेने एकमेकांचे पसंतीने आम्हापैकी कोणावरही  दडपण किंवा जोरजुलुम केलेला नाही . आम्ही लॉजची रूम भाड्याने घेत असतेवेळी व्यवस्थापक यांना वय पूर्ण असलेले ओळखपत्र दाखवलेले आहे. आम्ही एकमेकांच्या संमतीने लॉजमध्ये आलेलो आहोत .त्यामुळे या गोष्टीस लॉज मालक /चालक/व्यवस्थापक जबाबदार असणार नाहीत /त्यांचा काहीही दोष नाही .</p></body></html>', // pass generated html here
                                    ));
                          }

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
                        },
                      ),
                    ),
                  )
                ]),
              ));
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

class DetailScreen extends StatelessWidget {
  final String? url;
  DetailScreen({this.url});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: InteractiveViewer(child: Image.network(url!)),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
