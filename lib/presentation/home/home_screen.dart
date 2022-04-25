import 'package:appcenter_companion/presentation/home/authentication_dialog.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/link.dart';
import 'package:window_manager/window_manager.dart';

import '../theme.dart';

const _appTitle = 'Appcenter Companion';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  final viewKey = GlobalKey();
  final settingsController = ScrollController();

  bool value = false;

  int index = 0;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        title: () {
          if (kIsWeb) return const Text(_appTitle);
          return const DragToMoveArea(
            child: Align(
              alignment: AlignmentDirectional.center,
              child: Text(_appTitle),
            ),
          );
        }(),
        actions: kIsWeb
            ? null
            : DragToMoveArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [Spacer(), WindowButtons()],
          ),
        ),
      ),
      pane: NavigationPane(
        selected: index,
        onChanged: (i) => setState(() => index = i),
        size: const NavigationPaneSize(
          openMinWidth: 250,
          openMaxWidth: 320,
        ),
        header: Container(
          height: kOneLineTileHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: FlutterLogo(
            style: appTheme.displayMode == PaneDisplayMode.top
                ? FlutterLogoStyle.markOnly
                : FlutterLogoStyle.horizontal,
            size: appTheme.displayMode == PaneDisplayMode.top ? 24 : 100.0,
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
            icon: const Icon(FluentIcons.checkbox_composite),
            title: const Text('Inputs'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.text_field),
            title: const Text('Forms'),
          ),
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.color),
            title: const Text('Colors'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.icon_sets_flag),
            title: const Text('Icons'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.plain_text),
            title: const Text('Typography'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.cell_phone),
            title: const Text('Mobile'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.toolbox),
            title: const Text('Command bars'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.pop_expand),
            title: const Text('Flyouts'),
          ),
          PaneItem(
            icon: Icon(
              appTheme.displayMode == PaneDisplayMode.top
                  ? FluentIcons.more
                  : FluentIcons.more_vertical,
            ),
            title: const Text('Others'),
            infoBadge: const InfoBadge(
              source: Text('9'),
            ),
          ),
        ],
        autoSuggestBox: AutoSuggestBox(
          controller: TextEditingController(),
          items: const ['Item 1', 'Item 2', 'Item 3', 'Item 4'],
        ),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
        footerItems: [
          PaneItemSeparator(),
          _LinkPaneItemAction(
            icon: const Icon(FluentIcons.user_sync),
            title: const Text('Login'),
            action: () => showDialog(
              context: context,
              builder: (context) => AuthenticationDialog(),
            ),
          ),
        ],
      ),
      content: NavigationBody(
        index: index,
        children: [
          Container(),
          Container(),
          Container(),
          Container(),
          Container(),
          Container(),
          Container(),
          Container(),
          Container(),
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

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
