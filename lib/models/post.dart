import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
abstract class Post with _$Post {
  const factory Post({
    required int id,
    required int userId,
    required String title,
    required String body,
    @Default([]) List<String> tags,
    @Default(0) int views,
    Reactions? reactions,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

@freezed
abstract class Reactions with _$Reactions {
  const factory Reactions({
    @Default(0) int likes,
    @Default(0) int dislikes,
  }) = _Reactions;

  factory Reactions.fromJson(Map<String, dynamic> json) =>
      _$ReactionsFromJson(json);
}
