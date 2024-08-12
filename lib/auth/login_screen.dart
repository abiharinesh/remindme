import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remindme/auth/register_screen.dart';
import 'package:remindme/general/general.dart';
import 'package:remindme/screens/homescreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 100, left: 40),
                child: Text("RemindMe", style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold
                ),)
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.only(top: 40, right: 20),
              child: Text("Sign In here", style: TextStyle(
                  fontSize: 20
              ),),
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, bottom: 40, top: 100),
              child: CupertinoTextField(
                controller: emailController,
                padding: EdgeInsets.all(13),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(225, 225, 225, 1),
                    borderRadius: BorderRadius.circular(12)
                ),
                placeholder: "Enter your email address...",
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 30, right: 30, bottom: 40),
              child: CupertinoTextField(
                controller: passwordController,
                obscureText: true,
                padding: EdgeInsets.all(13),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(225, 225, 225, 1),
                    borderRadius: BorderRadius.circular(12)
                ),
                placeholder: "Enter your password...",
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 100),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(222, 243, 199, 1.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                    )
                ),
                onPressed: () async {
                  if(emailController.text.trim().isNotEmpty
                  && passwordController.text.trim().isNotEmpty) {
                    setState(() {
                      isLoading = true;
                    });
                    User? currentUser;

                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text
                    ).then((auth) {
                      currentUser = auth.user;
                    }).catchError((error) {
                      Fluttertoast.showToast(msg: "Error while signing user in");
                    });

                    if(currentUser != null) {
                      await FirebaseFirestore.instance.collection("users")
                          .doc(currentUser!.uid).get().then((snapshot) async {
                            if(snapshot.exists) {
                              await sharedPreferences!.setString("status", snapshot.data()!['status']);

                              if(snapshot.data()!['status'] == "approved") {
                                await sharedPreferences!.setString("uid", snapshot.data()!['uid']);
                                await sharedPreferences!.setString("fullname", snapshot.data()!['uid']);
                                await sharedPreferences!.setString("email", snapshot.data()!['email']);

                                setState(() {
                                  isLoading = false;
                                });

                                Navigator.pushReplacement(context, MaterialPageRoute(
                                    builder: (BuildContext ctx) => Homescreen()));
                              } else {
                                FirebaseAuth.instance.signOut();
                                Navigator.pushReplacement(context, MaterialPageRoute(
                                    builder: (BuildContext ctx) => LoginScreen()));
                                Fluttertoast.showToast(msg: "You have been blocked");
                              }
                            }
                      });
                    }

                  } else {
                    Fluttertoast.showToast(msg: "Email and password are required");
                  }
                },
                child: isLoading ? CircularProgressIndicator() : Text("CONTINUE", style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                ),),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 40, right: 20),
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (BuildContext ctx)
                      => RegisterScreen()));
                },
                child: Text("Sign Up here"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}