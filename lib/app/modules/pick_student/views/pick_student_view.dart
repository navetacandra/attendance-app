import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pick_student_controller.dart';

class PickStudentView extends GetView<PickStudentController> {
  PickStudentView({super.key});
  final selfC = Get.find<PickStudentController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Student'),
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
                Container(
                  width: double.infinity,
                  height: 60,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Obx(
                    () => DropdownButton(
                      hint: const Text(
                        "Choose Student",
                        style: TextStyle(fontSize: 18),
                      ),
                      items: selfC.buildMenu(),
                      value: selfC.selectedStudent["_id"] == null
                          ? null
                          // ignore: invalid_use_of_protected_member
                          : selfC.selectedStudent.value,
                      onChanged: (student) => selfC
                          .changeSelection(student as Map<String, dynamic>),
                      isExpanded: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ...(selfC.card != null
                    ? [
                        Obx(
                          () => TextFormField(
                            controller: selfC.formControllers["card"],
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                fontSize: 17, color: Colors.black),
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 17,
                              ),
                              label: const Text(
                                "Card Tag",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
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
                                Icons.credit_card,
                                size: 28,
                              ),
                              errorText: selfC.formErrors["card"],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20)
                      ]
                    : []),
                Obx(
                  () => TextFormField(
                    controller: selfC.formControllers["nis"],
                    readOnly: true,
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
                    readOnly: true,
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
                    readOnly: true,
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
                    readOnly: true,
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
                    readOnly: true,
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
                    readOnly: true,
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
                    readOnly: true,
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
                    readOnly: true,
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
                Obx(() => 
                  InkWell(
                    onTap: () => selfC.isLoading.isFalse
                      ? selfC.submit(context)
                      : null,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: selfC.isLoading.isFalse
                          ? const Text(
                            "EDIT STUDENT",
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
