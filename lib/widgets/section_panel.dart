import 'package:flutter/material.dart';

import '../shared/responsive.dart';

class SectionPanel extends StatelessWidget {
  const SectionPanel(
      {required this.title,
      required this.child,
      this.actions = const [],
      super.key});

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final padding = MeshResponsive.pagePadding(context);
    final gap = MeshResponsive.gap(context);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < MeshResponsive.mobileMax;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: mobile
                          ? constraints.maxWidth
                          : constraints.maxWidth * 0.35,
                    ),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ...actions,
                ],
              );
            },
          ),
          SizedBox(height: gap),
          Expanded(child: child),
        ],
      ),
    );
  }
}
