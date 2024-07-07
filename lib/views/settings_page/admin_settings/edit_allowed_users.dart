import 'package:flutter/material.dart';
import 'package:scouting_app/db/auth/authentication.dart';
import 'package:scouting_app/widgets/buttons/accept_button.dart';
import 'package:scouting_app/widgets/buttons/deny_button.dart';
import 'package:scouting_app/views/settings_page/admin_settings/admin_settings_page_base.dart';

class EditAllowedUsers extends AdminSettingsPageBase {
  const EditAllowedUsers({super.key});

  @override
  AdminSettingsPageBaseState<EditAllowedUsers> createState() =>
      _EditAllowedUsersState();
}

class _EditAllowedUsersState
    extends AdminSettingsPageBaseState<EditAllowedUsers> {
  TextEditingController searchController = TextEditingController();
  List<String> filteredUsers = [];

  void _showRemovedAllowedUserDialog(BuildContext context, int userIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text("Remove user permissions"),
          ),
          content: Text(
              "Are you sure you want to remove permission from user ${AuthManager.allowedUsersEmails[userIndex]}?"),
          actions: [
            Center(
              child: DenyButton(
                text: "Yes, Remove",
                onPressed: () {
                  AuthManager.removeUserPermissions(
                      AuthManager.allowedUsersEmails[userIndex]);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Center(
              child: AcceptButton(
                text: "Cancel",
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        );
      },
    );
  }

  void _showAddAllowedUserDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Center(
                child: Text("Add user permissions"),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter user email',
                    ),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: AcceptButton(
                    text: "Add",
                    onPressed: () {
                      String email = emailController.text.trim();
                      if (!emailRegex.hasMatch(email)) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Invalid email address"),
                              actions: [
                                AcceptButton(
                                  text: "Close",
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          },
                        );
                        return;
                      }

                      AuthManager.addUserPermissions(email);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Center(
                  child: DenyButton(
                    text: "Cancel",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Allowed Users"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  filteredUsers = AuthManager.allowedUsersEmails
                      .where((email) =>
                          email.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by user email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.isNotEmpty
                  ? filteredUsers.length
                  : AuthManager.allowedUsersEmails.length,
              itemBuilder: (context, index) {
                String email = filteredUsers.isNotEmpty
                    ? filteredUsers[index]
                    : AuthManager.allowedUsersEmails[index];
                return GestureDetector(
                  onTap: () => _showRemovedAllowedUserDialog(context, index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            email,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () => _showAddAllowedUserDialog(context),
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "Add",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
