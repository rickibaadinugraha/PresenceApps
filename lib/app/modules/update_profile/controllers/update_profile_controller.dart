import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateProfileController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController nipC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();
  final ImagePicker picker = ImagePicker();

  XFile? image;

  void pickImage() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print(image!.name);
      print(image!.name.split(".").last);
      print(image!.path);
    } else {
      print(image);
    }
    update();
  }

  Future<void> updateProfile(String uid) async {
    if (nipC.text.isNotEmpty &&
        nameC.text.isNotEmpty &&
        emailC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        Map<String, dynamic> data = {
          "name": nameC.text,
        };
        if (image != null) {
          File file = File(image!.path);
          String ext = image!.name.split(".").last;

          await storageRef.child("$uid/profile.$ext").putFile(file);
          String urlImage =
              await storageRef.child("$uid/profile.$ext").getDownloadURL();

          data.addAll({"profile": urlImage});
        }
        await firestore.collection("pegawai").doc(uid).update(data);
        image = null;
        Get.snackbar("Berhasil", "Telah berhasil perbarui profil");
      } catch (e) {
        Get.snackbar("Terjadi kesalahan", "Tidak dapat perbarui profil");
      } finally {
        isLoading.value = false;
      }
    }
  }

  void deleteProfile(String uid) async {
    try {
      await firestore
          .collection("pegawai")
          .doc(uid)
          .update({"profile": FieldValue.delete()});
      Get.back();
      Get.snackbar("Berhasil", "Telah berhasil hapus gambar profil");
    } catch (e) {
      Get.snackbar("Tejadi kesalahan", "Tidak dapat hapus gambar profil");
    } finally {
      update();
    }
  }
}
