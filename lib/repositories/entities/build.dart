import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/dto/build_dto.dart';
import 'package:collection/collection.dart';

// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart';

import 'branch.dart';

// Note: no need remoteObjects here, because the id is already an int
@Entity()
class Build {
  @Id(assignable: true)
  int id;
  final int buildId;
  final String buildNumber;
  final DateTime queueTime;
  final DateTime? startTime;
  final DateTime? finishTime;
  final DateTime lastChangedDate;
  final String sourceVersion;

  final sourceBranch = ToOne<Branch>();

  BuildStatus status;

  int get dbStatus {
    return status.index;
  }

  set dbStatus(int value) {
    status = BuildStatus.values[value];
  }

  BuildResult? result;

  int? get dbResult {
    return result?.index;
  }

  set dbResult(int? value) {
    if (value == null) {
      result = null;
    } else {
      result = BuildResult.values[value];
    }
  }

  Build({
    this.id = 0,
    required this.buildNumber,
    required this.buildId,
    required this.queueTime,
    required this.startTime,
    required this.finishTime,
    required this.lastChangedDate,
    this.status = BuildStatus.unknown,
    this.result = BuildResult.unknown,
    required this.sourceVersion,
  }) : super();

  factory Build.createFromDto(
    BuildDto lastBuild,
    Branch branch,
    Store store,
  ) {
    final box = store.box<Build>();

    final build = Build(
      buildId: lastBuild.id,
      buildNumber: lastBuild.buildNumber,
      queueTime: lastBuild.queueTime,
      startTime: lastBuild.startTime,
      finishTime: lastBuild.finishTime,
      lastChangedDate: lastBuild.lastChangedDate,
      status: lastBuild.status,
      result: lastBuild.result,
      sourceVersion: lastBuild.sourceVersion,
    );
    build.sourceBranch.target = branch;

    // check if there is a build with the same buildId, branch and application
    final QueryBuilder<Build> builder =
        box.query(Build_.buildId.equals(build.buildId));
    builder.link(
      Build_.sourceBranch,
      Branch_.name.equals(branch.name),
    );

    final existingBuild = builder.build().find().firstWhereOrNull((build) {
      return build.sourceBranch.target?.application.target?.remoteId ==
          branch.application.target?.remoteId;
    });

    build.id = existingBuild?.id ?? 0;
    box.put(build);
    return build;
  }
}
