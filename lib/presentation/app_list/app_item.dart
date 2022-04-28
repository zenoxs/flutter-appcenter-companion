import 'package:appcenter_companion/presentation/widgets/build_status_indicator.dart';
import 'package:appcenter_companion/repositories/repositories.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AppItem extends StatelessWidget {
  final BundledApplication bundledApplication;

  const AppItem({Key? key, required this.bundledApplication}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    style: FluentTheme.of(context).typography.body!.copyWith(
                          color: FluentTheme.of(context).accentColor.normal,
                        ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
      header: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    branch?.application.target?.name ?? '-',
                  ),
                ],
              ),
              subtitle: Text(branch?.name ?? '-'),
            );
          },
        ).toList(),
      ),
    );
  }
}
