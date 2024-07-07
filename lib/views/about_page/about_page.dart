import 'package:flutter/material.dart';
import 'package:scouting_app/config/app/app_constants.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("About"),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "This is the official scouting for The Poros Robotics #5554",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "The app was first used during the 2024 season and was developed for around 3 years before that.",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  "App version: ${AppConstants.currentVersion}",
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "2023-2024 Development Team",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Eilon, Shai, Benyo, Tom",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
