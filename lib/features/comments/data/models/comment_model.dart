import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/comment_entity.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.name,
    required super.email,
    required super.body,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      postId: postId,
      name: name,
      email: email,
      body: body,
    );
  }
}
