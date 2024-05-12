import 'package:flutter/material.dart';

import 'package:dideban/models/group.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
  });

  final Group group;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: ClipOval(
            child: Text(group.name)
          ),
          title: Text(group.groupid),
          subtitle: Text(group.id),
        ),
      ),
    );
  }
}
