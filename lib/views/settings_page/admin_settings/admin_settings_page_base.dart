import 'package:flutter/material.dart';
import 'package:scouting_app/db/auth/authentication.dart';
import 'package:scouting_app/views/settings_page/settings_page.dart';

abstract class AdminSettingsPageBase extends StatefulWidget {
  const AdminSettingsPageBase({super.key});

  @override
  AdminSettingsPageBaseState createState();
}

abstract class AdminSettingsPageBaseState<T extends AdminSettingsPageBase>
    extends State<T> {
  @override
  void initState() {
    super.initState();
    AuthManager.allowedUsersNotifier.addListener(_handleUserPermissionChange);
  }

  @override
  void dispose() {
    AuthManager.allowedUsersNotifier
        .removeListener(_handleUserPermissionChange);
    super.dispose();
  }

  void _handleUserPermissionChange() {
    setState(() {});
  }

  @protected
  void checkUserPermission() {
    if (!AuthManager.isUserAllowed()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    checkUserPermission();
    return buildContent(context);
  }

  Widget buildContent(BuildContext context);
}
