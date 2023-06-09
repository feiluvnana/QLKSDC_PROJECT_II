import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_ii/model/BookingModel.dart';
import 'package:project_ii/model/RoomModel.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CatInfo(),
              SizedBox(height: 50),
              OwnerInfo(),
              SizedBox(height: 50),
              BookingInfo()
            ],
          ),
        ),
      ),
    );
  }
}

class CatInfo extends StatelessWidget {
  const CatInfo({super.key});

  @override
  Widget build(BuildContext context) {
    Booking bookingData = Get.arguments["bookingData"];
    Image catImage = Image.memory(
      base64.decode(bookingData.catData.catImage ?? ""),
      width: 500,
      height: 500,
      fit: BoxFit.scaleDown,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 1100,
            alignment: Alignment.centerLeft,
            child: const Text(
              "Thông tin mèo",
              style: TextStyle(
                color: Color(0xff3d426b),
                fontSize: 28,
              ),
            ),
          ),
        ),
        Table(
          columnWidths: const {
            0: FixedColumnWidth(100),
            1: FixedColumnWidth(1000)
          },
          border: TableBorder.all(width: 0.5),
          children: [
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Tên mèo"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(bookingData.catData.catName),
                )
              ],
            ),
            TableRow(
                decoration: BoxDecoration(color: Colors.grey[200]),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Ảnh"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: catImage,
                  ),
                ]),
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Giới tính"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(bookingData.catData.catGender ?? ""),
                )
              ],
            ),
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Tuổi"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(bookingData.catData.age.toString()),
                )
              ],
            ),
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Thể trạng"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(bookingData.catData.physicalCondition),
                )
              ],
            ),
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Giống"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(bookingData.catData.species ?? ""),
                )
              ],
            ),
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Đặc điểm nhận dạng"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(bookingData.catData.appearance ?? ""),
                )
              ],
            )
          ],
        )
      ],
    );
  }
}

class OwnerInfo extends StatelessWidget {
  const OwnerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    Booking bookingData = Get.arguments["bookingData"];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 1100,
            alignment: Alignment.centerLeft,
            child: const Text(
              "Thông tin chủ",
              style: TextStyle(
                color: Color(0xff3d426b),
                fontSize: 28,
              ),
            ),
          ),
        ),
        Table(
          columnWidths: const {
            0: FixedColumnWidth(100),
            1: FixedColumnWidth(1000)
          },
          border: TableBorder.all(width: 0.5),
          children: [
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Tên chủ"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      (bookingData.catData.ownerData.ownerGender == "Nam")
                          ? "(Anh) ${bookingData.catData.ownerData.ownerName}"
                          : "(Chị) ${bookingData.catData.ownerData.ownerName}"),
                )
              ],
            ),
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Số điện thoại"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(bookingData.catData.ownerData.tel),
                )
              ],
            ),
          ],
        )
      ],
    );
  }
}

class BookingInfo extends StatelessWidget {
  const BookingInfo({super.key});

  @override
  Widget build(BuildContext context) {
    Booking bookingData = Get.arguments["bookingData"];
    Room roomData = Get.arguments["roomData"];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 1100,
            alignment: Alignment.centerLeft,
            child: const Text(
              "Thông tin đặt phòng",
              style: TextStyle(
                color: Color(0xff3d426b),
                fontSize: 28,
              ),
            ),
          ),
        ),
        Table(
          columnWidths: const {
            0: FixedColumnWidth(100),
            1: FixedColumnWidth(1000)
          },
          border: TableBorder.all(width: 0.5),
          children: [
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Số phòng"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${roomData.roomID}(${bookingData.subNumber})"),
                )
              ],
            ),
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Ngày đặt phòng"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(DateFormat("yyyy-MM-dd HH:mm:ss")
                      .format(bookingData.bookingDate)),
                )
              ],
            ),
            const TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Phương thức thanh toán"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(""),
                )
              ],
            ),
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Lịch trình"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(text: "Check-in:\n"),
                                TextSpan(
                                  text: DateFormat("yyyy-MM-dd HH:mm:ss")
                                      .format(bookingData.dateIn),
                                  style: TextStyle(
                                      color: (bookingData.dateIn.hour < 14)
                                          ? Colors.red
                                          : null),
                                )
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(text: "Check-out:\n"),
                                TextSpan(
                                  text: DateFormat("yyyy-MM-dd HH:mm:ss")
                                      .format(bookingData.dateOut),
                                  style: TextStyle(
                                      color: (bookingData.dateOut.hour > 14 ||
                                              (bookingData.dateOut.hour == 14 &&
                                                  bookingData.dateOut.minute >
                                                      0))
                                          ? Colors.red
                                          : null),
                                )
                              ],
                            ),
                          ),
                        ),
                      ]),
                )
              ],
            ),
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Lễ tân tiếp nhận"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(bookingData.byRep),
                )
              ],
            ),
          ],
        )
      ],
    );
  }
}
