import 'package:appcenter_companion/bloc/bloc.dart';
import 'package:appcenter_companion/environment.dart';
import 'package:appcenter_companion/interceptors/authentication_interceptor.dart';
import 'package:appcenter_companion/presentation/app.dart';
import 'package:appcenter_companion/repositories/repositories.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'objectbox.g.dart';

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

  final store = await openStore(macosApplicationGroup: 'ac-companion');

  final Environment environment = Environment.fromEnvironment();
  final AppcenterHttp appcenterHttp = AppcenterHttp(environment);
  final TokenRepository tokenRepository = TokenRepository();

  final AuthenticationCubit authenticationCubit = AuthenticationCubit(
    appcenterHttp,
    tokenRepository,
  );
  // set up interceptors
  final AuthenticationInterceptor authenticationInterceptor =
      AuthenticationInterceptor(tokenRepository);
  appcenterHttp.interceptors.add(authenticationInterceptor);

  final BranchRepository branchRepository =
      BranchRepository(appcenterHttp, store);
  final ApplicationRepository applicationRepository = ApplicationRepository(
    appcenterHttp,
    store,
    branchRepository,
  );
  final BundledApplicationRepository bundledApplicationRepository =
      BundledApplicationRepository(
    store,
    applicationRepository,
    appcenterHttp,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: environment),
        RepositoryProvider.value(value: tokenRepository),
        RepositoryProvider.value(value: appcenterHttp),
        RepositoryProvider.value(value: applicationRepository),
        RepositoryProvider.value(value: branchRepository),
        RepositoryProvider.value(value: bundledApplicationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authenticationCubit),
        ],
        child: const App(),
      ),
    ),
  );
}
