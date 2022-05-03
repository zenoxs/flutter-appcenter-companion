import 'package:appcenter_companion/repositories/authentication_repository.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticationDialog extends StatefulWidget {
  const AuthenticationDialog({Key? key}) : super(key: key);

  @override
  State<AuthenticationDialog> createState() => _AuthenticationDialogState();
}

class _AuthenticationDialogState extends State<AuthenticationDialog> {
  final TextEditingController _tokenController = TextEditingController();
  AuthenticationAccess _accessValue = AuthenticationAccess.readOnly;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('API Token'),
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
            controller: _tokenController,
            header: 'API Token',
            placeholder: 'xaprjx4nyuu78w....',
          ),
          const SizedBox(height: 16),
          InfoLabel(
            label: 'Access',
            child: Wrap(
              spacing: 6,
              direction: Axis.vertical,
              children: AuthenticationAccess.values
                  .map(
                    (value) => RadioButton(
                      content: Text(value.name),
                      onChanged: (_) {
                        setState(() {
                          _accessValue = value;
                        });
                      },
                      checked: value == _accessValue,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          StreamBuilder(
            stream: context.read<AuthenticationRepository>().stream,
            builder: (context, AsyncSnapshot<AuthenticationState> snapshot) {
              final token = snapshot.data?.maybeWhen(
                    authenticated: (token, access) => token,
                    orElse: () => null,
                  ) ??
                  '<none>';
              final access = snapshot.data?.maybeWhen(
                    authenticated: (token, access) => access.name,
                    orElse: () => null,
                  ) ??
                  '<none>';
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoLabel(
                    label: 'Current access',
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    child: Text(
                      access,
                      style: FluentTheme.of(context).typography.caption,
                    ),
                  ),
                  InfoLabel(
                    label: 'Current token',
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    child: SelectableText(
                      token,
                      style: FluentTheme.of(context).typography.caption,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      actions: [
        FilledButton(
          child: const Text('Save'),
          onPressed: () {
            context
                .read<AuthenticationRepository>()
                .login(_tokenController.text, access: _accessValue);
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
