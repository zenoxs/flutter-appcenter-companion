import 'dart:async';
import 'dart:convert';

import 'package:appcenter_companion/repositories/appcenter_http.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'dto/dto.dart';
import 'entities/entities.dart';

class AppWebSocketChannel {
  AppWebSocketChannel._({
    required LinkedApplication linkedApplication,
    required String wsUrl,
  }) : _linkedApplication = linkedApplication {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channelSubscription = _channel.stream.listen(
      (message) {
        debugPrint('ws ${_application.name} message: $message');
        final event = WsAppEvent.fromJson(jsonDecode(message));

        if (event is WsAppEventBuild) {
          if (event.data.sourceBranch ==
              _linkedApplication.branch.target!.name) {
            if (!_subscribedBuildIds.contains(event.data.id)) {
              _method(WsMethod.subscribe(event.data.id));
              _subscribedBuildIds.add(event.data.id);
            }
            _eventController.add(event);
          }
        } else {
          _eventController.add(event);
        }
      },
      onError: (error) {
        debugPrint('ws ${_application.name} error: $error');
      },
      onDone: () {
        debugPrint('ws ${_application.name} done');
      },
    );
    _method(const WsMethod.watchRepo());
  }

  final LinkedApplication _linkedApplication;
  late final WebSocketChannel _channel;
  late final StreamSubscription _channelSubscription;
  final _subscribedBuildIds = <int>{};
  final _eventController = StreamController<WsAppEvent>();

  Application get _application =>
      _linkedApplication.branch.target!.application.target!;

  Stream<WsAppEvent> get event => _eventController.stream;

  static Future<AppWebSocketChannel> connect({
    required AppcenterHttp http,
    required LinkedApplication linkedApplication,
  }) async {
    final application = linkedApplication.branch.target!.application.target!;
    final res = await http.post(
      'apps/${application.owner.target!.name}/${application.name}/websockets',
    );
    final data = CreateWSResponseDto.fromJson(res.data);

    return AppWebSocketChannel._(
      linkedApplication: linkedApplication,
      wsUrl: data.url,
    );
  }

  void _method(WsMethod method) {
    _channel.sink.add(jsonEncode(method.toJson()));
  }

  void close() {
    _channelSubscription.cancel();
    _eventController.close();
    _channel.sink.close();
  }
}
