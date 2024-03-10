import 'package:attendance_app/app/middelwares/auth_guard.dart';
import 'package:attendance_app/app/middelwares/non_auth_guard.dart';
import 'package:get/get.dart';

import '../modules/add_student/bindings/add_student_binding.dart';
import '../modules/add_student/views/add_student_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/cards/bindings/cards_binding.dart';
import '../modules/cards/views/cards_view.dart';
import '../modules/edit_student/bindings/edit_student_binding.dart';
import '../modules/edit_student/views/edit_student_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/pick_student/bindings/pick_student_binding.dart';
import '../modules/pick_student/views/pick_student_view.dart';
import '../modules/report/bindings/report_binding.dart';
import '../modules/report/views/report_view.dart';
import '../modules/schedule/bindings/schedule_binding.dart';
import '../modules/schedule/views/schedule_view.dart';
import '../modules/student_table/bindings/student_table_binding.dart';
import '../modules/student_table/views/student_table_view.dart';
import '../modules/students/bindings/students_binding.dart';
import '../modules/students/views/students_view.dart';
import '../modules/whatsapp/bindings/whatsapp_binding.dart';
import '../modules/whatsapp/views/whatsapp_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.AUTH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.STUDENTS,
      page: () => StudentsView(),
      binding: StudentsBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.ADD_STUDENT,
      page: () => AddStudentView(),
      binding: AddStudentBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.EDIT_STUDENT,
      page: () => EditStudentView(),
      binding: EditStudentBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.CARDS,
      page: () => CardsView(),
      binding: CardsBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.PICK_STUDENT,
      page: () => PickStudentView(),
      binding: PickStudentBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.WHATSAPP,
      page: () => WhatsappView(),
      binding: WhatsappBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.SCHEDULE,
      page: () => ScheduleView(),
      binding: ScheduleBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.REPORT,
      page: () => ReportView(),
      binding: ReportBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.STUDENT_TABLE,
      page: () => StudentTableView(),
      binding: StudentTableBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => AuthView(),
      binding: AuthBinding(),
      middlewares: [NonAuthGuard()],
    ),
  ];
}
