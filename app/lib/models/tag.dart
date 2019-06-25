import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable()
class Tag {
  Tag(this.articleRef, this.tag);

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  final String articleRef;
  final String tag;

  Map<String, dynamic> toJson() => _$TagToJson(this);
}
