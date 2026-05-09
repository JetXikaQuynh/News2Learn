import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 2)
class UserModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String email;

  @HiveField(2)
  String name;

  @HiveField(3)
  String? avatar;

  @HiveField(4)
  DateTime createdAt;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    this.avatar,
    required this.createdAt,
  });
}
