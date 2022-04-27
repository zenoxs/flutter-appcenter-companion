import 'package:appcenter_companion/presentation/app_list/add_bundled_app/add_linked_app_dialog.dart';
import 'package:appcenter_companion/repositories/application_repository.dart';
import 'package:appcenter_companion/repositories/branch_repository.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bundled_app_cubit.dart';
import 'bloc/add_bundled_app_cubit.dart';

class AddBundledAppDialog extends StatefulWidget {
  const AddBundledAppDialog({Key? key}) : super(key: key);

  @override
  State<AddBundledAppDialog> createState() => _AddBundledAppDialogState();
}

class _AddBundledAppDialogState extends State<AddBundledAppDialog> {
  final TextEditingController _nameController = TextEditingController();
  late final AddBundledAppCubit _addBundledAppCubit = AddBundledAppCubit(
    context.read<ApplicationRepository>(),
    context.read<BranchRepository>(),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _addBundledAppCubit,
      child: ContentDialog(
        title: const Text('Add bundled app'),
        constraints: const BoxConstraints(maxWidth: 500),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'TBA',
            ),
            const SizedBox(height: 16),
            TextBox(
              autofocus: true,
              controller: _nameController,
              header: 'Name',
              placeholder: 'Ex: Gmail',
            ),
            const SizedBox(height: 16),
            InfoLabel(
              label: 'Linked applications',
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 100,
                  maxHeight: 200,
                ),
                child: BlocBuilder<AddBundledAppCubit, AddBundledAppState>(
                  builder: (context, state) {
                    if (state.linkedBranches.isEmpty) {
                      return Text(
                        'You need at least one linked application to add a bundled app.',
                        style: FluentTheme
                            .of(context)
                            .typography
                            .caption,
                      );
                    }
                    return TreeView(
                      items: [
                        ...state.linkedBranches.map(
                              (branch) =>
                              TreeViewItem(
                                key: Key(branch.id.toString()),
                                content: Text(
                                    '${branch.application.target!.name}/${branch
                                        .name}'),
                                value: branch,
                              ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              child: const Text('Add linked application'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      BlocProvider.value(
                        value: _addBundledAppCubit,
                        child: const AddLinkedAppDialog(),
                      ),
                );
              },
            )
          ],
        ),
        actions: [
          FilledButton(
            child: const Text('Add'),
            onPressed: () {
              context.read<BundledAppCubit>().addBundledApp(
                _nameController.text,
                _addBundledAppCubit.state.linkedBranches,
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
