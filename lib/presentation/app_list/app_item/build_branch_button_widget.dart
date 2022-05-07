import 'package:appcenter_companion/presentation/theme.dart';
import 'package:appcenter_companion/repositories/repositories.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class BuildBranchButtonWidget extends StatelessWidget {
  const BuildBranchButtonWidget({
    Key? key,
    BuildStatus? status,
    required this.onBuild,
    required this.onCancelBuild,
    this.tooltipBuild,
    this.tooltipCancelBuild,
  })  : status = status ?? BuildStatus.unknown,
        super(key: key);

  final String? tooltipBuild;
  final String? tooltipCancelBuild;
  final BuildStatus status;
  final VoidCallback onBuild;
  final VoidCallback onCancelBuild;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthenticationState>(
      stream: context.read<AuthenticationRepository>().stream,
      builder: (context, AsyncSnapshot<AuthenticationState> snapshot) {
        if (status == BuildStatus.inProgress ||
            status == BuildStatus.notStarted) {
          return Tooltip(
            message: tooltipCancelBuild,
            child: IconButton(
              icon: Icon(
                FluentIcons.circle_stop,
                size: 16,
                color: FluentTheme.of(context).dangerColor,
              ),
              onPressed:
                  snapshot.data?.isFullAccess == true ? onCancelBuild : null,
            ),
          );
        }
        return Tooltip(
          message: tooltipBuild,
          child: IconButton(
            icon: Icon(
              FluentIcons.play,
              size: 16,
              color: FluentTheme.of(context).positiveColor,
            ),
            onPressed: snapshot.data?.isFullAccess == true ? onBuild : null,
          ),
        );
      },
    );
  }
}
