import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/controllers/task_controller.dart';
import 'package:todo_app/services/notification_services.dart';
import 'package:todo_app/services/theme_services.dart';
import 'package:todo_app/ui/add_task_page.dart';
import 'package:todo_app/ui/theme.dart';
import 'package:todo_app/widgets/button.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());
  var notifyHelper;
  @override
  void initState() {
    super.initState();
    _taskController.getTasks();
  notifyHelper = NotifyHelper();
  notifyHelper.initializeNotification();
  notifyHelper.requestIOSPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          SizedBox(height: 10,),
          _showTasks(),
        ],
      ),
    );
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
          itemCount: _taskController.taskList.length,
          itemBuilder: ((context, index) {
            print(_taskController.taskList.length);
          return GestureDetector(
            onTap: () {
              _taskController.delete(_taskController.taskList[index]);
              _taskController.getTasks();
            },
            child: Container(
              width: 100,
              height: 50,
              color: Colors.green,
              margin: const EdgeInsets.only(bottom: 10),
              child: Text(_taskController.taskList[index].title.toString()),
            ),
          );
        }));
      }),
    );
  }

  Container _addDateBar() {
    return Container(
          margin: const EdgeInsets.only(top: 20, left: 20),
          child: DatePicker(
            DateTime.now(),
            height: 100,
            width: 80,
            initialSelectedDate: DateTime.now(),
            selectionColor: primaryClr,
            selectedTextColor: Colors.white,
            dateTextStyle: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey
              ),
            ),
            dayTextStyle: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey
              ),
            ),
            monthTextStyle: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey
              ),
            ),
            onDateChange: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          )
        );
  }

  Container _addTaskBar() {
    return Container(
          margin: EdgeInsets.only(right: 20,left: 20, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat.yMMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                  ),
                  Text('Today', style: headingStyle,)
                ],
              ),
              MyButton(label: "+Add Task", onTap: () async{
                await Get.to(AddTaskPage());
                _taskController.getTasks();
              }),
            ],
          ),
        );
  }

  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          // change theme action
          print('tapped');
          ThemeService().switchTheme();
          notifyHelper.displayNotification(title: "Theme Changed", body: Get.isDarkMode  ? "Activated light mode": "Activated dark mode");
          // Get.isDarkModeはへこうする前の状態を返すので反対に書く必要がある
          notifyHelper.scheduledNotification();
        },
        child:  Icon(Get.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
        size: 20,
        color: Get.isDarkMode ? Colors.white: Colors.black,),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: AssetImage("images/profile.png"),
        ),
        SizedBox(width: 10,)
      ],
    );
  }
}