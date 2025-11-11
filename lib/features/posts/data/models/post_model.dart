import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/post_entity.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  PostEntity toEntity() {
    return PostEntity(id: id, userId: userId, title: title, body: body);
  }
}
