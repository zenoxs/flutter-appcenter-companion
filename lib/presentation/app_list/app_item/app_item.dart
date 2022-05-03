import 'package:appcenter_companion/objectbox.g.dart';
import 'package:appcenter_companion/presentation/app_list/app_item/bloc/app_item_bloc.dart';
import 'package:appcenter_companion/presentation/widgets/build_status_indicator.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppItem extends StatelessWidget {
  final int bundledApplicationId;

  const AppItem({Key? key, required this.bundledApplicationId})
      : super(key: key);

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
              children: bundledApplication.linkedApplications
                  .map(
                    (linkedApp) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          linkedApp.branch.target!.application.target!.name,
                          style: FluentTheme.of(context)
                              .typography
                              .body!
                              .copyWith(
                                color:
                                    FluentTheme.of(context).accentColor.normal,
                              ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
            header: Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CircleAvatar(
                  radius: 18,
                  foregroundImage: bundledApplication.iconUrl != null
                      ? NetworkImage(bundledApplication.iconUrl!)
                      : null,
                ),
                Text(
                  bundledApplication.name,
                  style: FluentTheme.of(context).typography.subtitle,
                ),
              ],
            ),
            content: Wrap(
              spacing: 10,
              children: bundledApplication.linkedApplications.map(
                (linkedApp) {
                  final branch = linkedApp.branch.target;
                  return ListTile(
                    leading: BuildStatusIndicator(
                      status: branch?.lastBuild.target?.status,
                      result: branch?.lastBuild.target?.result,
                    ),
                    title: Wrap(
                      children: [
                        Text(
                          branch?.application.target?.displayName ?? '-',
                        ),
                      ],
                    ),
                    subtitle: Text(branch?.name ?? '-'),
                  );
                },
              ).toList(),
            ),
          );
        },
      ),
    );
  }
}
