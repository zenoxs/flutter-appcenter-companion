import 'package:appcenter_companion/presentation/app_list/add_bundled_app/bloc/add_linked_app_cubit.dart';
import 'package:appcenter_companion/repositories/application_repository.dart';
import 'package:appcenter_companion/repositories/branch_repository.dart';
import 'package:appcenter_companion/repositories/entities/application.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bundled_app_cubit.dart';

class AddLinkedAppDialog extends StatefulWidget {
  const AddLinkedAppDialog({Key? key}) : super(key: key);

  @override
  State<AddLinkedAppDialog> createState() => _AddLinkedAppDialogState();
}

class _AddLinkedAppDialogState extends State<AddLinkedAppDialog> {
  final TextEditingController _nameController = TextEditingController();
  List<Application> _linkedApps = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddLinkedAppCubit(
        context.read<ApplicationRepository>(),
        context.read<BranchRepository>(),
      ),
      child: ContentDialog(
        title: const Text('Add linked app'),
        constraints: const BoxConstraints(maxWidth: 500),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InfoLabel(
              label: 'Select an application:',
              child: BlocBuilder<AddLinkedAppCubit, AddLinkedAppState>(
                builder: (context, state) {
                  if (state.applications.isEmpty) {
                    return const Text(
                      'You need at least one application to add a linked app.',
                    );
                  }
                  return DropDownButton(
                    title: Text(state.selectedApplication?.name ?? ''),
                    items: state.applications
                        .map(
                          (app) => DropDownButtonItem(
                            title: Text(app.name),
                            onTap: () => context
                                .read<AddLinkedAppCubit>()
                                .selectApplication(app),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
            BlocBuilder<AddLinkedAppCubit, AddLinkedAppState>(
              builder: (context, state) {
                if (state.selectedApplication == null) {
                  return const SizedBox();
                }
                return InfoLabel(
                  label: 'Select a branch:',
                  child: BlocBuilder<AddLinkedAppCubit, AddLinkedAppState>(
                    builder: (context, state) {
                      if (state.branches.isEmpty) {
                        return const Text(
                          'You need at least one activated branch.',
                        );
                      }
                      return DropDownButton(
                        title: Text(state.selectedBranch?.name ?? ''),
                        items: state.branches
                            .map(
                              (branch) => DropDownButtonItem(
                                title: Text(branch.name),
                                onTap: () => context
                                    .read<AddLinkedAppCubit>()
                                    .selectBranch(branch),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          FilledButton(
            child: const Text('Add'),
            onPressed: () {
              context.read<BundledAppCubit>().addBundledApp(
                    _nameController.text,
                    _linkedApps,
                  );
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
