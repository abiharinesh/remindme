import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  int? reminderCreatedDate;
  Timestamp? reminderDate;
  String? reminderDescription;
  String? reminderID;
  String? reminderTitle;
  String? status;
  String? userID;

  Reminder({
    this.reminderCreatedDate,
    this.reminderDate,
    this.reminderDescription,
    this.reminderID,
    this.reminderTitle,
    this.status,
    this.userID
});

  Reminder.fromJson(Map<String, dynamic> json) {
    reminderCreatedDate = json["reminderCreatedDate"];
    reminderDate = json["reminderDate"];
    reminderDescription = json["reminderDescription"];
    reminderID = json["reminderID"];
    reminderTitle = json["reminderTitle"];
    status = json["status"];
    userID = json["userID"];
  }

  Reminder.toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["reminderCreatedDate"] = reminderCreatedDate;
    data["reminderDate"] = reminderDate;
    data["reminderDescription"] = reminderDescription;
    data["reminderID"] = reminderID;
    data["reminderTitle"] = reminderTitle;
    data["status"] = status;
    data["userID"] = userID;
  }
}