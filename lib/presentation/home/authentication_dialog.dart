import 'package:appcenter_companion/bloc/authentication/authentication_cubit.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticationDialog extends StatefulWidget {
  const AuthenticationDialog({Key? key}) : super(key: key);

  @override
  State<AuthenticationDialog> createState() => _AuthenticationDialogState();
}

class _AuthenticationDialogState extends State<AuthenticationDialog> {
  final TextEditingController _tokenController = TextEditingController();

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
          BlocBuilder<AuthenticationCubit, AuthenticationState>(
            builder: (context, state) {
              final token = state.maybeWhen(
                authenticated: (token) => token,
                orElse: () => '<none>',
              );
              return SelectableText(
                'Current token: $token',
              );
            },
          ),
        ],
      ),
      actions: [
        FilledButton(
          child: const Text('Save'),
          onPressed: () {
            context.read<AuthenticationCubit>().login(_tokenController.text);
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
