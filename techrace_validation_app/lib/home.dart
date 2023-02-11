import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techracev/gamevalidate.dart';
import 'package:techracev/login.dart';
import 'package:techracev/main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return (clueNo != 0) ? HomeLog() : Login();
  }
}

class HomeLog extends StatelessWidget {
  const HomeLog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            InkWell(
              //make it circular and blue in colour
              borderRadius: BorderRadius.circular(32),
              //overlayColor: MaterialStateProperty.all(Colors.blue),

              onTap: () async {
                showGeneralDialog(
                    barrierDismissible: true,
                    barrierLabel: '',
                    context: context,
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AlertDialog(
                          title: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                final box = GetStorage();
                                box.erase();
                                clueNo = 0;
                                // Navigator.popUntil(context, (route) {
                                //   return route.isFirst;
                                // });
                                // Navigator.pushAndRemoveUntil(context, , (route) => false)
                                // Navigator.push(context, MaterialPageRoute(
                                //   builder: (context) => const Login(),));
                                // Remove any route in the stack
                                Navigator.of(context)
                                    .popUntil((route) => false);

// Add the first route. Note MyApp() would be your first widget to the app.
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Home()),
                                );
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        ));
                // final box = GetStorage();
                // box.erase();
                // Navigator.popUntil(context, (route) {
                //   return route.isFirst;
                // });
              },
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.login),
                  )),
            ),
          ],
        ),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Validate(),
              ),
            );
          },
          child: const Text('Start Validation'),
        ),
      ),
      // ),
    );
  }
}
