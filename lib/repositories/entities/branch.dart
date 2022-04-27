import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/dto/branch_dto.dart';
import 'package:appcenter_companion/repositories/entities/build.dart';
import 'package:objectbox/objectbox.dart';

import 'application.dart';

@Entity()
class Branch {
  @Id()
  int id;
  final String name;

  @Backlink('sourceBranch')
  final builds = ToMany<Build>();

  final lastBuild = ToOne<Build>();

  final application = ToOne<Application>();

  Branch({this.id = 0, required this.name}) : super();

  static Branch createFromDto(
      BranchDto branchDto, Application application, Store store) {
    final box = store.box<Branch>();
    final branch = Branch(
      name: branchDto.branch.name,
    );
    branch.lastBuild.target = Build.createFromDto(branchDto.lastBuild, store);
    branch.application.target = application;

    final QueryBuilder<Branch> builder =
        box.query(Branch_.name.equals(branch.name));
    builder.link(Branch_.application, Application_.id.equals(application.id));

    final existing = builder.build().findFirst();
    branch.id = existing?.id ?? 0;
    box.put(branch);

    return branch;
  }
}
