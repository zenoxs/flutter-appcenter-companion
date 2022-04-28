import 'package:appcenter_companion/presentation/app_list/add_bundled_app/add_bundled_app_dialog.dart';
import 'package:appcenter_companion/presentation/app_list/app_item.dart';
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
                      onPressed: () {
                        context.read<BundledAppCubit>().refresh();
                      },
                    ),
                  ],
                ),
              ),
            ),
            content: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final bundledApp = state.bundledApplications[index];
                return AppItem(bundledApplication: bundledApp);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: state.bundledApplications.length,
            ),
          );
        },
      ),
    );
  }
}
