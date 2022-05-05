import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'bloc/new_release_cubit.dart';

class NewReleaseDialog extends StatelessWidget {
  const NewReleaseDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewReleaseCubit, NewReleaseState>(
      builder: (context, state) {
        if (state is NewReleaseStateAvailableVersion) {
          return ContentDialog(
            title: const Text('New release available'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A new release of the app ${state.version} is available. Please update to the latest version.',
                ),
                const SizedBox(height: 10),
                InfoLabel(
                  label: 'Ignore this update',
                  isHeader: false,
                  child: Checkbox(
                    checked: state.currentReleaseIgnored,
                    onChanged: (value) => context
                        .read<NewReleaseCubit>()
                        .ignoreCurrentRelease(ignored: value ?? false),
                  ),
                ),
              ],
            ),
            actions: [
              FilledButton(
                child: const Text('Update'),
                onPressed: () {
                  launchUrlString(state.downloadUrl);
                  Navigator.of(context).pop();
                },
              ),
              Button(
                child: const Text('Ignore'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
