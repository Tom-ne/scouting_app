import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/widgets/buttons/accept_button.dart';
import 'package:scouting_app/theme/theme_provider.dart';
import 'package:scouting_app/db/auth/authentication.dart';

class LoginScreen extends StatelessWidget {
  static final TextEditingController emailController = TextEditingController();
  static final TextEditingController passwordController =
      TextEditingController();

  const LoginScreen({super.key});

  Future<void> login(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;
    final success = await AuthManager.login(email, password);
    if (success) {
      emailController.text = "";
      passwordController.text = "";
      // ignore: use_build_context_synchronously
      Navigator.restorablePushReplacementNamed(context, "/home");
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Invalid email or password. Please try again.'),
          actions: [
            AcceptButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: "OK",
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.primaryColor,
        title: const Text(
          'Poro-Scouting',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: themeProvider.toggleMode,
            icon: themeProvider.icon,
            color: Colors.white,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Scouting APP",
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Login",
              style: TextStyle(fontSize: 44.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 44.0,
            ),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "User Email",
                prefixIcon: Icon(Icons.mail),
              ),
            ),
            const SizedBox(
              height: 26.0,
            ),
            TextField(
              obscureText: true,
              controller: passwordController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "User Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(
              height: 88.0,
            ),
            SizedBox(
              width: double.infinity,
              child: RawMaterialButton(
                fillColor: const Color(0xFF0069FE),
                elevation: 0.0,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                onPressed: () => login(context),
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
