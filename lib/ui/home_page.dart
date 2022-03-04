import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/services/notification_services.dart';
import 'package:todo_app/services/theme_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var notifyHelper;
  @override
  void initState() {
    super.initState();
  notifyHelper = NotifyHelper();
  notifyHelper.initializeNotification();
  notifyHelper.requestIOSPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [
          Text('Theme Data', style: TextStyle(fontSize: 30),)
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      leading: GestureDetector(
        onTap: () {
          // change theme action
          print('tapped');
          ThemeService().switchTheme();
          notifyHelper.displayNotification(title: "Theme Changed", body: Get.isDarkMode  ? "Activated light mode": "Activated dark mode");
          // Get.isDarkModeはへこうする前の状態を返すので反対に書く必要がある
          notifyHelper.scheduledNotification();
        },
        child:  Icon(Icons.nightlight_round, size: 20,),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.person)),
        SizedBox(width: 10,)
      ],
    );
  }
}