import 'package:fluent_ui/fluent_ui.dart';

class BuildListScreen extends StatelessWidget {
  const BuildListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Builds'),
        commandBar: SizedBox(
          width: 300,
          child: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.add),
                label: const Text('Add'),
                onPressed: () {},
              ),
              CommandBarButton(
                icon: const Icon(FluentIcons.refresh),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
