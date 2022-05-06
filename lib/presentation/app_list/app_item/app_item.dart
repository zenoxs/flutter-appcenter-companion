import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/presentation/app_list/app_item/bloc/app_item_bloc.dart';
import 'package:appcenter_companion/presentation/widgets/build_status_indicator_widget.dart';
import 'package:appcenter_companion/repositories/repositories.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppItem extends StatefulWidget {
  final int bundledApplicationId;

  const AppItem({
    Key? key,
    required this.bundledApplicationId,
  }) : super(key: key);

  @override
  State<AppItem> createState() => _AppItemState();
}

class _AppItemState extends State<AppItem> {
  final _moreController = FlyoutController();
  late final _bloc = AppItemBloc(
    bundledApplicationId: widget.bundledApplicationId,
    bundledApplicationRepository: context.read<BundledApplicationRepository>(),
    branchRepository: context.read<BranchRepository>(),
    store: context.read<Store>(),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
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
                                  .add(AppItemEvent.cancelAllBuildRequested())
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
                                .add(AppItemEvent.buildAllRequested())
                            : null,
                      ),
                    );
                  },
                ),
                Flyout(
                  controller: _moreController,
                  content: (context) {
                    return MenuFlyout(
                      items: [
                        MenuFlyoutItem(
                          leading: const Icon(FluentIcons.delete),
                          text: const Text('Remove'),
                          onPressed: () {
                            _moreController.close();
                            _onRemove(state.bundledApplication);
                          },
                        ),
                        MenuFlyoutItem(
                          leading: const Icon(FluentIcons.edit),
                          text: const Text('Edit'),
                          onPressed: () {
                            _moreController.close();
                          },
                        ),
                      ],
                    );
                  },
                  child: IconButton(
                    icon: const Icon(FluentIcons.more),
                    onPressed: () {
                      _moreController.open();
                    },
                  ),
                ),
                const Divider(
                  direction: Axis.vertical,
                  size: 27,
                ),
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
                                    ? () => context.read<AppItemBloc>().add(
                                          AppItemEvent
                                              .cancelAllBuildRequested(),
                                        )
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
                                  ? () =>
                                  context.read<AppItemBloc>().add(
                                      AppItemEvent.buildRequested(linkedApp))
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

  void _onRemove(BundledApplication bundledApplication) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(
          'Remove ${bundledApplication.name} permanently?',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        content: Text(
          'Are you sure you want to remove ${bundledApplication.name}?',
        ),
        actions: [
          Button(
            child: const Text('Remove'),
            onPressed: () {
              _bloc.add(AppItemEvent.removeRequested());
              Navigator.pop(context);
            },
          ),
          Button(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
