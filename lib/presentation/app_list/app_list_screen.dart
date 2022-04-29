import 'package:appcenter_companion/presentation/app_list/add_bundled_app/add_bundled_app_dialog.dart';
import 'package:appcenter_companion/presentation/app_list/app_item.dart';
import 'package:appcenter_companion/repositories/authentication_repository.dart';
import 'package:appcenter_companion/repositories/bundled_application_repository.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bundled_app_cubit.dart';

class AppListScreen extends StatelessWidget {
  const AppListScreen({
    Key? key,
    required this.onLogin,
  }) : super(key: key);

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BundledAppCubit(
        context.read<BundledApplicationRepository>(),
        context.read<AuthenticationRepository>(),
      ),
      child: BlocBuilder<BundledAppCubit, BundledAppState>(
        builder: (context, state) {
          return ScaffoldPage(
            header: PageHeader(
              title: const Text('Bundled Applications'),
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
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.loading) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0)
                        .copyWith(bottom: 10),
                    child: const ProgressBar(),
                  ),
                ] else ...[
                  const SizedBox(
                    height: 14.5,
                  ),
                ],
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final bundledApp = state.bundledApplications[index];
                      return AppItem(bundledApplication: bundledApp);
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemCount: state.bundledApplications.length,
                  ),
                ),
              ],
            ),
            bottomBar: StreamBuilder<AuthenticationState>(
              stream: context.read<AuthenticationRepository>().stream,
              builder: (context, snapshot) {
                if (snapshot.data is AuthenticationStateAuthenticated) {
                  return const SizedBox();
                }
                return InfoBar(
                  severity: InfoBarSeverity.error,
                  title: const Text('Log first:'),
                  content: Text.rich(
                    TextSpan(
                      text:
                          'Set up your appcenter account to add bundled applications.',
                      children: [
                        const TextSpan(
                          text: ' ',
                        ),
                        TextSpan(
                          text: 'Log now',
                          style: TextStyle(
                            color: FluentTheme.of(context).accentColor,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = onLogin,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
