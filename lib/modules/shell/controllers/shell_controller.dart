import 'package:get/get.dart';

class ShellController extends GetxController {
  final index = 0.obs;

  void select(int value) => index.value = value;
}
