import 'dart:io';

import 'package:appcenter_companion/presentation/app_list/app_list_screen.dart';
import 'package:appcenter_companion/presentation/home/authentication_dialog.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';
import 'package:window_manager/window_manager.dart';

import '../settings/settings_screen.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  final viewKey = GlobalKey();

  int _selectedScreen = 0;
  late final List<Widget> _screens = [
    AppListScreen(
      onLogin: onLogin,
    ),
    Container(),
    Container(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final theme = FluentTheme.of(context);
    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
        title: const DragToMoveArea(child: SizedBox.expand()),
        automaticallyImplyLeading: false,
        height: 30,
        actions: (Platform.isWindows || Platform.isLinux)
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [Spacer(), _WindowButtons()],
              )
            : null,
      ),
      pane: NavigationPane(
        selected: _selectedScreen,
        onChanged: (i) => setState(() {
          _selectedScreen = i;
        }),
        size: const NavigationPaneSize(
          openMinWidth: 200,
          openMaxWidth: 280,
        ),
        header: Container(
          height: kOneLineTileHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'AC Companion',
              style: FluentTheme.of(context).typography.title!.copyWith(
                    fontSize:
                        appTheme.displayMode == PaneDisplayMode.top ? 20 : 22.0,
                  ),
            ),
          ),
        ),
        displayMode: appTheme.displayMode,
        indicator: () {
          switch (appTheme.indicator) {
            case NavigationIndicators.end:
              return const EndNavigationIndicator();
            case NavigationIndicators.sticky:
            default:
              return const StickyNavigationIndicator();
          }
        }(),
        items: [
          // It doesn't look good when resizing from compact to open
          // PaneItemHeader(header: Text('User Interaction')),
          PaneItem(
            icon: const Icon(FluentIcons.all_apps),
            title: const Text('Apps'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.build),
            title: const Text('Builds'),
          ),
          PaneItemSeparator(),
        ],
        footerItems: [
          PaneItemSeparator(),
          _LinkPaneItemAction(
            icon: const Icon(FluentIcons.user_sync),
            title: const Text('Login'),
            action: onLogin,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
          ),
        ],
      ),
      content: Container(
        color: theme.scaffoldBackgroundColor,
        // TODO find a solution to keep animation and state widget state
        child: IndexedStack(
          index: _selectedScreen,
          children: _screens,
        ),
      ),
    );
  }

  void onLogin() {
    showDialog(
      context: context,
      builder: (context) => const AuthenticationDialog(),
    );
  }
}

class _WindowButtons extends StatelessWidget {
  const _WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _LinkPaneItemAction extends PaneItem {
  _LinkPaneItemAction({
    required Widget icon,
    this.link,
    this.action,
    title,
    infoBadge,
    focusNode,
    autofocus = false,
  }) : super(
          icon: icon,
          title: title,
          infoBadge: infoBadge,
          focusNode: focusNode,
          autofocus: autofocus,
        );

  final String? link;
  final VoidCallback? action;

  @override
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    bool? autofocus,
  }) {
    if (link != null) {
      return Link(
        uri: Uri.parse(link!),
        builder: (context, followLink) => super.build(
          context,
          selected,
          followLink,
          displayMode: displayMode,
          showTextOnTop: showTextOnTop,
          autofocus: autofocus,
        ),
      );
    }

    return super.build(
      context,
      selected,
      action,
      displayMode: displayMode,
      showTextOnTop: showTextOnTop,
      autofocus: autofocus,
    );
  }
}
