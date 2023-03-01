import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class UpdatePasswordController extends GetxController {
  RxBool isloading = false.obs;
  TextEditingController currC = TextEditingController();
  TextEditingController newC = TextEditingController();
  TextEditingController confirmC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  void updatePass() async {
    if (currC.text.isNotEmpty &&
        newC.text.isNotEmpty &&
        confirmC.text.isNotEmpty) {
      if (newC.text == confirmC.text) {
        isloading.value = true;
        try {
          String emailUser = auth.currentUser!.email!;

          await auth.signInWithEmailAndPassword(
              email: emailUser, password: currC.text);

          await auth.currentUser!.updatePassword(newC.text);

          print("Update Password Berhasil");
          Get.back();
          Get.snackbar("Berhasil", "Berhasil memperbarui password");
        } on FirebaseAuthException catch (e) {
          if (e.code == "wrong-password") {
            Get.snackbar(
                "Terjadi ksesalahan", "Password yang dimasukkan salah");
          } else {
            Get.snackbar("Tejadi kesalahan", "${e.code.toLowerCase()}");
          }
        } catch (e) {
          Get.snackbar("Terjadi kesalahan", "Tidak dapat update password");
        } finally {
          isloading.value = false;
        }
      } else {
        Get.snackbar("Terjadi kesalahan", "Confirm password tidak cocok");
      }
    } else {
      Get.snackbar("Terjadi kesalahan", "Semua harus wajib di input");
    }
  }
}
