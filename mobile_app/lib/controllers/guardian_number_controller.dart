import 'package:get/get.dart';

class GuardianController extends GetxController {
  final _phoneNumber = '01084770706'.obs;
  set phoneNumber(String value) => this._phoneNumber.value = value;
  String get phoneNumber => this._phoneNumber.value;
}
