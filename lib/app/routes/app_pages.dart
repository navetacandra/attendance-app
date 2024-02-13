import 'package:get/get.dart';

import '../modules/add_student/bindings/add_student_binding.dart';
import '../modules/add_student/views/add_student_view.dart';
import '../modules/cards/bindings/cards_binding.dart';
import '../modules/cards/views/cards_view.dart';
import '../modules/edit_student/bindings/edit_student_binding.dart';
import '../modules/edit_student/views/edit_student_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/pick_student/bindings/pick_student_binding.dart';
import '../modules/pick_student/views/pick_student_view.dart';
import '../modules/students/bindings/students_binding.dart';
import '../modules/students/views/students_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.STUDENTS,
      page: () => StudentsView(),
      binding: StudentsBinding(),
    ),
    GetPage(
      name: _Paths.ADD_STUDENT,
      page: () => AddStudentView(),
      binding: AddStudentBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_STUDENT,
      page: () => EditStudentView(),
      binding: EditStudentBinding(),
    ),
    GetPage(
      name: _Paths.CARDS,
      page: () => CardsView(),
      binding: CardsBinding(),
    ),
    GetPage(
      name: _Paths.PICK_STUDENT,
      page: () => PickStudentView(),
      binding: PickStudentBinding(),
    ),
  ];
}
