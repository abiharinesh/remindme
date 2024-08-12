import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remindme/auth/login_screen.dart';
import 'package:remindme/general/general.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/homescreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
              child: Text("Sign Up here", style: TextStyle(
                fontSize: 20
              ),),
            ),

            Container(
              margin: EdgeInsets.only(left: 30, right: 30, bottom: 40, top: 80),
              child: CupertinoTextField(
                controller: fullnameController,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(225, 225, 225, 1),
                  borderRadius: BorderRadius.circular(12)
                ),
                placeholder: "Enter your fullname...",
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 30, right: 30, bottom: 40),
              child: CupertinoTextField(
                controller: emailController,
                padding: EdgeInsets.all(10),
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
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(225, 225, 225, 1),
                    borderRadius: BorderRadius.circular(12)
                ),
                placeholder: "Enter your password...",
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, bottom: 40),
              child: CupertinoTextField(
                controller: confPasswordController,
                obscureText: true,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(225, 225, 225, 1),
                    borderRadius: BorderRadius.circular(12)
                ),
                placeholder: "Confirm your password...",
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(222, 243, 199, 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  )
                ),
                onPressed: () {
                  if(passwordController.text.trim().isNotEmpty) {
                    if(passwordController.text.trim() == confPasswordController.text.trim()) {
                      if(fullnameController.text.trim().isNotEmpty && emailController.text.trim().isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });
                        signUpUser();

                      } else {
                        Fluttertoast.showToast(msg: "All fields are required");
                      }
                    } else {
                      Fluttertoast.showToast(msg: "The passwords do no match");
                    }
                  } else {
                    Fluttertoast.showToast(msg: "The password cannot be empty");
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
                      => LoginScreen()));
                },
                child: Text("Sign In here"),
              ),
            ),

          ],
        ),
      ),
    );
  }

  void signUpUser() async{
    User? currentUser;
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text).then((value) {
          currentUser = value.user;
    }).catchError((error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "The user failed to sign up");
    });

    if(currentUser != null) {
      FirebaseFirestore.instance.collection("users").doc(currentUser!.uid).set({
        "uid": currentUser!.uid,
        "email": currentUser!.email,
        "fullname": fullnameController.text,
        "status": "approved",
        "token": ""
      });
    }

    sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences!.setString("uid", currentUser!.uid);
    await sharedPreferences!.setString("email", currentUser!.email!);
    await sharedPreferences!.setString("fullname", fullnameController.text);
    await sharedPreferences!.setString("status", "approved");

    setState(() {
      isLoading = false;
      sharedPreferences;
    });

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Homescreen()));

  }
}