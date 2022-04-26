import 'package:fluent_ui/fluent_ui.dart';

class AppListScreen extends StatelessWidget {
  const AppListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: CommandBar(
                mainAxisAlignment: MainAxisAlignment.start,
                overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
                compactBreakpointWidth: 768,
                primaryItems: [
                  CommandBarButton(
                    icon: const Icon(FluentIcons.add),
                    label: const Text('Add'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            CommandBar(
              overflowBehavior: CommandBarOverflowBehavior.noWrap,
              primaryItems: [
                CommandBarButton(
                  icon: const Icon(FluentIcons.refresh),
                  onPressed: () {},
                ),
              ],
            )
          ],
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(

                /// You can add a padding to the view to avoid having the scrollbar over the UI elements
                padding: EdgeInsets.only(right: 16.0),
                itemCount: 100,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(),
                    title: Text('$index'),
                  );
                }),
          ),
        ),
      ],
    );
  }
}
