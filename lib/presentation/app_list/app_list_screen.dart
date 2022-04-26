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
      child: ScaffoldPage.scrollable(
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
                  onPressed: () {},
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.refresh),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        children: [],
      ),
    );
  }
}
