import 'package:appcenter_companion/presentation/theme.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

bool get kIsWindowEffectsSupported {
  return !kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return ScaffoldPage.scrollable(
      scrollController: _scrollController,
      header: const PageHeader(
        title: Text('Settings'),
      ),
      children: [
        InfoLabel(
          label: 'Theme mode',
          child: Wrap(
            spacing: 10,
            children: [
              ...List.generate(ThemeMode.values.length, (index) {
                final mode = ThemeMode.values[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: RadioButton(
                    checked: appTheme.mode == mode,
                    onChanged: (value) {
                      if (value) {
                        appTheme.mode = mode;

                        if (kIsWindowEffectsSupported) {
                          // some window effects require on [dark] to look good.
                          appTheme.setEffect(appTheme.windowEffect, context);
                        }
                      }
                    },
                    content: Text('$mode'.replaceAll('ThemeMode.', '')),
                  ),
                );
              }),
            ],
          ),
        )
      ],
    );
  }
}
