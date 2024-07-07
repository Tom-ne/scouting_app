import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scouting_app/views/home_page/home_screen.dart';
import 'package:scouting_app/views/settings_page/admin_settings/admin_settings_page_base.dart';
import 'package:scouting_app/widgets/buttons/accept_button.dart';
import 'package:scouting_app/widgets/buttons/deny_button.dart';
import 'package:scouting_app/utils/tba_manager.dart';

class TeamsImport extends AdminSettingsPageBase {
  const TeamsImport({super.key});

  @override
  TeamsImportState createState() => TeamsImportState();
}

class TeamsImportState extends AdminSettingsPageBaseState<TeamsImport> {
  List<TBA_Event> events = [];
  bool loading = false;
  final GlobalKey<FormState> customEventKey = GlobalKey<FormState>();
  final customEventKeyController = TextEditingController();
  bool isInvalidCode = false;

  @override
  void initState() {
    loadEvents();
    super.initState();
  }

  Future<void> loadEvents() async {
    loading = true;

    List<TBA_Event>? loadedEvents;
    try {
      loadedEvents = await TBA_Manager.fetchEvents();
    } catch (e) {
      if (kDebugMode) {
        print("failed to load data from TBA: $e");
      }
    }
    if (mounted) {
      setState(() {
        if (loadedEvents != null) {
          events = loadedEvents;
        }
        loading = false;
      });
    }
  }

  Future<void> _loadTeamsFromEvent(TBA_Event event) async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    try {
      final teamsIdForEvent = await TBA_Manager.fetchTeamsFromEvent(event);
      await HomeScreen.teams.clearTeams();
      await HomeScreen.teams.addAllTeams(teamsIdForEvent);
    } catch (e) {
      if (kDebugMode) {
        print("failed to load data from TBA: $e");
      }
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void showImportDialog(BuildContext context, TBA_Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text("Import teams from event"),
          ),
          content: Text(
              "Would you like to import all teams for ${event.name}? this will remove every team loaded currently!"),
          actions: [
            Center(
              child: DenyButton(
                text: "Accept",
                onPressed: () {
                  _loadTeamsFromEvent(event);
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
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    String eventsNames = events.map((event) => event.name).join(', ');
    if (kDebugMode) {
      print(eventsNames);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Import teams"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Other event"),
              content: Form(
                key: customEventKey,
                child: TextFormField(
                  controller: customEventKeyController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'You must enter a value!';
                    }
                    if (isInvalidCode) {
                      return 'You must enter a valid event code!';
                    }
                    return null;
                  },
                  onSaved: (value) async {
                    if (value != null && value.isNotEmpty) {
                      isInvalidCode = await TBA_Manager.isValidEventCode(value);
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Event code',
                    focusColor: Colors.black,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Add"),
                  onPressed: () {
                    if (!customEventKey.currentState!.validate()) return;
                    events.add(TBA_Event(
                        name: "Custom event code",
                        key: customEventKeyController.text));
                    Navigator.of(context).pop();
                    showImportDialog(context, events[events.length - 1]);
                  },
                ),
              ],
            );
          },
        ),
        child: const Icon(Icons.dashboard_customize),
      ),
      body: Visibility(
        visible: !loading,
        replacement: const Center(child: CircularProgressIndicator()),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => showImportDialog(context, events[index]),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Center(
                      child: Text(events[index].name),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
