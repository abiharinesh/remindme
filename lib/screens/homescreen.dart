import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:remindme/general/general.dart';
import 'package:remindme/models/reminder.dart';
import 'package:remindme/screens/new_reminder_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveAndStoreToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "RemindMe",
          style: TextStyle(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(left: 20, top: 10),
              child: Text(
                "My Reminders",
                style: TextStyle(
                  fontSize: 23,
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(sharedPreferences!.getString("uid")!)
                .collection("reminders")
                .snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                Reminder model = Reminder.fromJson(
                                    snapshot.data!.docs[index].data()!
                                        as Map<String, dynamic>);

                                return Container(
                                    margin: EdgeInsets.only(
                                        top: 20, left: 25, right: 25),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              offset: Offset(3, 3),
                                              blurRadius: 15,
                                              color:
                                                  Colors.grey.withOpacity(0.4))
                                        ]),
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              model.reminderTitle!,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(model.reminderDescription!),
                                            Container(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Date: ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(displayDate(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          model.reminderDate!
                                                              .millisecondsSinceEpoch))),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  "Status: ${model.status}"),
                                            )
                                          ],
                                        ),
                                        Positioned(
                                            right: 0,
                                            child: IconButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection("reminders")
                                                    .doc(model.reminderID)
                                                    .delete()
                                                    .whenComplete(() {
                                                  FirebaseFirestore.instance
                                                      .collection("users")
                                                      .doc(sharedPreferences!
                                                          .getString("uid"))
                                                      .collection("reminders")
                                                      .doc(model.reminderID)
                                                      .delete()
                                                      .whenComplete(() {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Reminder deleted succesfully");
                                                  });
                                                });
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                            ))
                                      ],
                                    ));
                              })));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext ctx) => NewReminderScreen(),
                    fullscreenDialog: true));
          },
          label: Icon(
            Icons.add_rounded,
            size: 30,
          )),
    );
  }

  String displayDate(DateTime reminderDate) {
    int hour = reminderDate.hour;
    int minute = reminderDate.minute;
    int second = reminderDate.second;
    int day = reminderDate.day;
    int month = reminderDate.month;
    int year = reminderDate.year;

    return " $day-$month-$year at $hour:$minute:$second";
  }

  retrieveAndStoreToken() async {
    FirebaseMessaging.instance.requestPermission();
    String? myToken = await FirebaseMessaging.instance.getToken();

    if (myToken != null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(sharedPreferences!.getString("uid"))
          .update({"token": myToken});
    }
  }
}
