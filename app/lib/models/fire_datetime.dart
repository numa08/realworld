import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class FireDateTime {}

class FieldValueNow extends FireDateTime {}

class TimestampDatetime extends FireDateTime {
  final Timestamp timestamp;

  TimestampDatetime(this.timestamp);

  DateTime get datetime => timestamp.toDate();
}

class FireDatetimeJsonConverter
    implements JsonConverter<FireDateTime, dynamic> {
  const FireDatetimeJsonConverter();

  @override
  // ignore: missing_return
  FireDateTime fromJson(json) {
    if (json is Timestamp) {
      return TimestampDatetime(json);
    }
  }

  @override
  toJson(FireDateTime object) {
    if (object is FieldValueNow) {
      return FieldValue.serverTimestamp();
    }
    if (object is TimestampDatetime) {
      return object.datetime;
    }
  }
}
