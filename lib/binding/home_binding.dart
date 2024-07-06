import "package:cloud_storage_demo/controller/home_controller.dart";
import "package:get/get.dart";

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(HomeController.new);
  }
}
