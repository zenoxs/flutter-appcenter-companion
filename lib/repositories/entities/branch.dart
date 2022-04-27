import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/dto/branch_dto.dart';
import 'package:appcenter_companion/repositories/entities/build.dart';
import 'package:objectbox/objectbox.dart';

import 'remote_object.dart';

@Entity()
class Branch extends RemoteObject {
  @Id()
  int id;
  final String name;
  @override
  final String remoteId;

  @Backlink('sourceBranch')
  final builds = ToMany<Build>();

  final lastBuild = ToOne<Build>();

  Branch({this.id = 0, required this.name, required this.remoteId}) : super();

  static void createFromDto(BranchDto branch, Store store) {}
}
