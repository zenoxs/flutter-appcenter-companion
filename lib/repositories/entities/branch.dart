import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/dto/branch_dto.dart';
import 'package:appcenter_companion/repositories/entities/build.dart';
// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart';

import 'application.dart';

@Entity()
class Branch {
  @Id(assignable: true)
  int id;
  final String name;

  final bool configured;

  @Backlink('sourceBranch')
  final builds = ToMany<Build>();

  final lastBuild = ToOne<Build>();

  final application = ToOne<Application>();

  Branch({
    this.id = 0,
    required this.name,
    required this.configured,
  }) : super();

  factory Branch.createFromDto(
    BranchDto branchDto,
    Application application,
    Store store,
  ) {
    final box = store.box<Branch>();
    final branch = Branch(
      name: branchDto.branch.name,
      configured: branchDto.configured,
    );
    branch.lastBuild.target = branchDto.lastBuild != null
        ? Build.createFromDto(branchDto.lastBuild!, branch, store)
        : null;
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
