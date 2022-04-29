import 'dart:math';

import 'package:appcenter_companion/presentation/theme.dart';
import 'package:appcenter_companion/repositories/repositories.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:simple_animations/simple_animations.dart';

class BuildStatusIndicator extends StatelessWidget {
  final BuildStatus status;
  final BuildResult result;
  final double size;

  const BuildStatusIndicator({
    Key? key,
    this.size = 24,
    BuildStatus? status,
    BuildResult? result,
  })  : status = status ?? BuildStatus.unknown,
        result = result ?? BuildResult.unknown,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon = FluentIcons.unknown_solid;
    Color color = FluentTheme.of(context).disabledColor;

    if (status == BuildStatus.completed) {
      if (result == BuildResult.canceled) {
        icon = FluentIcons.blocked2_solid;
      } else if (result == BuildResult.failed) {
        icon = FluentIcons.status_error_full;
        color = FluentTheme.of(context).dangerColor;
      } else if (result == BuildResult.succeeded) {
        icon = FluentIcons.completed_solid;
        color = FluentTheme.of(context).positiveColor;
      }
    } else if (status == BuildStatus.inProgress) {
      icon = FluentIcons.progress_ring_dots;
      color = FluentTheme.of(context).accentColor;
    } else if (status == BuildStatus.notStarted) {
      icon = FluentIcons.away_status;
      color = FluentTheme.of(context).accentColor;
    } else if (status == BuildStatus.cancelling) {
      icon = FluentIcons.blocked2_solid;
    }

    final iconWidget = Icon(
      icon,
      color: color,
      size: size,
    );

    if (status == BuildStatus.inProgress) {
      return LoopAnimation(
        builder: (context, child, double value) {
          return Transform.rotate(
            angle: pi * value,
            child: iconWidget,
          );
        },
        duration: const Duration(milliseconds: 1500),
        tween: Tween<double>(begin: 0, end: 2),
      );
    }
    return iconWidget;
  }
}
