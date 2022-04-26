import 'package:appcenter_companion/bloc/appcenter_ws/appcenter_ws_cubit.dart';
import 'package:appcenter_companion/bloc/authentication/authentication_cubit.dart';
import 'package:appcenter_companion/environment.dart';
import 'package:appcenter_companion/interceptors/authentication_interceptor.dart';
import 'package:appcenter_companion/presentation/app.dart';
import 'package:appcenter_companion/repositories/appcenter_http.dart';
import 'package:appcenter_companion/repositories/application_repository.dart';
import 'package:appcenter_companion/repositories/token_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if it's on the web, windows or android, load the accent color
  if (kIsWeb ||
      [TargetPlatform.windows, TargetPlatform.android]
          .contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
      );
      await windowManager.setMinimumSize(const Size(755, 545));
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }

  final Environment environment = Environment.fromEnvironment();
  final AppcenterHttp appcenterHttp = AppcenterHttp(environment);
  final TokenRepository tokenRepository = TokenRepository();
  final ApplicationRepository applicationRepository =
      ApplicationRepository(appcenterHttp);

  // set up interceptors
  final AuthenticationInterceptor authenticationInterceptor =
      AuthenticationInterceptor(tokenRepository);
  appcenterHttp.interceptors.add(authenticationInterceptor);

  final AuthenticationCubit authenticationCubit = AuthenticationCubit(
    appcenterHttp,
    tokenRepository,
  );
  final AppcenterWsCubit appcenterWsCubit = AppcenterWsCubit(
    appcenterHttp,
    applicationRepository,
    authenticationCubit,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: environment),
        RepositoryProvider.value(value: tokenRepository),
        RepositoryProvider.value(value: appcenterHttp),
        RepositoryProvider.value(value: applicationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authenticationCubit),
          BlocProvider.value(value: appcenterWsCubit),
        ],
        child: const App(),
      ),
    ),
  );
}
