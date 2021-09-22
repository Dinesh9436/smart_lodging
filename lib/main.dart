import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:lodging/home.dart';
import 'package:lodging/splashScreen.dart';
import './constants.dart' as Constants;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:page_transition/page_transition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    routes: {
      '/': (context) => AnimatedSplashScreen(),
      '/home': (context) => HomeScreen(),
      '/signin': (context) => MyHomePage(),
    },
  ));
}

final key = new GlobalKey<HomeScreenState>();

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  bool? _success;
  String? _userEmail;

  GlobalKey<FormState> _key = new GlobalKey();
  final databaseRef = FirebaseDatabase.instance.reference();

  bool _validate = false;
  String? email, password;

  String? validatePassword(String? value) {
    if (value!.length < 6)
      return 'Password must be more than 5 charaters';
    else
      return null;
  }

  String? validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern as String);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
      ),
      body: StreamBuilder(
        stream: databaseRef.child("users").onValue,
        builder: (context, AsyncSnapshot<dynamic> snap) {
          if (snap.hasData) {
            Map<dynamic, dynamic> data = snap.data.snapshot.value;

            if (data == null) {
              return Center(
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              Map<dynamic, dynamic> data = snap.data.snapshot.value;
              print(data);
              List<dynamic> keyss = data.keys.toList();
              List<dynamic> emails = [];
              List<dynamic> pass = [];
              List<dynamic> role = [];

              data.forEach((key, value) {
                emails.add(value["email"]);
                pass.add(value["password"]);
                role.add(value["role"]);
              });

              return Column(
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Image.asset('assets/smart-lodging-logo.png')),
                  Form(
                      key: _key,
                      autovalidate: _validate,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 32.0, right: 16.0, left: 16.0),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                  color: Colors.indigo,
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ConstrainedBox(
                            constraints:
                                BoxConstraints(minWidth: double.infinity),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 32.0, right: 24.0, left: 24.0),
                              child: TextFormField(
                                  textAlignVertical: TextAlignVertical.center,
                                  textInputAction: TextInputAction.next,
                                  //validator: validateEmail,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context).nextFocus(),
                                  controller: _emailController,
                                  style: TextStyle(fontSize: 18.0),
                                  keyboardType: TextInputType.emailAddress,
                                  cursorColor: Constants.COLOR_PRIMARY,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.only(
                                          left: 16, right: 16),
                                      fillColor: Colors.white,
                                      hintText: 'E-mail Address',
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                              color: Constants.COLOR_PRIMARY,
                                              width: 2.0)),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ))),
                            ),
                          ),
                          ConstrainedBox(
                            constraints:
                                BoxConstraints(minWidth: double.infinity),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 32.0, right: 24.0, left: 24.0),
                              child: TextFormField(
                                  obscureText: true,
                                  textAlignVertical: TextAlignVertical.center,
                                  validator: validatePassword,
                                  controller: _passwordController,
                                  textInputAction: TextInputAction.done,
                                  style: TextStyle(fontSize: 18.0),
                                  cursorColor: Constants.COLOR_PRIMARY,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.only(
                                          left: 16, right: 16),
                                      fillColor: Colors.white,
                                      hintText: 'Password',
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                              color: Constants.COLOR_PRIMARY,
                                              width: 2.0)),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 40.0, left: 40.0, top: 40),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  minWidth: double.infinity),
                              child: RaisedButton(
                                color: Constants.COLOR_PRIMARY,
                                child: Text(
                                  'Log In',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                textColor: Colors.white,
                                splashColor: Constants.COLOR_PRIMARY,
                                onPressed: () async {
                                  var retrievedName;

                                  showLoaderDialog(context);

                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  for (var i = 0; i < keyss.length; i++) {
                                    print(_emailController.text);
                                    if (_emailController.text == emails[i] &&
                                        _passwordController.text == pass[i]) {
                                      await prefs.setString('email', emails[i]);
                                      await prefs.setString('role', role[i]);

                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil('/home',
                                              (Route<dynamic> route) => false);
                                    }
                                  }

                                  // keyss.for((element) {
                                  //   print(_emailController.text);
                                  //   if (_emailController.text ==
                                  //           data.value['email'] &&
                                  //       _passwordController.text ==
                                  //           data.value['password']) {
                                  //     prefs.setString(
                                  //         email, data.value['email']);
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //           builder: (context) =>
                                  //               HomeScreen()),
                                  //     );
                                  //   } else {
                                  //     // Navigator.of(context).pop();
                                  //     Toast.show(
                                  //         "please enter valid  details",
                                  //         context,
                                  //         duration: Toast.LENGTH_SHORT,
                                  //         gravity: Toast.BOTTOM);
                                  //   }
                                  // });

                                  //push(context, HomeScreen());
                                },
                                padding: EdgeInsets.only(top: 12, bottom: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    side: BorderSide(
                                        color: Constants.COLOR_PRIMARY)),
                              ),
                            ),
                          ),
                        ],
                      )

                      /* Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: double.infinity),
                      child: RaisedButton.icon(
                        label: Text(
                          'Facebook Login',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        icon: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Image.asset(
                            'assets/images/facebook_logo.png',
                            color: Colors.white,
                            height: 30,
                            width: 30,
                          ),
                        ),
                        color: Color(Constants.FACEBOOK_BUTTON_COLOR),
                        textColor: Colors.white,
                        splashColor: Color(Constants.FACEBOOK_BUTTON_COLOR),
                        onPressed: () async {
                          final facebookLogin = FacebookLogin();
                          final result = await facebookLogin.logIn(['email']);
                          switch (result.status) {
                            case FacebookLoginStatus.loggedIn:
                              showProgress(
                                  context, 'Logging in, please wait...', false);
                              await FirebaseAuth.instance
                                  .signInWithCredential(
                                      FacebookAuthProvider.getCredential(
                                          accessToken: result.accessToken.token))
                                  .then((AuthResult authResult) async {
                                User user = await _fireStoreUtils
                                    .getCurrentUser(authResult.user.uid);
                                if (user == null) {
                                  _createUserFromFacebookLogin(
                                      result, authResult.user.uid);
                                } else {
                                  _syncUserDataWithFacebookData(result, user);
                                }
                              });
                              break;
                            case FacebookLoginStatus.cancelledByUser:
                              break;
                            case FacebookLoginStatus.error:
                              showAlertDialog(
                                  context, 'Error', 'Couldn\'t login via facebook.');
                              break;
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(
                                color: Color(Constants.FACEBOOK_BUTTON_COLOR))),
                      ),
                    ),
                  ),*/

                      ),
                ],
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
    );
  }
}
