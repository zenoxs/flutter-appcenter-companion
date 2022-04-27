import 'package:appcenter_companion/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

import 'branch.dart';

// Note: no need remoteObjects here, because the id is already an int
@Entity()
class Build {
  @Id()
  int id;
  final String buildNumber;
  final DateTime queueTime;
  final DateTime startTime;
  final DateTime finishTime;
  final DateTime lastChangedDate;
  final String status;
  final String result;
  final String sourceVersion;

  final sourceBranch = ToOne<Branch>();

  Build({
    this.id = 0,
    required this.buildNumber,
    required this.queueTime,
    required this.startTime,
    required this.finishTime,
    required this.lastChangedDate,
    required this.status,
    required this.result,
    required this.sourceVersion,
  }) : super();
}
