import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/controllers/task_controller.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/ui/theme.dart';
import 'package:todo_app/widgets/button.dart';
import 'package:todo_app/widgets/input_field.dart';

class EditTaskPage extends StatefulWidget {
  EditTaskPage({
    required this.task,
    Key? key
  }) : super(key: key);
  Task task;

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late final Task? task;
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late DateTime _selectedDate;
  late String _endTime;
  late String _startTime;
  late int _selectedRemind;
  List<int> remindList = [
    5,10,15,20
  ];
  String _selectedRepeat = "None";
  List<String> repeatList = [
    "None","Daily","Weekly","Monthly"
  ];
  late int _selectedColor;
  @override
  void initState() {
    task = widget.task;
    setState(() {
      _titleController.text = task!.title.toString();
      _noteController.text = task!.note.toString();
      _selectedDate = DateTime(int.parse(task!.date!.split('/')[2]),
      int.parse(task!.date!.split('/')[0]),
      int.parse(task!.date!.split('/')[1]));
      _startTime = _convertStringToTime(task!.startTime.toString());
      _endTime = _convertStringToTime(task!.endTime.toString());
      _selectedRepeat = task!.repeat.toString();
      _selectedRemind = int.parse(task!.remind.toString());
      _selectedColor = int.parse(task!.color.toString());
    });
  }
  @override
  Widget build(BuildContext context) {
    print(_selectedDate);
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(context),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Task', style: headingStyle,),
              MyInputField(title: "Title", hint: "Enter your title", controller: _titleController,),
              MyInputField(title: "Note", hint: "Enter your note", controller: _noteController,),
              MyInputField(title: "Date",
              hint: DateFormat('yyyy/MM/dd').format(_selectedDate),
              widget: IconButton(
                  onPressed: () {
                    _getDateFromUser();
                  },
                  icon: const Icon(Icons.calendar_today_outlined,color: Colors.grey,),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: MyInputField(title: "Start Time",
                    hint: _startTime,
                    widget: IconButton(
                      onPressed: () {
                        _getTimeFromUser(isStartTime: true);
                        
                      },
                      icon: Icon(Icons.access_time_rounded, color: Colors.grey,),
                    ),
                    ),
                  ),
                  SizedBox(width: 12,),
                  Expanded(
                    child: MyInputField(title: "End Time",
                    hint: _endTime,
                    widget: IconButton(
                      onPressed: () {
                        _getTimeFromUser(isStartTime: false);
                      },
                      icon: Icon(Icons.access_time_rounded, color: Colors.grey,),
                    ),
                    ),
                  ),
                ],
              ),
              MyInputField(title: "Remind", hint: "${_selectedRemind} min early",
                widget: DropdownButton(
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey,),
                  iconSize: 32,
                  elevation: 4,
                  underline: Container(height: 0),
                  style: subTitleStyle,
                  items: remindList.map<DropdownMenuItem<String>>((int value){
                    return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text("${value} min early")
                    );
                  }).toList(),
                  onChanged: (String? newVal) {
                    if(newVal != null) {
                      setState(() {
                        _selectedRemind = int.parse(newVal);
                      });
                    }
                  },
                ),
              ),
              MyInputField(title: "Repeat", hint: "${_selectedRepeat}",
                widget: DropdownButton(
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey,),
                  iconSize: 32,
                  elevation: 4,
                  underline: Container(height: 0),
                  style: subTitleStyle,
                  items: repeatList.map<DropdownMenuItem<String>>((String value){
                    return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text("${value}",)
                    );
                  }).toList(),
                  onChanged: (String? newVal) {
                    if(newVal != null) {
                      setState(() {
                        _selectedRepeat = newVal;
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 18,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPallete(),
                  MyButton(label: "Edit Task", onTap: () {
                    _validateData();
                  })
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _validateData() {
    if(_titleController.text.isNotEmpty&&_noteController.text.isNotEmpty) {
      // add to database
      _editTaskOfDB();
      Get.back();
    } else if(_titleController.text.isEmpty || _noteController.text.isEmpty){
      Get.snackbar("Required", 'All field are required!',
      snackPosition: SnackPosition.BOTTOM, 
      backgroundColor: Colors.white,
      colorText: Colors.red,
      icon: Icon(Icons.warning_amber_outlined)
      );
    }
  }

  _editTaskOfDB() async {
    print("editTaskOfDB");
    print(_titleController.text);
    print(_noteController.text);
    await _taskController.editTask(
        task:Task(
          id: task!.id,
        title: _titleController.text,
        note: _noteController.text,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        remind: _selectedRemind,
        repeat: _selectedRepeat,
        color: _selectedColor,
        isCompleted: 0
      )
    );

  }

  Column _colorPallete() {
    return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Color', style: titleStyle,),
                    SizedBox(height: 8,),
                    Wrap(
                      children: List<Widget>.generate(3, (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                          _selectedColor = index;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: index==0?primaryClr:index==1?pinkClr:yellowClr,
                            child: _selectedColor==index?Icon(Icons.check, size: 16,color: Colors.white,):Container(),
                          ),
                        ),
                      )),
                    )
                  ],
                );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child:  Icon(Icons.arrow_back_ios,
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

  _getDateFromUser() async {
    DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2100));
      if(_pickedDate != null) {
        print('pickedDate$_pickedDate');
        setState(() {
          _selectedDate = _pickedDate;
        });
      }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    var _pickedTime = await _showTimePicker();
    String _formattedTime = _pickedTime.format(context);
    if(_pickedTime ==null) {
      print('Time canceled');
    } else if(isStartTime) {
      setState(() {
        _startTime = _formattedTime;
      });
    } else if(!isStartTime) {
      setState(() {
        _endTime = _formattedTime;
      });
    }
  }

  _showTimePicker() {
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_startTime.split(':')[0]),
        minute: int.parse(_startTime.split(':')[1].split(' ')[0])
      )
    );
  }

  _convertStringToDate() {

  }

  _convertStringToTime(String startTime) {
    DateTime date = DateFormat.jm().parse(startTime);
    var myTime = DateFormat("HH:mm a").format(date);
    return myTime;
  }
  
}