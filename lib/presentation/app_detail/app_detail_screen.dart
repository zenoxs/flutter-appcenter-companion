import 'package:fluent_ui/fluent_ui.dart';

class AppDetailScreen extends StatelessWidget {
  const AppDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        leading: IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('App Detail'),
      ),
      content: const Center(
        child: Text('test'),
      ),
    );
  }
}
