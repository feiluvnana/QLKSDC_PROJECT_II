// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:project_ii/data/generators/excel_generator.dart';
import 'package:project_ii/data/providers/history_related_work_provider.dart';
import 'package:project_ii/utils/reusables/notice_dialog.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/providers/calendar_related_work_provider.dart';
import '../data/providers/info_related_work_provider.dart';
import '../models/cat_model.dart';
import '../models/order_model.dart';
import '../data/providers/addition_model.dart';
import '../models/owner_model.dart';
import '../models/room_group_model.dart';

abstract class InformationPageEvent {}

class ToggleModifyOwnerEvent extends InformationPageEvent {}

class ToggleModifyCatEvent extends InformationPageEvent {}

class ToggleModifyOrderEvent extends InformationPageEvent {}

class ModifyOwnerEvent extends InformationPageEvent {
  final String? name, tel, gender;

  ModifyOwnerEvent({this.name, this.tel, this.gender});
}

class ModifyCatEvent extends InformationPageEvent {
  final String? weightRank,
      name,
      species,
      physicalCondition,
      appearance,
      gender;
  final Uint8List? image;
  final int? age, sterilization, vaccination;
  final double? weight;

  ModifyCatEvent(
      {this.weightRank,
      this.name,
      this.species,
      this.physicalCondition,
      this.appearance,
      this.gender,
      this.image,
      this.age,
      this.sterilization,
      this.vaccination,
      this.weight});
}

class ModifyOrderEvent extends InformationPageEvent {
  final List<Addition>? additionsList;
  final DateTime? checkIn, checkOut;
  final String? attention, note;
  final String? roomID;
  final int? eatingRank, subRoomNum;

  ModifyOrderEvent(
      {this.additionsList,
      this.checkIn,
      this.checkOut,
      this.attention,
      this.note,
      this.roomID,
      this.eatingRank,
      this.subRoomNum});
}

class SaveChangesEvent extends InformationPageEvent {
  final BuildContext context;

  SaveChangesEvent(this.context);
}

class CancelOrderEvent extends InformationPageEvent {
  final BuildContext context;

  CancelOrderEvent(this.context);
}

class CheckoutEvent extends InformationPageEvent {
  final BuildContext context;

  CheckoutEvent(this.context);
}

class CheckinEvent extends InformationPageEvent {
  final BuildContext context;

  CheckinEvent(this.context);
}

class GotoHomePage extends InformationPageEvent {
  final BuildContext context;

  GotoHomePage(this.context);
}

class InformationState extends Equatable {
  final GlobalKey<FormState> formKey1, formKey2, formKey3;
  final bool isEditing1, isEditing2, isEditing3;
  final Order modifiedOrder, order;

  const InformationState(this.formKey1, this.formKey2, this.formKey3,
      {required this.isEditing1,
      required this.isEditing2,
      required this.isEditing3,
      required this.modifiedOrder,
      required this.order});

  InformationState copyWith({
    bool? isEditing1,
    bool? isEditing2,
    bool? isEditing3,
    bool? isEditing4,
    Order? order,
  }) {
    return InformationState(formKey1, formKey2, formKey3,
        isEditing1: isEditing1 ?? this.isEditing1,
        isEditing2: isEditing2 ?? this.isEditing2,
        isEditing3: isEditing3 ?? this.isEditing3,
        modifiedOrder: order ?? modifiedOrder,
        order: this.order);
  }

  Order modifyOrder(
      {List<Addition>? additionsList,
      DateTime? orderCheckIn,
      DateTime? orderCheckOut,
      String? orderAttention,
      String? orderNote,
      String? roomID,
      int? subRoomNum,
      int? eatingRank,
      Cat? cat}) {
    return Order.fromJson({
      "date": order.date.toString(),
      "checkin": (orderCheckIn != null)
          ? orderCheckIn.toString()
          : modifiedOrder.checkIn.toString(),
      "checkout": (orderCheckOut != null)
          ? orderCheckOut.toString()
          : modifiedOrder.checkOut.toString(),
      "incharge": "",
      "subroom_num": subRoomNum ?? modifiedOrder.subRoomNum,
      "eating_rank": eatingRank ?? modifiedOrder.eatingRank,
      "attention": orderAttention ?? modifiedOrder.attention,
      "note": orderNote ?? modifiedOrder.note,
      "additions_list": (additionsList != null)
          ? List.generate(
              additionsList.length, (index) => additionsList[index].toJson())
          : List.generate(modifiedOrder.additionsList?.length ?? 0,
              (index) => modifiedOrder.additionsList![index].toJson()),
      "room": roomID == null
          ? order.room.toJson()
          : GetIt.I<InternalStorage>()
              .read("roomGroupsList")
              .firstWhere((element) => element.room.id == roomID)
              .room
              .toJson(),
      "cat": cat == null ? order.cat.toJson() : cat.toJson(),
      "bill_num": -1,
      "is_out": 0
    });
  }

  Cat modifyCat(
      {String? catName,
      String? catWeightRank,
      int? catAge,
      String? catPhysicalCondition,
      double? catWeight,
      String? catGender,
      String? catAppearance,
      String? catSpecies,
      int? catSterilization,
      int? catVaccination,
      Uint8List? catImage,
      Owner? owner}) {
    return Cat.fromJson({
      "weight_rank": catWeightRank ?? modifiedOrder.cat.weightRank,
      "name": catName ?? modifiedOrder.cat.name,
      "age": catAge ?? modifiedOrder.cat.age,
      "physical_condition":
          catPhysicalCondition ?? modifiedOrder.cat.physicalCondition,
      "sterilization": catSterilization ?? modifiedOrder.cat.sterilization,
      "vaccination": catVaccination ?? modifiedOrder.cat.vaccination,
      "appearance": catAppearance ?? modifiedOrder.cat.appearance,
      "gender": catGender ?? modifiedOrder.cat.gender,
      "image": (catImage == null)
          ? ((modifiedOrder.cat.image == null)
              ? null
              : base64Encode(modifiedOrder.cat.image!))
          : base64Encode(catImage),
      "species": catSpecies ?? modifiedOrder.cat.species,
      "weight": catWeight ?? modifiedOrder.cat.weight,
      "owner": owner == null ? modifiedOrder.cat.owner.toJson() : owner.toJson()
    });
  }

  Owner modifyOwner(
      {String? ownerName, String? ownerGender, String? ownerTel}) {
    return Owner.fromJson({
      "name": ownerName ?? modifiedOrder.cat.owner.name,
      "gender": ownerGender ?? modifiedOrder.cat.owner.gender,
      "tel": ownerTel ?? modifiedOrder.cat.owner.tel
    });
  }

  @override
  List<Object?> get props =>
      [modifiedOrder, isEditing1, isEditing2, isEditing3];
}

class InfoPageBloc extends Bloc<InformationPageEvent, InformationState>
    with ExcelGenerator {
  final int ridx, oidx;
  InfoPageBloc(this.ridx, this.oidx)
      : super(InformationState(GlobalKey<FormState>(), GlobalKey<FormState>(),
            GlobalKey<FormState>(),
            isEditing1: false,
            isEditing2: false,
            isEditing3: false,
            modifiedOrder: (GetIt.I<InternalStorage>()
                    .read("roomGroupsList")[ridx] as RoomGroup)
                .ordersList[oidx],
            order: (GetIt.I<InternalStorage>().read("roomGroupsList")[ridx]
                    as RoomGroup)
                .ordersList[oidx])) {
    on<ToggleModifyCatEvent>((event, emit) {
      if (!state.order.isCheckedin && !state.order.isWalkedin) return;
      if (state.order.isCheckedout) return;
      emit(state.copyWith(isEditing1: !(state.isEditing1)));
    });
    on<ToggleModifyOwnerEvent>((event, emit) {
      if (!state.order.isCheckedin && !state.order.isWalkedin) return;
      if (state.order.isCheckedout) return;
      emit(state.copyWith(isEditing2: !(state.isEditing2)));
    });
    on<ToggleModifyOrderEvent>((event, emit) {
      if (!state.order.isCheckedin && !state.order.isWalkedin) return;
      if (state.order.isCheckedout) return;
      emit(state.copyWith(isEditing3: !(state.isEditing3)));
    });
    on<ModifyCatEvent>(
      (event, emit) {
        if (!state.order.isCheckedin && !state.order.isWalkedin) return;
        if (state.order.isCheckedout) return;
        emit(state.copyWith(
            order: state.modifyOrder(
                cat: state.modifyCat(
                    catAge: event.age,
                    catAppearance: event.appearance,
                    catGender: event.gender,
                    catImage: event.image,
                    catName: event.name,
                    catPhysicalCondition: event.physicalCondition,
                    catSpecies: event.species,
                    catSterilization: event.sterilization,
                    catVaccination: event.vaccination,
                    catWeight: event.weight,
                    catWeightRank: event.weightRank))));
      },
    );
    on<ModifyOwnerEvent>((event, emit) {
      if (!state.order.isCheckedin && !state.order.isWalkedin) return;
      if (state.order.isCheckedout) return;
      emit(state.copyWith(
          order: state.modifyOrder(
              cat: state.modifyCat(
                  owner: state.modifyOwner(
                      ownerGender: event.gender,
                      ownerName: event.name,
                      ownerTel: event.tel)))));
    });
    on<ModifyOrderEvent>((event, emit) {
      if (!state.order.isCheckedin && !state.order.isWalkedin) return;
      if (state.order.isCheckedout) return;
      emit(state.copyWith(
          order: state.modifyOrder(
              additionsList: event.additionsList,
              orderAttention: event.attention,
              orderCheckIn: event.checkIn,
              orderCheckOut: event.checkOut,
              orderNote: event.note,
              subRoomNum: event.subRoomNum,
              eatingRank: event.eatingRank,
              roomID: event.roomID)));
    });
    on<GotoHomePage>((event, emit) => event.context.pop());
    on<SaveChangesEvent>((event, emit) async {
      if (!state.order.isCheckedin && !state.order.isWalkedin) {
        await NoticeDialog.showMessageDialog(event.context,
            text: "Không thể thay đổi vì chưa check-in hoặc walk-in.");
        return;
      }
      if (state.order.isCheckedout) return;
      if (state.formKey1.currentState?.validate() != true) return;
      if (state.formKey2.currentState?.validate() != true) return;
      if (state.formKey3.currentState?.validate() != true) return;
      bool isSuccessed = false;
      List<Addition>? list;
      DateTime now = DateTime.now();
      if (state.modifiedOrder.additionsList != null) {
        list =
            List.generate(state.modifiedOrder.additionsList!.length, (index) {
          if (state.modifiedOrder.additionsList![index].time == null) {
            if (GetIt.I<InternalStorage>()
                    .read("servicesList")
                    .firstWhere((element) =>
                        element.id ==
                        state.modifiedOrder.additionsList![index].serviceID)
                    .name ==
                "Trả mèo") {
              return Addition.fromJson({
                "service_id":
                    state.modifiedOrder.additionsList![index].serviceID,
                "distance": state.modifiedOrder.additionsList![index].distance,
                "quantity": state.modifiedOrder.additionsList![index].quantity,
                "time": state.modifiedOrder.checkOut.toString()
              });
            }
            return Addition.fromJson({
              "service_id": state.modifiedOrder.additionsList![index].serviceID,
              "distance": state.modifiedOrder.additionsList![index].distance,
              "quantity": state.modifiedOrder.additionsList![index].quantity,
              "time": now.add(const Duration(minutes: 30)).toString()
            });
          }
          return state.modifiedOrder.additionsList![index];
        });
        emit(state.copyWith(
            order: state.modifyOrder(
          additionsList: list,
        )));
      }
      await InfoRelatedWorkProvider.saveChanges(
              state.modifiedOrder, state.order)
          .then((res) async {
        if (jsonDecode(res.body)["errors"].length == 0) {
          await NoticeDialog.showMessageDialog(event.context,
              text: "Thay đổi thông tin đặt phòng thành công");
          isSuccessed = true;
        } else {
          NoticeDialog.showErrDialog(event.context,
              errList: jsonDecode(res.body)["errors"],
              firstText: "Thay đổi thông tin đặt phòng thất bại");
        }
      });
      if (!isSuccessed) return;
      CalendarRelatedWorkProvider.clearRoomGroupsList();
      HistoryRelatedWorkProvider.clearHistoriesList();
      await CalendarRelatedWorkProvider(
              currentMonth: DateTime(state.modifiedOrder.checkIn.year,
                  state.modifiedOrder.checkIn.month),
              today: DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day))
          .getRoomGroups();
      List<RoomGroup> roomGroupsList =
          GetIt.I<InternalStorage>().read("roomGroupsList");
      int newRidx = roomGroupsList.indexOf(roomGroupsList.firstWhere(
          (element) => element.room.id == state.modifiedOrder.room.id));
      List<Order> ordersList = roomGroupsList[newRidx].ordersList;
      int newOidx = ordersList.indexOf(ordersList.firstWhere((element) =>
          element.date == state.modifiedOrder.date &&
          element.checkIn == state.modifiedOrder.checkIn &&
          element.checkOut == state.modifiedOrder.checkOut &&
          element.subRoomNum == state.modifiedOrder.subRoomNum &&
          element.room.id == state.modifiedOrder.room.id));
      event.context.replace("/info",
          extra: {"ridx": newRidx.toString(), "oidx": newOidx.toString()});
    });
    on<CancelOrderEvent>((event, emit) async {
      if (state.order.isCheckedin || state.order.isWalkedin) {
        await NoticeDialog.showMessageDialog(event.context,
            text: "Không thể hủy vì đã check-in hoặc walk-in.");
        return;
      }
      if (state.order.isCheckedout) return;
      int hours = DateTime(state.order.checkIn.year, state.order.checkIn.month,
              state.order.checkIn.day, 14)
          .difference(DateTime.now())
          .inHours;
      if ((await NoticeDialog.showConfirmDialog(event.context,
              text:
                  "Tình trạng hủy phòng: Trước khi check-in ${hours} tiếng${hours < 48 ? " (Hủy phòng trễ)" : ""}.") !=
          true)) return;
      await InfoRelatedWorkProvider.cancel(state.order,
              charge: hours >= 48
                  ? 0
                  : hours >= 24
                      ? 0.5
                      : 1)
          .then((res) async {
        if (jsonDecode(res.body)["errors"].length == 0) {
          await NoticeDialog.showMessageDialog(event.context,
              text: "Huỷ đặt phòng thành công");
          await createCancelBill(
              oidx: oidx,
              ridx: ridx,
              billTemplate: jsonDecode(res.body)["results"]);
          HistoryRelatedWorkProvider.clearHistoriesList();
          CalendarRelatedWorkProvider.clearRoomGroupsList();
          add(GotoHomePage(event.context));
        } else {
          NoticeDialog.showErrDialog(event.context,
              errList: jsonDecode(res.body)["errors"],
              firstText: "Huỷ đặt phòng thất bại");
        }
      });
    });
    on<CheckoutEvent>((event, emit) async {
      if (state.order.isCheckedout) return;
      int hours = DateTime.now()
          .difference(DateTime(state.order.checkIn.year,
              state.order.checkIn.month, state.order.checkIn.day, 14))
          .inHours;
      bool inTime = DateTime.now().day == state.order.checkOut.day &&
          DateTime.now().month == state.order.checkOut.month &&
          DateTime.now().year == state.order.checkOut.year;
      bool? charge = await NoticeDialog.showCheckoutDialog(event.context,
          text:
              "Tình trạng check-out: Sau check-in $hours tiếng. ${inTime ? "Đúng" : "Khác"} ngày check-out dự kiến.");
      if (charge == null) return;
      bool isSuccessed = false;
      await InfoRelatedWorkProvider.checkout(state.order,
              charge: charge || inTime
                  ? hours >= 48
                      ? 0
                      : hours >= 24
                          ? 0.5
                          : 1
                  : 0)
          .then((res) async {
        if (jsonDecode(res.body)["errors"].length == 0) {
          await NoticeDialog.showMessageDialog(event.context,
              text: "Check-out thành công. Chuẩn bị xuất hoá đơn.");
          await createBill(
              oidx: oidx,
              ridx: ridx,
              billTemplate: jsonDecode(res.body)["results"]);
          isSuccessed = true;
        } else {
          NoticeDialog.showErrDialog(event.context,
              errList: jsonDecode(res.body)["errors"],
              firstText: "Check-out thất bại");
        }
      });
      if (!isSuccessed) return;
      HistoryRelatedWorkProvider.clearHistoriesList();
      CalendarRelatedWorkProvider.clearRoomGroupsList();
      await CalendarRelatedWorkProvider(
              currentMonth: DateTime(state.modifiedOrder.checkIn.year,
                  state.modifiedOrder.checkIn.month),
              today: DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day))
          .getRoomGroups();
      List<RoomGroup> roomGroupsList =
          GetIt.I<InternalStorage>().read("roomGroupsList");
      int newRidx = roomGroupsList.indexOf(roomGroupsList.firstWhere(
          (element) => element.room.id == state.modifiedOrder.room.id));
      List<Order> ordersList = roomGroupsList[newRidx].ordersList;
      int newOidx = ordersList.indexOf(ordersList.firstWhere((element) =>
          element.date == state.modifiedOrder.date &&
          element.checkIn == state.modifiedOrder.checkIn &&
          element.subRoomNum == state.modifiedOrder.subRoomNum &&
          element.room.id == state.modifiedOrder.room.id));
      print("check");
      event.context.replace("/info",
          extra: {"ridx": newRidx.toString(), "oidx": newOidx.toString()});
    });

    on<CheckinEvent>((event, emit) async {
      if (state.order.isCheckedout) return;
      event.context.replace("/info/checkin", extra: state.order);
    });
  }

  @override
  void onTransition(
      Transition<InformationPageEvent, InformationState> transition) {
    super.onTransition(transition);
  }
}