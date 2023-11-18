import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presence/app/routes/app_pages.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changePage(int i) async {
    switch (i) {
      case 1:
        Map<String, dynamic> dataResponse = await determinePosition();
        if (dataResponse["error"] != true) {
          Position position = dataResponse["position"];

          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          String address =
              "${placemarks[0].name}, ${placemarks[0].subLocality}, ${placemarks[0].locality}";
          await updatePosition(position, address);

          // cek distance betweeen 2 position
          double distance = Geolocator.distanceBetween(
              -6.3065, 107.1647967, position.latitude, position.longitude);

          // presensi
          await presensi(position, address, distance);

          // Get.snackbar("Berhasil", "Kamu telah mengisi daftar hadir");
        } else {
          Get.snackbar("Terjadi Kesalahan", dataResponse["message"]);
        }
        break;
      case 2:
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> presensi(
      Position position, String address, double distance) async {
    String uid = await auth.currentUser!.uid;

    CollectionReference<Map<String, dynamic>> colPresence =
        await firestore.collection("pegawai").doc(uid).collection("presence");

    QuerySnapshot<Map<String, dynamic>> snapPresence = await colPresence.get();

    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");

    String status = "Di luar area, Tidak bisa absen masuk";
    if (distance <= 10000) {
      status = "Di dalam area, bisa absen masuk";
    }

    if (snapPresence.docs.length == 0) {
      // belum pernah absen & set absen masuk pertama kalinya

      await Get.defaultDialog(
        title: "Validasi Presensi",
        middleText:
            "Apakah kamu yakin untuk mengisi daftar hadir absensi masuk?",
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await colPresence.doc(todayDocID).set({
                "date": now.toIso8601String(),
                "masuk": {
                  "date": now.toIso8601String(),
                  "lat": position.latitude,
                  "long": position.longitude,
                  "addres": address,
                  "status": status,
                  "distance": distance,
                },
              });
              Get.back();
              Get.snackbar("Berhasil", "Kamu telah mengisi daftar hadir masuk");
            },
            child: Text("Yes"),
          ),
        ],
      );
    } else {
      // sudah pernah absen? cek hari ini sudah absen masuk/keluar blm.
      DocumentSnapshot<Map<String, dynamic>> todayDoc =
          await colPresence.doc(todayDocID).get();

      if (todayDoc.exists == true) {
        // absen keluar && jika sudah absen masuk dan kelur
        Map<String, dynamic>? dataPresenceToday = todayDoc.data();

        if (dataPresenceToday?["keluar"] != null) {
          Get.snackbar("Informasi Penting",
              "Kamu sudah absen masuk & keluar, Tidak dapat mengubah data kembali");
        } else {
          await Get.defaultDialog(
            title: "Validasi Presensi",
            middleText:
                "Apakah kamu yakin untuk mengisi daftar hadir absensi keluar?",
            actions: [
              OutlinedButton(
                onPressed: () => Get.back(),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await colPresence.doc(todayDocID).update({
                    "keluar": {
                      "date": now.toIso8601String(),
                      "lat": position.latitude,
                      "long": position.longitude,
                      "addres": address,
                      "status": status,
                      "distance": distance,
                    },
                  });
                  Get.back();
                  Get.snackbar(
                      "Berhasil", "Kamu telah mengisi daftar hadir keluar");
                },
                child: Text("Yes"),
              ),
            ],
          );
        }
      } else {
        // jika belum ada maka absen
        await Get.defaultDialog(
          title: "Validasi Presensi",
          middleText:
              "Apakah kamu yakin untuk mengisi daftar hadir absensi masuk?",
          actions: [
            OutlinedButton(
              onPressed: () => Get.back(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await colPresence.doc(todayDocID).set({
                  "date": now.toIso8601String(),
                  "masuk": {
                    "date": now.toIso8601String(),
                    "lat": position.latitude,
                    "long": position.longitude,
                    "addres": address,
                    "status": status,
                    "distance": distance,
                  },
                });
                Get.back();
                Get.snackbar("Berhasil",
                    "Kamu telah mengisi daftar hadir untuk absensi masuk");
              },
              child: Text("Yes"),
            ),
          ],
        );
      }
    }
  }

  Future<void> updatePosition(Position position, String address) async {
    String uid = await auth.currentUser!.uid;

    await firestore.collection("pegawai").doc(uid).update(
      {
        "position": {
          "latitude": position.latitude,
          "longitude": position.longitude,
        },
        "address": address,
      },
    );
  }

  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // return Future.error('Location services are disabled.');
      return {
        "message": "Tidak dapat mengambil Location GPS dari device",
        "error": true,
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // return Future.error('Location permissions are denied');
        return {
          "message": "Izin menggunakan Location GPS di tolak",
          "error": true,
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
      return {
        "message": "Tidak mendapatkan Izin menggunakan Location GPS",
        "error": true,
      };
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return {
      "position": position,
      "message": "Mendapatkan Location GPS dari device",
      "error": false,
    };
  }
}
