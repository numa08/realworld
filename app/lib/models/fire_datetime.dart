import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class FireDateTime {
  DateTime get dateTime;
}

class FieldValueNow extends FireDateTime {
  @override
  DateTime get dateTime => null;
}

class TimestampDatetime extends FireDateTime {
  TimestampDatetime(this.timestamp);

  final Timestamp timestamp;

  @override
  DateTime get dateTime => timestamp.toDate();
}

class FireDatetimeJsonConverter
    implements JsonConverter<FireDateTime, dynamic> {
  const FireDatetimeJsonConverter();

  @override
  FireDateTime fromJson(dynamic json) {
    if (json is Timestamp) {
      return TimestampDatetime(json);
    }
    throw ArgumentError(
        ['FieldValue.serverTimestamp should not be serialized.']);
  }

  @override
  dynamic toJson(FireDateTime object) {
    if (object is FieldValueNow) {
      return FieldValue.serverTimestamp();
    }
    if (object is TimestampDatetime) {
      return object.dateTime;
    }
  }
}
