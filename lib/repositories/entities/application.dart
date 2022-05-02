import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/repositories/dto/app_dto.dart';
// ignore: unnecessary_import
import 'package:objectbox/objectbox.dart';

import 'owner.dart';
import 'remote_object.dart';

@Entity()
class Application extends RemoteObject {
  @Id(assignable: true)
  int id;
  final String name;
  final String displayName;
  final String? description;
  final String? iconUrl;
  @override
  final String remoteId;

  final owner = ToOne<Owner>();

  @Transient()
  Os os;

  int get dbOs {
    return os.index;
  }

  set dbOs(int value) {
    os = Os.values[value];
  }

  @Transient()
  Platform platform;

  int get dbPlatform {
    return platform.index;
  }

  set dbPlatform(int value) {
    platform = Platform.values[value];
  }

  Application({
    this.id = 0,
    this.os = Os.unknown,
    this.platform = Platform.unknown,
    this.description,
    this.iconUrl,
    required this.name,
    required this.displayName,
    required this.remoteId,
  }) : super();

  Application copyWith({
    int? id,
    String? name,
    String? remoteId,
    String? iconUrl,
    String? displayName,
    Platform? platform,
    String? description,
    Os? os,
  }) {
    return Application(
      id: id ?? this.id,
      name: name ?? this.name,
      os: os ?? this.os,
      platform: platform ?? this.platform,
      iconUrl: iconUrl ?? this.iconUrl,
      description: description ?? this.description,
      displayName: displayName ?? this.displayName,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  factory Application.createFromDto(AppDto appDto, Store store) {
    final box = store.box<Application>();
    final app = Application(
      name: appDto.name,
      displayName: appDto.displayName,
      os: appDto.os,
      iconUrl: appDto.iconUrl,
      platform: appDto.platform,
      description: appDto.description,
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
