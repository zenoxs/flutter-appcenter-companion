import 'package:objectbox/objectbox.dart';

import 'branch.dart';
import 'bundled_application.dart';

@Entity()
class LinkedApplication {
  @Id()
  int id;

  final branch = ToOne<Branch>();
  final bundledApplication = ToOne<BundledApplication>();

  LinkedApplication({this.id = 0});
}
