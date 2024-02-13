import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_student_controller.dart';

class EditStudentView extends GetView<EditStudentController> {
  EditStudentView({super.key});
  final selfC = Get.find<EditStudentController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: FutureBuilder(
            future: selfC.getStudent(context),
            builder: (context, snapshot) {
              if(snapshot.connectionState != ConnectionState.done) return Container();
              if(snapshot.data != true) return Container();
              return Form(
                key: selfC.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Obx(
                      () => TextFormField(
                        controller: selfC.formControllers["nis"],
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 17, color: Colors.black),
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 17,
                          ),
                          label: const Text(
                            "Nomor Induk Siswa",
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
                            Icons.perm_identity_rounded,
                            size: 28,
                          ),
                          errorText: selfC.formErrors["nis"],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                        controller: selfC.formControllers["email"],
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 17, color: Colors.black),
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 17,
                          ),
                          label: const Text(
                            "Email",
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
                            Icons.email_rounded,
                            size: 28,
                          ),
                          errorText: selfC.formErrors["email"],
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
                        controller: selfC.formControllers["alamat"],
                        keyboardType: TextInputType.text,
                        style: const TextStyle(fontSize: 17, color: Colors.black),
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 17,
                          ),
                          label: const Text(
                            "Alamat",
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
                            Icons.home,
                            size: 28,
                          ),
                          errorText: selfC.formErrors["alamat"],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => TextFormField(
                        controller: selfC.formControllers["telSiswa"],
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 17, color: Colors.black),
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 17,
                          ),
                          label: const Text(
                            "WhatsApp Siswa",
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
                          errorText: selfC.formErrors["telSiswa"],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => TextFormField(
                        controller: selfC.formControllers["telWaliMurid"],
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 17, color: Colors.black),
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 17,
                          ),
                          label: const Text(
                            "WhatsApp Wali Murid",
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
                          errorText: selfC.formErrors["telWaliMurid"],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => TextFormField(
                        controller: selfC.formControllers["telWaliKelas"],
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 17, color: Colors.black),
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 17,
                          ),
                          label: const Text(
                            "WhatsApp Wali Kelas",
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
                          errorText: selfC.formErrors["telWaliKelas"],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => selfC.submit(context),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "EDIT STUDENT",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
