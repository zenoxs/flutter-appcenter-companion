import 'dart:async';

import 'package:appcenter_companion/bloc/authentication/authentication_cubit.dart';
import 'package:appcenter_companion/repositories/appcenter_http.dart';
import 'package:appcenter_companion/repositories/application_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'appcenter_ws_state.dart';

class AppcenterWsCubit extends Cubit<AppcenterWsState> {
  AppcenterWsCubit(
    AppcenterHttp http,
    ApplicationRepository applicationRepository,
    AuthenticationCubit authenticationCubit,
  )   : _http = http,
        _authenticationCubit = authenticationCubit,
        _applicationRepository = applicationRepository,
        super(AppcenterWsInitial()) {
    _authSubscription = _authenticationCubit.stream.listen((state) {
      if (state is AuthenticationStateAuthenticated) {
        _connect();
      }
    });
  }

  final AppcenterHttp _http;
  final AuthenticationCubit _authenticationCubit;
  final ApplicationRepository _applicationRepository;
  late final StreamSubscription _authSubscription;

  List<WebSocketChannel> _channels = [];

  Future<void> _connect() async {
    final apps = await _applicationRepository.apps();

    _channels = await Future.wait(
      apps.map((app) async {
        final wsUrl =
            await _http.post('apps/${app.owner.name}/${app.name}/websockets');

        final channel = WebSocketChannel.connect(Uri.parse(wsUrl.data['url']));

        channel.stream.listen((message) {
          print('ws ${app.name} message: $message');
          // channel.sink.close(status.goingAway);
        }, onError: (error) {
          print('ws ${app.name} error: $error');
        }, onDone: () {
          print('ws ${app.name} done');
        });

        channel.sink.add('{"method":"watch-repo"}');
        return channel;
      }),
    );
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
