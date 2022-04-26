import 'package:appcenter_companion/repositories/entities/application.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class BundledApplication {
  @Id()
  int id;
  String name;

  final applications = ToMany<Application>();

  BundledApplication({this.id = 0, required this.name});
}
