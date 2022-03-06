import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotifiedPage extends StatelessWidget {
  const NotifiedPage({
    required this.label,
    Key? key
  }) : super(key: key);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.isDarkMode ? Colors.grey[600]:Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: Get.isDarkMode ? Colors.white : Colors.black,),
        ),
        title: Text(label.split("|")[0],style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black),),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 400,
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Get.isDarkMode ? Colors.white:Colors.grey[400]
          ),
          child: Text(label.split("|")[1],style: TextStyle(color: Get.isDarkMode ? Colors.black : Colors.white, fontSize: 30),),
        ),
      ),
    );
  }
}