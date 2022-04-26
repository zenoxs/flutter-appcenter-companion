import 'package:appcenter_companion/repositories/application_repository.dart';
import 'package:appcenter_companion/repositories/entities/application.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bundled_app_cubit.dart';

class AddBundledAppDialog extends StatefulWidget {
  const AddBundledAppDialog({Key? key}) : super(key: key);

  @override
  State<AddBundledAppDialog> createState() => _AddBundledAppDialogState();
}

class _AddBundledAppDialogState extends State<AddBundledAppDialog> {
  final TextEditingController _nameController = TextEditingController();
  List<Application> _linkedApps = [];

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Add bundled app'),
      constraints: const BoxConstraints(maxWidth: 500),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Please enter your API token. It can be found in the API section of your account settings.',
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
            label: 'Select linked applications:',
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 350,
              ),
              child: StreamBuilder(
                  stream: context
                      .read<ApplicationRepository>()
                      .applications
                      .map((event) => event.find()),
                  builder:
                      (context, AsyncSnapshot<List<Application>> snapshot) {
                    if (!snapshot.hasData) {
                      return Text(
                        'You need at least one application to add a bundled app.',
                        style: FluentTheme.of(context).typography.caption,
                      );
                    }
                    return TreeView(
                      items: [
                        // TODO: Display by organization tree + create bloc for application list ?
                        ...snapshot.data!.map(
                          (app) => TreeViewItem(
                            key: Key(app.id.toString()),
                            content: Text(app.name),
                            value: app,
                          ),
                        )
                      ],
                      onSelectionChanged: (item) async {
                        _linkedApps =
                            item.map((e) => e.value as Application).toList();
                      },
                      // (optional). Can be TreeViewSelectionMode.single or TreeViewSelectionMode.multiple
                      selectionMode: TreeViewSelectionMode.multiple,
                    );
                  }),
            ),
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
    );
  }
}
