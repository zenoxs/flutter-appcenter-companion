import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/dto/app_dto.dart';
import 'package:objectbox/objectbox.dart';

import 'owner.dart';
import 'remote_object.dart';

@Entity()
class Application extends RemoteObject {
  @Id()
  int id;
  final String name;
  @override
  final String remoteId;

  final owner = ToOne<Owner>();

  Application({this.id = 0, required this.name, required this.remoteId})
      : super();

  Application copyWith({int? id, String? name, String? remoteId}) {
    return Application(
      id: id ?? this.id,
      name: name ?? this.name,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  static Application createFromDto(AppDto appDto, Store store) {
    final box = store.box<Application>();
    final app = Application(
      name: appDto.name,
      remoteId: appDto.id,
    );
    app.owner.target = Owner.createFromDto(appDto.owner, store);
    final existing = box
        .query(Application_.remoteId.equals(app.remoteId))
        .build()
        .findFirst();
    app.id = existing?.id ?? 0;
    box.put(app);

    return app;
  }
}
