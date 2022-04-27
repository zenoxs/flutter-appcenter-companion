import 'package:appcenter_companion/presentation/app_list/add_bundled_app/bloc/add_linked_app_cubit.dart';
import 'package:appcenter_companion/repositories/application_repository.dart';
import 'package:appcenter_companion/repositories/branch_repository.dart';
import 'package:appcenter_companion/repositories/entities/application.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repositories/entities/branch.dart';
import 'bloc/add_bundled_app_cubit.dart';

class AddLinkedAppDialog extends StatelessWidget {
  const AddLinkedAppDialog({Key? key}) : super(key: key);

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
        content: Wrap(
          children: [
            InfoLabel(
              label: 'Select an app',
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 100,
                  maxHeight: 150,
                  maxWidth: 230,
                ),
                child: BlocBuilder<AddLinkedAppCubit, AddLinkedAppState>(
                  builder: (context, state) {
                    if (state.applications.isEmpty) {
                      return Text(
                        'You need at least one application to add a bundled app.',
                        style: FluentTheme.of(context).typography.caption,
                      );
                    }
                    return TreeView(
                      items: [
                        ...state.applications.map(
                          (app) => TreeViewItem(
                            key: Key(app.id.toString()),
                            content: Text(app.name),
                            value: app,
                            selected: state.selectedApplication == app,
                          ),
                        )
                      ],
                      onSelectionChanged: (item) async {
                        context
                            .read<AddLinkedAppCubit>()
                            .selectApplication(item.first.value as Application);
                      },
                      // (optional). Can be TreeViewSelectionMode.single or TreeViewSelectionMode.multiple
                      selectionMode: TreeViewSelectionMode.single,
                    );
                  },
                ),
              ),
            ),
            InfoLabel(
              label: 'Select a branch',
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 100,
                  maxHeight: 150,
                  maxWidth: 230,
                ),
                child: BlocBuilder<AddLinkedAppCubit, AddLinkedAppState>(
                  builder: (context, state) {
                    if (state.loadingBranches) {
                      return const Center(
                        child: ProgressBar(),
                      );
                    }

                    if (state.selectedApplication == null) {
                      return Text(
                        'Select an application first.',
                        style: FluentTheme.of(context).typography.caption,
                      );
                    }

                    if (state.branches.isEmpty) {
                      return Text(
                        'You need at least one configured branch to add a linked app.',
                        style: FluentTheme.of(context).typography.caption,
                      );
                    }
                    return TreeView(
                      items: [
                        ...state.branches.map(
                          (branch) => TreeViewItem(
                            key: Key(branch.id.toString()),
                            content: Text(branch.name),
                            value: branch,
                            selected: state.selectedBranch == branch,
                          ),
                        )
                      ],
                      onSelectionChanged: (item) async {
                        context
                            .read<AddLinkedAppCubit>()
                            .selectBranch(item.first.value as Branch);
                      },
                      // (optional). Can be TreeViewSelectionMode.single or TreeViewSelectionMode.multiple
                      selectionMode: TreeViewSelectionMode.single,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<AddLinkedAppCubit, AddLinkedAppState>(
            builder: (context, state) {
              return FilledButton(
                onPressed: state.selectedBranch != null
                    ? () {
                        context.read<AddBundledAppCubit>().addLinkedBranch(
                              state.selectedBranch!,
                            );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('Add'),
              );
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
