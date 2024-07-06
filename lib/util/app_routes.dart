import "package:cloud_storage_demo/binding/home_binding.dart";
import "package:cloud_storage_demo/screen/home_screen.dart";
import "package:get/get.dart";

class AppRoutes {
  AppRoutes._();
  static final AppRoutes instance = AppRoutes._();

  String get homeScreen => "/";

  List<GetPage<dynamic>> get getPages {
    final GetPage<dynamic> getPages = GetPage<dynamic>(
      name: homeScreen,
      page: HomeScreen.new,
      binding: HomeBinding(),
    );
    return <GetPage<dynamic>>[getPages];
  }
}
