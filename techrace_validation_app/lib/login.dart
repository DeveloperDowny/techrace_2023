import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techracev/home.dart';
import 'package:techracev/main.dart';
import 'package:techracev/utils/desk.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //vars
  int password = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TechRaceV'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              hintText: 'Enter Clue No. (to be validated)',
              contentPadding: EdgeInsets.all(8),
            ),
            onChanged: (value) {
              try {
                clueNo = int.parse(value);
              } catch (e) {
                //debugPrint("$e");
                clueNo = 0;
              }
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              hintText: 'Password',
              contentPadding: EdgeInsets.all(8),
            ),
            onChanged: (value) {
              try {
                password = int.parse(value);
              } catch (e) {
                //debugPrint("$e");
                password = 0;
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Builder(builder: (context) {
                return TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromARGB(255, 110, 105, 105).withOpacity(0.2)),
                    ),
                    onPressed: () async {
                      if (clueNo <= 0) {
                        Get.closeAllSnackbars();
                        Get.snackbar(
                          'Error',
                          'Please enter a valid clue number',
                        );
                      } else {
                        DatabaseReference ref = FirebaseDatabase.instance
                            .ref("/validation/$clueNo");
                        await ref.get().then((data) async {
                          if (data.value == null) {
                            Get.closeAllSnackbars();
                            Get.snackbar(
                              'Error',
                              'Clue number not found',
                            );
                          } else {
                            if (data.value == password) {
                              DatabaseReference newRef =
                                  FirebaseDatabase.instance.ref("/validation");
                              int newPass = Random().nextInt(899) + 100;
                              await newRef.update({
                                "$clueNo": newPass,
                              });
                              Get.closeAllSnackbars();
                              Get.snackbar('Logged In', '',
                                  snackPosition: SnackPosition.BOTTOM);
                              final box = GetStorage();
                              box.write('clueNo', clueNo);
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Home(),
                                ),
                              );
                            } else {
                              Get.closeAllSnackbars();
                              Get.snackbar(
                                'Error',
                                'Incorrect password',
                              );
                            }
                          }
                        });
                      }
                    },
                    child: const Text('Login'));
              }),
              const SizedBox(
                width: 10,
              ),
              Builder(builder: (context) {
                return TextButton(
                    onPressed: () async {
                      final box = GetStorage();
                      bool stateLog = box.read('stateLog') ?? false;
                      if (stateLog) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Desk(),
                          ),
                        );
                      } else {
                        DatabaseReference ref = FirebaseDatabase.instance
                          .ref("/validation/statePass");
                      await ref.get().then((data) async {
                        if (data.value == null) {
                          Get.closeAllSnackbars();
                          Get.snackbar(
                            'Error',
                            'Password not found',
                          );
                        } else {
                          if (data.value == password) {
                            int pass = Random().nextInt(899) + 100;
                            DatabaseReference newRef =
                                FirebaseDatabase.instance.ref("/validation");
                            await newRef.update({
                              'statePass': pass,
                            });

                            box.write('stateLog', true);
                            Get.closeAllSnackbars();
                            Get.snackbar('Logged In', '',
                                snackPosition: SnackPosition.BOTTOM);
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Desk(),
                              ),
                            );
                          } else {
                            Get.closeAllSnackbars();
                            Get.snackbar(
                              'Error',
                              'Incorrect password',
                            );
                          }
                        }
                      });
                      }
                      
                    },
                    child: const Text("State Login"));
              }),
            ],
          ),
        ]),
      ),
    );
  }
}
