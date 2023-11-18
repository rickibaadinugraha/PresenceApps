import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/detail_presensi_controller.dart';

class DetailPresensiView extends GetView<DetailPresensiController> {
  // const DetailPresensiView({Key? key}) : super(key: key);
  final Map<String, dynamic> data = Get.arguments;
  @override
  Widget build(BuildContext context) {
    print(data);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DETAIL PRESENSI'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "${DateFormat.yMMMMEEEEd().format(DateTime.parse(data["date"]))}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Masuk",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(data["masuk"]?["date"] == null
                    ? "Jam : -"
                    : "Jam : ${DateFormat.jms().format(DateTime.parse(data["masuk"]!["date"]))}"),
                Text(data["masuk"]?["lat"] == null &&
                        data["masuk"]?["long"] == null
                    ? "Posisi : -"
                    : "Posisi : ${data["masuk"]!["lat"]}, ${data["masuk"]!["long"]}"),
                Text(data["masuk"]?["status"] == null
                    ? "status : -"
                    : "Status : ${data["masuk"]!["status"]}"),
                Text(data["masuk"]?["distance"] == null
                    ? "Jarak : -"
                    : "Jarak : ${data["masuk"]!["distance"].toString().split(".").first} Meter"),
                Text("Addres : ${data["masuk"]!["addres"]}"),
                SizedBox(height: 20),
                Text(
                  "Keluar",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(data["keluar"]?["date"] == null
                    ? "Jam : -"
                    : "Jam : ${DateFormat.jms().format(DateTime.parse(data["keluar"]!["date"]))}"),
                Text(data["keluar"]?["lat"] == null &&
                        data["keluar"]?["long"] == null
                    ? "Posisi : -"
                    : "Posisi : ${data["keluar"]!["lat"]}, ${data["keluar"]!["long"]}"),
                Text(data["keluar"]?["status"] == null
                    ? "status: -"
                    : "Status: ${data["keluar"]!["status"]}"),
                Text(data["keluar"]?["distance"] == null
                    ? "Jarak : -"
                    : "Jarak : ${data["keluar"]!["distance"].toString().split(".").first} Meter"),
                Text(data["keluar"]?["addres"] == null
                    ? "Alamat : -"
                    : "Addres : ${data["keluar"]!["addres"]}"),
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }
}
