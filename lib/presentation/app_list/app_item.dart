import 'package:appcenter_companion/repositories/repositories.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

class AppItem extends StatelessWidget {
  final BundledApplication bundledApplication;

  const AppItem({Key? key, required this.bundledApplication}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expander(
      // isButton: true,
      // onPressed: () {
      //   Navigator.of(context).push(FluentPageRoute(builder: (_) {
      //     return AppDetailScreen();
      //   }));
      // },
      headerHeight: 70,
      header: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bundledApplication.name,
            style: FluentTheme.of(context).typography.subtitle,
          ),
          const SizedBox(height: 5),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            children: bundledApplication.linkedApplications
                .map(
                  (linkedApp) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        linkedApp.branch.target!.application.target!.name,
                        style: FluentTheme.of(context)
                            .typography
                            .body!
                            .copyWith(
                              color: FluentTheme.of(context).accentColor.normal,
                            ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),

      content: const SizedBox(
        child: Text('hello'),
      ),
    );
  }
}
