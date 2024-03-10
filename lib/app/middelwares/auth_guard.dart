import 'package:attendance_app/app/routes/app_pages.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final storage = GetStorage();
    final hasToken = storage.read("token") != null;
    if(!hasToken) return const RouteSettings(name: Routes.AUTH);
    return null;
  }
}
