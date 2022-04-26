import 'package:objectbox/objectbox.dart';

@Entity()
class BundleApplication {
  int id;
  String name;

  BundleApplication({required this.id, required this.name});
}
