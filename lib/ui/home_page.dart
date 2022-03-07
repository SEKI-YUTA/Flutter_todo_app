import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:todo_app/controllers/task_controller.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/notification_services.dart';
import 'package:todo_app/services/theme_services.dart';
import 'package:todo_app/ui/add_task_page.dart';
import 'package:todo_app/ui/edit_task_page.dart';
import 'package:todo_app/ui/theme.dart';
import 'package:todo_app/widgets/button.dart';
import 'package:todo_app/widgets/task_tile.dart';

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
            Task task = _taskController.taskList[index];
            print("from home:${task.toJson()}");
            if(task.repeat == "Daily") {
              DateTime date = DateFormat.jm().parse(task.startTime.toString());
              var myTime = DateFormat("HH:mm").format(date);
              print(myTime);
              notifyHelper.scheduledNotification(int.parse(myTime.split(":")[0]),int.parse(myTime.split(":")[1]),task);
              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showBottomSheet(context, task);
                          },
                          child: TaskTile(task:task),
                        )
                      ],
                    ),
                  ),
                )
              );
            }
            if(task.date == DateFormat.yMd().format(_selectedDate)) {
              return AnimationConfiguration.staggeredList(
              position: index,
              child: SlideAnimation(
                child: FadeInAnimation(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showBottomSheet(context, task);
                        },
                        child: TaskTile(task:task),
                      )
                    ],
                  ),
                ),
              )
            );
            } else {
              return Container();
            }
            // return AnimationConfiguration.staggeredList(
            //   position: index,
            //   child: SlideAnimation(
            //     child: FadeInAnimation(
            //       child: Row(
            //         children: [
            //           GestureDetector(
            //             onTap: () {
            //               _showBottomSheet(context, task);
            //             },
            //             child: TaskTile(task:task),
            //           )
            //         ],
            //       ),
            //     ),
            //   )
            // );
        }));
      }),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: task.isCompleted == 1 ?
        MediaQuery.of(context).size.height * 0.24:
        MediaQuery.of(context).size.height * 0.40 ,
        color: Get.isDarkMode ? darkGreyClr : Colors.white,
        child: Column(
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600]:Colors.grey[300]
              ),
            ),
            Spacer(),
            task.isCompleted == 1 ?
            Container():
            _bottomSheetButton(label: "Task Complete", onTap: () {
              _taskController.markTaskCompleted(task.id!);
              Get.back();
            }, clr: primaryClr, context: context),
            const SizedBox(height: 5,),
            _bottomSheetButton(label: "Edit Task", onTap: () {
              Get.to(EditTaskPage(task: task));
            }, clr: Colors.green[300]!, context: context),
            const SizedBox(height: 5,),
            _bottomSheetButton(label: "Delete Task", onTap: () {
              _taskController.delete(task);
              Get.back();
            }, clr: Colors.red[300]!, context: context),
            SizedBox(height: 20,),
            _bottomSheetButton(label: "Close", onTap: () {
              Get.back();
            }, isColose: true,clr: Colors.red[300]!, context: context),
            SizedBox(height: 10,)
          ],
        ),
      )
    );
  }

  _bottomSheetButton({
    required String label,
    required Function()? onTap,
    required Color clr,
    bool isColose = false,
    required BuildContext context
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: isColose?Colors.transparent:clr,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 2,
            color: isColose?Get.isDarkMode?Colors.grey[600]!:Colors.grey[300]!:clr
          )
        ),
        child: Center(child: Text(label, style: isColose?titleStyle:titleStyle.copyWith(color: Colors.white),)),
      ),
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
              print(date);
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
          // この場合Get.isDarkModeは変更する前の状態を返すので反対に書く必要がある
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