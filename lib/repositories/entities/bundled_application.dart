import 'package:appcenter_companion/repositories/entities/entities.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class BundledApplication {
  @Id(assignable: true)
  int id;
  String name;

  @Backlink('bundledApplication')
  final linkedApplications = ToMany<LinkedApplication>();

  String? get iconUrl {
    String? url;
    for (final linkedApp in linkedApplications) {
      final appIcon = linkedApp.branch.target?.application.target?.iconUrl;
      if (appIcon != null) {
        url = appIcon;
        break;
      }
    }
    return url;
  }

  BundledApplication({this.id = 0, required this.name});
}
