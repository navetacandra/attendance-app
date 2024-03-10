import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  AuthView({super.key});
  final selfC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          margin: const EdgeInsets.only(top: 120),
          child: Form(
            key: selfC.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "LOGIN",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: TextFormField(
                    controller: selfC.usernameController,
                    keyboardType: TextInputType.text,
                    textAlignVertical: TextAlignVertical.bottom,
                    maxLines: 1,
                    validator: selfC.validateUsername,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Username or Email",
                      labelText: "Username",
                      prefixIcon: const Icon(Icons.person, color: Colors.black, size: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: TextFormField(
                    controller: selfC.passwordController,
                    keyboardType: TextInputType.text,
                    textAlignVertical: TextAlignVertical.bottom,
                    maxLines: 1,
                    validator: selfC.validatePassword,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Password",
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock, color: Colors.black, size: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                InkWell(
                  onTap: () => selfC.submit(),
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.grey.withOpacity(.5),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: Offset.zero
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "LOGIN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    )
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
