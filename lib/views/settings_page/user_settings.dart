import 'package:flutter/material.dart';
import 'package:scouting_app/config/app/app_constants.dart';
import 'package:scouting_app/db/auth/authentication.dart';
import 'package:scouting_app/widgets/buttons/accept_button.dart';
import 'package:scouting_app/widgets/buttons/deny_button.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  late TextEditingController _usernameController;
  late String _userName;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: AuthManager.userName);
    updateUserName();
    AuthManager.currentUserNotifier.addListener(updateUserName);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    AuthManager.currentUserNotifier.removeListener(updateUserName);
    super.dispose();
  }

  void updateUserName() {
    setState(() {
      _userName = AuthManager.userName ?? 'NO USERNAME FOUND';
    });
  }

  String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return "Username cannot be empty.";
    } else if (username.length > AppConstants.maxUsernameLength) {
      return "Username length cannot exceed ${AppConstants.maxUsernameLength} characters.";
    }
    return null;
  }

  void _changeUsername() {
    String newUsername = _usernameController.text;
    String? invalidUsername = validateUsername(newUsername);

    if (invalidUsername != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Invalid username"),
              content: Text(invalidUsername),
              actions: [
                AcceptButton(
                  onPressed: () => Navigator.pop(context),
                  text: "Ok",
                )
              ],
            );
          });
    } else {
      // Update the current user's display name
      AuthManager.userName = newUsername;
      // Close the dialog
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            const Text(
              "Currently connected user: ",
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            AcceptButton(
              onPressed: () {
                _usernameController.text = _userName;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Change username"),
                      content: TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'New Username',
                        ),
                      ),
                      actions: [
                        Row(
                          children: [
                            DenyButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              text: "Cancel",
                            ),
                            AcceptButton(
                              onPressed: _changeUsername,
                              text: "Save",
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
              text: "Change username",
            ),
          ],
        ),
      ),
    );
  }
}
