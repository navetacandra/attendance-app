import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_teacher_controller.dart';

class AddTeacherView extends GetView<AddTeacherController> {
  AddTeacherView({super.key});
  final selfC = Get.find<AddTeacherController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Form(
            key: selfC.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Obx(
                  () => TextFormField(
                    controller: selfC.formControllers["nama"],
                    keyboardType: TextInputType.name,
                    style: const TextStyle(fontSize: 17, color: Colors.black),
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 17,
                      ),
                      label: const Text(
                        "Nama",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.25,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.25,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        size: 28,
                      ),
                      errorText: selfC.formErrors["nama"],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => TextFormField(
                    controller: selfC.formControllers["kelas"],
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 17, color: Colors.black),
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 17,
                      ),
                      label: const Text(
                        "Kelas",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.25,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.25,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.school_rounded,
                        size: 28,
                      ),
                      errorText: selfC.formErrors["kelas"],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => TextFormField(
                    controller: selfC.formControllers["tel"],
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 17, color: Colors.black),
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 17,
                      ),
                      label: const Text(
                        "WhatsApp Guru",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.25,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.25,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.phone,
                        size: 28,
                      ),
                      errorText: selfC.formErrors["tel"],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() =>
                  InkWell(
                    onTap: () => selfC.isLoading.isFalse
                      ? selfC.submit()
                      : null,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: selfC.isLoading.isFalse
                          ? const Text(
                            "ADD STUDENT",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          )
                          : const CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
