import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/dto/commit_dto.dart';
// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart';

import 'branch.dart';

@Entity()
class Commit {
  @Id(assignable: true)
  int id;

  final String url;
  final String sha;

  @Property(type: PropertyType.date)
  final DateTime createdAt;

  Commit({
    this.id = 0,
    required this.url,
    required this.sha,
    required this.createdAt,
  }) : super();

  factory Commit.createFromDto(
    BranchCommitDto branchCommitDto,
    Branch branch,
    Store store,
  ) {
    final box = store.box<Commit>();

    // remove previous branch commit
    final currentBranchCommit = branch.commit.target;
    if (currentBranchCommit != null) {
      box.remove(currentBranchCommit.id);
    }

    final commit = Commit(
      url: branchCommitDto.url,
      sha: branchCommitDto.sha,
      createdAt: DateTime.now(),
    );

    box.put(commit);

    return commit;
  }
}
