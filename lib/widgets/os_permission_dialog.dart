import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../l10n/l10n_extension.dart';

class OsPermissionDialog extends StatelessWidget {
  final String title;
  final String content;

  const OsPermissionDialog({
    super.key,
    required this.title,
    required this.content,
  });

  static Future<void> show(BuildContext context, {required String title, required String content}) {
    return showDialog(
      context: context,
      builder: (_) => OsPermissionDialog(title: title, content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            PermissionService.openSettings();
          },
          child: Text(context.l10n.openSettings),
        ),
      ],
    );
  }
}
