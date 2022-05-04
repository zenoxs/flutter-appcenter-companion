import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/presentation/app_list/app_item/bloc/app_item_bloc.dart';
import 'package:appcenter_companion/presentation/widgets/build_status_indicator.dart';
import 'package:appcenter_companion/repositories/repositories.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppItem extends StatelessWidget {
  final int bundledApplicationId;

  const AppItem({
    Key? key,
    required this.bundledApplicationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppItemBloc(
        bundledApplicationId: bundledApplicationId,
        store: context.read<Store>(),
      ),
      child: BlocBuilder<AppItemBloc, AppItemState>(
        builder: (context, state) {
          final bundledApplication = state.bundledApplication;
          return Expander(
            initiallyExpanded: true,
            trailing: Wrap(
              runSpacing: 10,
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...bundledApplication.linkedApplications.map(
                  (linkedApp) => Text(
                    linkedApp.branch.target!.application.target!.name,
                    style: FluentTheme.of(context).typography.body!.copyWith(
                          color: FluentTheme.of(context).accentColor.normal,
                        ),
                  ),
                ),
                StreamBuilder<AuthenticationState>(
                  stream: context.read<AuthenticationRepository>().stream,
                  builder:
                      (context, AsyncSnapshot<AuthenticationState> snapshot) {
                    if (state.status == BuildStatus.inProgress) {
                      return Tooltip(
                        message: 'Cancel builds',
                        child: IconButton(
                          icon: const Icon(
                            FluentIcons.processing_cancel,
                            size: 16,
                          ),
                          onPressed: snapshot.data?.isFullAccess == true
                              ? () => context
                                  .read<AppItemBloc>()
                                  .add(AppItemEvent.cancelAllBuild())
                              : null,
                        ),
                      );
                    }
                    return Tooltip(
                      message: 'Build all applications',
                      child: IconButton(
                        icon: const Icon(
                          FluentIcons.build,
                          size: 16,
                        ),
                        onPressed: snapshot.data?.isFullAccess == true
                            ? () => context
                                .read<AppItemBloc>()
                                .add(AppItemEvent.buildAll())
                            : null,
                      ),
                    );
                  },
                )
              ],
            ),
            header: Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: FluentTheme.of(context).accentColor.lightest,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: bundledApplication.iconUrl != null
                      ? Image.network(
                          bundledApplication.iconUrl!,
                        )
                      : null,
                ),
                Text(
                  bundledApplication.name,
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                BuildStatusIndicator(
                  status: state.status,
                  result: state.result,
                ),
              ],
            ),
            content: Wrap(
              spacing: 10,
              children: [
                ...bundledApplication.linkedApplications.map(
                  (linkedApp) {
                    final branch = linkedApp.branch.target;
                    final lastBuild = branch?.lastBuild.target;
                    final application = branch?.application.target;
                    return ListTile(
                      leading: BuildStatusIndicator(
                        status: lastBuild?.status,
                        result: lastBuild?.result,
                      ),
                      title: Wrap(
                        children: [
                          Text(
                            application?.displayName ?? '-',
                          ),
                        ],
                      ),
                      trailing: StreamBuilder<AuthenticationState>(
                        stream: context.read<AuthenticationRepository>().stream,
                        builder: (
                          context,
                          AsyncSnapshot<AuthenticationState> snapshot,
                        ) {
                          if (lastBuild?.status == BuildStatus.inProgress) {
                            return Tooltip(
                              message: 'Cancel ${application?.displayName}',
                              child: IconButton(
                                icon: const Icon(
                                  FluentIcons.processing_cancel,
                                  size: 16,
                                ),
                                onPressed: snapshot.data?.isFullAccess == true
                                    ? () => context
                                        .read<AppItemBloc>()
                                        .add(AppItemEvent.cancelAllBuild())
                                    : null,
                              ),
                            );
                          }
                          return Tooltip(
                            message: 'Build ${application?.displayName}',
                            child: IconButton(
                              icon: const Icon(
                                FluentIcons.build,
                                size: 16,
                              ),
                              onPressed: snapshot.data?.isFullAccess == true
                                  ? () => context
                                      .read<AppItemBloc>()
                                      .add(AppItemEvent.buildAll())
                                  : null,
                            ),
                          );
                        },
                      ),
                      subtitle: Text(branch?.name ?? '-'),
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
