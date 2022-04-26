import 'package:appcenter_companion/presentation/app_list/add_bundled_app_dialog.dart';
import 'package:appcenter_companion/presentation/widgets/fluent_card.dart';
import 'package:appcenter_companion/repositories/bundled_application_repository.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bundled_app_cubit.dart';

class AppListScreen extends StatelessWidget {
  const AppListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BundledAppCubit(context.read<BundledApplicationRepository>()),
      child: BlocBuilder<BundledAppCubit, BundledAppState>(
        builder: (context, state) {
          return ScaffoldPage(
              header: PageHeader(
                title: const Text('Bundle Applications'),
                commandBar: SizedBox(
                  width: 300,
                  child: CommandBar(
                    mainAxisAlignment: MainAxisAlignment.end,
                    primaryItems: [
                      CommandBarButton(
                        icon: const Icon(FluentIcons.add),
                        label: const Text('Add'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => BlocProvider.value(
                              value: context.read<BundledAppCubit>(),
                              child: const AddBundledAppDialog(),
                            ),
                          );
                        },
                      ),
                      CommandBarButton(
                        icon: const Icon(FluentIcons.refresh),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              content: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final bundledApp = state.bundledApplications[index];
                  // TODO: create a widget for this
                  return FluentCard(
                    isButton: true,
                    onPressed: () {},
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bundledApp.name,
                          style: FluentTheme.of(context).typography.subtitle,
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          runSpacing: 10,
                          spacing: 10,
                          children: bundledApp.applications
                              .map(
                                (linkedApp) => Text(linkedApp.name,
                                    style: FluentTheme.of(context)
                                        .typography
                                        .body!
                                        .copyWith(
                                            color: FluentTheme.of(context)
                                                .accentColor
                                                .normal)),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: state.bundledApplications.length,
              )
              // children: state.bundledApplications
              //     .map(
              //       (app) => Container(
              //         padding: const EdgeInsets.all(8),
              //         child: Card(
              //           padding: EdgeInsets.all(10),
              //          child: Column(
              //            mainAxisSize: MainAxisSize.min,
              //            children: [
              //              Text(app.name),
              //              Wrap(
              //                children: app.applications
              //                    .map((linkedApp) => Chip(text: Text(linkedApp.name)))
              //                    .toList(),
              //              ),
              //            ],
              //          ),
              //         ),
              //       ),
              //     )
              //     .toList(),
              );
        },
      ),
    );
  }
}
