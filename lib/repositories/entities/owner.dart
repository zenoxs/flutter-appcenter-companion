import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/dto/app_dto.dart';
import 'package:objectbox/objectbox.dart';

import 'application.dart';
import 'remote_object.dart';

@Entity()
class Owner implements RemoteObject {
  @Id()
  int id;
  final String name;
  @override
  final String remoteId;

  @Backlink('owner')
  final applications = ToMany<Application>();

  Owner({this.id = 0, required this.name, required this.remoteId}) : super();

  static Owner createFromDto(OwnerDto ownerDto, Store store) {
    final box = store.box<Owner>();
    final owner = Owner(
      remoteId: ownerDto.id,
      name: ownerDto.name,
    );
    final existing =
        box.query(Owner_.remoteId.equals(owner.remoteId)).build().findFirst();
    owner.id = existing?.id ?? 0;
    box.put(owner);

    return owner;
  }
}
