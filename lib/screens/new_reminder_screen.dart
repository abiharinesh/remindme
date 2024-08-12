import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remindme/general/general.dart';

class NewReminderScreen extends StatefulWidget {
  const NewReminderScreen({super.key});

  @override
  State<NewReminderScreen> createState() => _NewReminderScreenState();
}

class _NewReminderScreenState extends State<NewReminderScreen> {
  final TextEditingController titlecontroller = TextEditingController();
  final TextEditingController descriptioncontroller = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Reminder"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 30, right: 30, bottom: 40, top: 40),
            child: CupertinoTextField(
              controller: titlecontroller,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(225, 225, 225, 1),
                  borderRadius: BorderRadius.circular(12)),
              placeholder: "Title of your reminder...",
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 30, right: 30, bottom: 40, top: 20),
            child: CupertinoTextField(
              controller: descriptioncontroller,
              maxLines: 10,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(225, 225, 225, 1),
                  borderRadius: BorderRadius.circular(12)),
              placeholder: "Description of your reminder...",
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    selectDate(context);
                  },
                  child: Text(selectedDate != null
                      ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                      : "Select Date")),
              TextButton(
                  onPressed: () {
                    selectTime(context);
                  },
                  child: Text(selectedTime != null
                      ? "${selectedTime!.hour}:${selectedTime!.minute}"
                      : "Select Time")),
            ],
          ),
          Container(
              margin: EdgeInsets.only(top: 60),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(222, 243, 199, 1.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (titlecontroller.text.trim().isNotEmpty &&
                        descriptioncontroller.text.trim().isNotEmpty) {
                      if (selectedDate != null && selectedTime != null) {
                        setState(() {
                          isLoading = true;
                        });
                        String reminderID =
                            DateTime.now().millisecondsSinceEpoch.toString() +
                                sharedPreferences!
                                    .getString("uid")!
                                    .substring(0, 3);

                        DateTime finalDateTime = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        );

                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(sharedPreferences!.getString("uid"))
                            .collection("reminders")
                            .doc(reminderID)
                            .set({
                          "reminderID": reminderID,
                          "reminderCreatedDate":
                              DateTime.now().millisecondsSinceEpoch,
                          "reminderTitle": titlecontroller.text,
                          "reminderDescription": descriptioncontroller.text,
                          "reminderDate": finalDateTime,
                          "status": "created",
                          "userID": sharedPreferences!.getString("uid"),
                        }).whenComplete(() {
                          FirebaseFirestore.instance
                              .collection("reminders")
                              .doc(reminderID)
                              .set({
                            "reminderID": reminderID,
                            "reminderCreatedDate":
                                DateTime.now().millisecondsSinceEpoch,
                            "reminderTitle": titlecontroller.text,
                            "reminderDescription": descriptioncontroller.text,
                            "reminderDate": finalDateTime,
                            "status": "created",
                            "userID": sharedPreferences!.getString("uid"),
                          }).whenComplete(() {
                            setState(() {
                              isLoading = false;
                              titlecontroller.clear();
                              descriptioncontroller.clear();
                              selectedDate = null;
                              selectedTime = null;
                              Fluttertoast.showToast(
                                  msg: "Reminder has been successfully created",
                                  timeInSecForIosWeb: 5);
                            });
                          });
                        });
                      } else {
                        Fluttertoast.showToast(
                            msg: "Pick a date and time to continue.");
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: "Title and description are required.");
                    }
                  },
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          "CREATE REMINDER",
                          style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        )))
        ],
      )),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context, initialTime: selectedTime ?? TimeOfDay.now());

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }
}
