import 'package:appcenter_companion/repositories/github_repository.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/new_release_cubit.dart';
import 'new_release_dialog.dart';

class NewReleaseGuard extends StatefulWidget {
  const NewReleaseGuard({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<NewReleaseGuard> createState() => _NewReleaseGuardState();
}

class _NewReleaseGuardState extends State<NewReleaseGuard> {
  late final cubit = NewReleaseCubit(context.read<GitHubRepository>());

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocListener<NewReleaseCubit, NewReleaseState>(
        listenWhen: (previous, current) =>
            previous is NewReleaseStateInitial &&
            current is NewReleaseStateAvailableVersion,
        listener: (context, state) {
          if (state is NewReleaseStateAvailableVersion) {
            showDialog(
              context: context,
              builder: (context) => BlocProvider.value(
                value: cubit,
                child: const NewReleaseDialog(),
              ),
            );
          }
        },
        child: widget.child,
      ),
    );
  }
}
