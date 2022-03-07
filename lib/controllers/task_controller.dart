import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/db/db_helper.dart';
import 'package:todo_app/models/task.dart';

class TaskController extends GetxController {

  @override
  void onReady() {
    super.onReady();
  }

  var taskList = <Task>[].obs;

  Future<int> addTask({Task? task}) async {
    return await DBHelper.insert(task);
  }

  void getTasks() async {
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

  void delete(Task task) {
    DBHelper.delete(task);
    //  print(val);
    getTasks();
  }

  void markTaskCompleted(int id) async{
    await DBHelper.updateCompleted(id);
    getTasks(); 
  }

  Future editTask({required Task task}) async {
    // print('edit task in task_controller');
    await DBHelper.editTaskData(task);
    getTasks();
  }

  void printAllData() {
    DBHelper.printAllData();
  }
}
