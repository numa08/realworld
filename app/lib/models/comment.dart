import 'package:app/models/models.dart';
import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String body;
  final Profile author;

  Comment(this.id, this.createdAt, this.updatedAt, this.body, this.author)
      : super([id]);
}
