import 'dart:io';

import 'package:appcenter_companion/presentation/home/home_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';

import 'theme.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AppTheme appTheme = AppTheme();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appTheme,
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp(
          title: 'Appcenter Companion',
          color: appTheme.color,
          themeMode: appTheme.mode,
          home: const HomeScreen(),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            scaffoldBackgroundColor: Colors.grey[190],
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          theme: ThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          builder: (context, child) {
            appTheme.setEffect(
              Platform.isWindows
                  ? flutter_acrylic.WindowEffect.acrylic
                  : flutter_acrylic.WindowEffect.disabled,
              context,
              notify: false,
            );
            return Directionality(
              textDirection: appTheme.textDirection,
              child: NavigationPaneTheme(
                data: NavigationPaneThemeData(
                  backgroundColor: appTheme.windowEffect !=
                          flutter_acrylic.WindowEffect.disabled
                      ? Colors.transparent
                      : null,
                ),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
