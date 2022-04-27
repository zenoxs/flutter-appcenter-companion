import 'package:appcenter_companion/repositories/entities/entities.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class BundledApplication {
  @Id()
  int id;
  String name;

  @Backlink('bundledApplication')
  final linkedApplications = ToMany<LinkedApplication>();

  BundledApplication({this.id = 0, required this.name});
}
