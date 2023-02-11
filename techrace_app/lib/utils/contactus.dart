import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ContactTile(
                  name: 'Bhushan Jadhav',
                  designation: 'Executive Head',
                  phone: '9136037456',
                  icon: FontAwesomeIcons.shieldHalved,
                ),
                ContactTile(
                  name: 'Atharv Bhagwat',
                  designation: 'Vice Executive Head',
                  phone: '8104742560',
                  icon: FontAwesomeIcons.shield,
                ),
                ContactTile(
                  name: 'Naman Badlani',
                  designation: 'Operations',
                  phone: '9619480353',
                  icon: FontAwesomeIcons.spaceAwesome,
                ),
                ContactTile(
                  name: 'Vedant Panchal',
                  designation: 'Technical Head',
                  phone: '8975803664',
                  icon: FontAwesomeIcons.server,
                ),
                ContactTile(
                  name: 'Stephen Vaz',
                  designation: 'Technical Head',
                  phone: '8779683559',
                  icon: FontAwesomeIcons.microchip,
                ),
              ],
            ),
          ),
        ));
  }
}

class ContactTile extends StatelessWidget {
  ContactTile({
    super.key,
    required this.name,
    required this.designation,
    required this.phone,
    required this.icon,
  });
  String name;
  String designation;
  String phone;
  IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(3),
      leading: Padding(
        padding: const EdgeInsets.all(4.0),
        child: FaIcon(
          icon,
          size: 25.w,
        ),
      ),
      minLeadingWidth: 0,
      minVerticalPadding: 0,
      title: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name),
              Text(designation,
                  style: TextStyle(fontSize: 11, color: Colors.blue)),
            ],
          ),
          const Spacer(),
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    constraints: BoxConstraints(minHeight: 10, minWidth: 40),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      launchUrl(Uri.parse('tel:$phone'));
                    },
                    icon: const Icon(
                      Icons.phone,
                    )),
                IconButton(
                  constraints: BoxConstraints(minHeight: 30, minWidth: 30),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // if(Platform.isIOS) {
                    List nameList = name.split(' ');
                    launchUrl(
                        Uri.parse(
                            'https://api.whatsapp.com/send?phone=91$phone&text=Hi%20${nameList[0]}'),
                        mode: LaunchMode.externalApplication);
                    // launchUrl(Uri.parse(
                    //     'https://api.whatsapp.com/send?phone=91$phone&text=Hi%20Bushan'));
                    // }
                    // else {
                    //   launchUrl(Uri.parse('https://wa.me/91$phone?text=Hi%20Bushan'));
                    // }
                  },
                  icon: const FaIcon(FontAwesomeIcons.whatsapp),
                ),
              ]),
        ],
      ),
      // subtitle: Row(children: [
      //   IconButton(
      //       onPressed: () {
      //         launchUrl(Uri.parse('tel:8779683559'));
      //       },
      //       icon: const Icon(Icons.phone)),
      //   IconButton(
      //     onPressed: () {
      //       launchUrl(Uri.parse(
      //           'https://wa.me/9198779683559?text=Hi%20Bushan'));
      //     },
      //     icon: const FaIcon(FontAwesomeIcons.whatsapp),
      //   ),
      // ]),
      // subtitle: Column(
      //   // mainAxisAlignment: MainAxisAlignment.start,
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     const Text('Executive Head'),
      //     Row(children: [
      //       IconButton(
      //           onPressed: () {},
      //           icon: const Icon(Icons.phone)),
      //       IconButton(
      //         onPressed: () {},
      //         icon: const FaIcon(FontAwesomeIcons.whatsapp),
      //       ),
      //     ]),
      //   ],
      // ),
    );
  }
}

// Widget contactDesign() {
//   return Container(
//       //custom list tile design

//       );
// }
