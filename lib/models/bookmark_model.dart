import 'package:hive/hive.dart';

part 'bookmark_model.g.dart';

@HiveType(typeId: 1)
class BookmarkModel {
  @HiveField(0)
  String bmId;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String articleId;

  BookmarkModel({
    required this.bmId,
    required this.userId,
    required this.articleId,
  });
}
