import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:project_ii/data/dependencies/internal_storage.dart';
import 'package:project_ii/data/providers/service_related_work_provider.dart';
import 'package:project_ii/utils/reusables/notice_dialog.dart';
import '../data/providers/calendar_related_work_provider.dart';
import '../data/providers/history_related_work_provider.dart';
import '../data/providers/info_related_work_provider.dart';
import '../data/types/render_state.dart';
import '../data/providers/addition_model.dart';
import '../models/cat_model.dart';
import '../models/owner_model.dart';
import '../models/order_model.dart';
import '../models/room_group_model.dart';

abstract class CheckinPageEvent {}

class NextStepEvent extends CheckinPageEvent {
  final BuildContext context;

  NextStepEvent(this.context);
}

class BackStepEvent extends CheckinPageEvent {}

class PickImageEvent extends CheckinPageEvent {
  final Uint8List? bytes;

  PickImageEvent(this.bytes);
}

class RequireDataEvent extends CheckinPageEvent {}

class CompleteRenderEvent extends CheckinPageEvent {}

class RefreshEvent extends CheckinPageEvent {}

class ModifyOwnerEvent extends CheckinPageEvent {
  final String? name, tel, gender;

  ModifyOwnerEvent({this.name, this.tel, this.gender});
}

class ModifyCatEvent extends CheckinPageEvent {
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

class ModifyOrderEvent extends CheckinPageEvent {
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

class SubmitDataEvent extends CheckinPageEvent {
  final BuildContext context;

  SubmitDataEvent(this.context);
}

class CheckinState extends Equatable {
  final GlobalKey<FormState> formKey1, formKey2, formKey3;
  final Order order;
  final RenderState renderState;
  final int currentStep;

  const CheckinState(this.formKey1, this.formKey2, this.formKey3,
      {required this.order,
      required this.currentStep,
      required this.renderState});

  @override
  List<Object?> get props => [order, currentStep, renderState];

  CheckinState copyWith(
      {Order? order, int? currentStep, RenderState? renderState}) {
    return CheckinState(formKey1, formKey2, formKey3,
        order: order ?? this.order,
        currentStep: currentStep ?? this.currentStep,
        renderState: renderState ?? this.renderState);
  }

  Order modifyOrder({
    List<Addition>? additionsList,
    DateTime? orderCheckIn,
    DateTime? orderCheckOut,
    String? orderAttention,
    String? orderNote,
    String? roomID,
    int? subRoomNum,
    int? eatingRank,
    Cat? cat,
  }) {
    return Order.fromJson(
      {
        "date": order.date.toString(),
        "checkin": (orderCheckIn != null)
            ? orderCheckIn.toString()
            : order.checkIn.toString(),
        "checkout": (orderCheckOut != null)
            ? orderCheckOut.toString()
            : order.checkOut.toString(),
        "incharge": "Nguyễn Tùng Dương",
        "subroom_num": subRoomNum ?? order.subRoomNum,
        "eating_rank": eatingRank ?? order.eatingRank,
        "attention": orderAttention ?? order.attention,
        "note": orderNote ?? order.note,
        "bill_num": -1,
        "is_out": 0,
        "additions_list": (additionsList != null)
            ? List.generate(
                additionsList.length, (index) => additionsList[index].toJson())
            : List.generate(order.additionsList?.length ?? 0,
                (index) => order.additionsList![index].toJson()),
        "room": roomID == null
            ? order.room.toJson()
            : GetIt.I<InternalStorage>()
                .read("roomGroupsList")
                .firstWhere((element) => element.room.id == roomID)
                .room
                .toJson(),
        "cat": cat == null ? order.cat.toJson() : cat.toJson(),
        "is_checkedin": 1,
        "is_walkedin": 0,
      },
    );
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
      "weight_rank": catWeightRank ?? order.cat.weightRank,
      "name": catName ?? order.cat.name,
      "age": catAge ?? order.cat.age,
      "physical_condition": catPhysicalCondition ?? order.cat.physicalCondition,
      "sterilization": catSterilization ?? order.cat.sterilization,
      "vaccination": catVaccination ?? order.cat.vaccination,
      "appearance": catAppearance ?? order.cat.appearance,
      "gender": catGender ?? order.cat.gender,
      "image": (catImage == null)
          ? ((order.cat.image == null) ? null : base64Encode(order.cat.image!))
          : base64Encode(catImage),
      "species": catSpecies ?? order.cat.species,
      "weight": catWeight ?? order.cat.weight,
      "owner": owner == null ? order.cat.owner.toJson() : owner.toJson()
    });
  }

  Owner modifyOwner(
      {String? ownerName, String? ownerGender, String? ownerTel}) {
    return Owner.fromJson({
      "name": ownerName ?? order.cat.owner.name,
      "gender": ownerGender ?? order.cat.owner.gender,
      "tel": ownerTel ?? order.cat.owner.tel
    });
  }
}

class CheckinPageBloc extends Bloc<CheckinPageEvent, CheckinState> {
  CheckinPageBloc(Order order)
      : super(CheckinState(GlobalKey<FormState>(), GlobalKey<FormState>(),
            GlobalKey<FormState>(),
            order: order, currentStep: 1, renderState: RenderState.waiting)) {
    GetIt.I<InternalStorage>().expose("servicesList")?.listen((data) {
      if (data == null) add(RefreshEvent());
    });
    on<RequireDataEvent>((event, emit) async {
      await ServiceRelatedWorkProvider.getServicesList();
      emit(state.copyWith(renderState: RenderState.rendering));
    });
    on<NextStepEvent>((event, emit) async {
      if (state.currentStep == 0) {
        if (state.formKey1.currentState?.validate() != true) return;
        state.formKey1.currentState?.save();
        emit(state.copyWith(currentStep: 1));
      } else if (state.currentStep == 1) {
        if (state.formKey2.currentState?.validate() != true) return;
        state.formKey2.currentState?.save();
        emit(state.copyWith(currentStep: 2));
      } else if (state.currentStep == 2) {
        if (state.formKey3.currentState?.validate() != true) return;
        state.formKey3.currentState?.save();
        add(SubmitDataEvent(event.context));
      }
    });
    on<BackStepEvent>((event, emit) {
      if (state.currentStep == 1) {
        state.formKey2.currentState?.save();
        emit(state.copyWith(currentStep: 0));
      } else if (state.currentStep == 2) {
        state.formKey3.currentState?.save();
        emit(state.copyWith(currentStep: 1));
      }
    });
    on<PickImageEvent>((event, emit) async {
      emit(state.copyWith(
          order:
              state.modifyOrder(cat: state.modifyCat(catImage: event.bytes))));
    });
    on<CompleteRenderEvent>((event, emit) {
      emit(state.copyWith(renderState: RenderState.completed));
    });
    on<ModifyOwnerEvent>((event, emit) {
      emit(state.copyWith(
          order: state.modifyOrder(
              cat: state.modifyCat(
                  owner: state.modifyOwner(
                      ownerName: event.name,
                      ownerGender: event.gender,
                      ownerTel: event.tel)))));
    });
    on<ModifyCatEvent>((event, emit) {
      emit(state.copyWith(
        order: state.modifyOrder(
            cat: state.modifyCat(
                catAge: event.age,
                catName: event.name,
                catAppearance: event.appearance,
                catGender: event.gender,
                catImage: event.image,
                catPhysicalCondition: event.physicalCondition,
                catSpecies: event.species,
                catSterilization: event.sterilization,
                catVaccination: event.vaccination,
                catWeight: event.weight,
                catWeightRank: event.weightRank)),
      ));
    });
    on<ModifyOrderEvent>((event, emit) async {
      emit(state.copyWith(
          order: state.modifyOrder(
              additionsList: event.additionsList,
              orderAttention: event.attention,
              orderCheckIn: event.checkIn,
              orderCheckOut: event.checkOut,
              orderNote: event.note,
              eatingRank: event.eatingRank,
              roomID: event.roomID,
              subRoomNum: event.subRoomNum)));
    });
    on<SubmitDataEvent>((event, emit) async {
      DateTime now = DateTime.now();
      bool isSuccessed = false;
      List<Addition>? list;
      if (state.order.additionsList != null) {
        list = List.generate(state.order.additionsList!.length, (index) {
          if (state.order.additionsList![index].time == null) {
            if (GetIt.I<InternalStorage>()
                    .read("servicesList")
                    .firstWhere((element) =>
                        element.name ==
                        state.order.additionsList![index].serviceID)
                    .name ==
                "Trả mèo") {
              return Addition.fromJson({
                "service_id": state.order.additionsList![index].serviceID,
                "distance": state.order.additionsList![index].distance,
                "quantity": state.order.additionsList![index].quantity,
                "time": state.order.checkOut.toString()
              });
            }
            return Addition.fromJson({
              "service_id": state.order.additionsList![index].serviceID,
              "distance": state.order.additionsList![index].distance,
              "quantity": state.order.additionsList![index].quantity,
              "time": now.add(const Duration(minutes: 30)).toString()
            });
          }
          return state.order.additionsList![index];
        });
        emit(state.copyWith(
            order: state.modifyOrder(
          additionsList: list,
        )));
      }
      emit(state.copyWith(order: state.modifyOrder(orderCheckIn: now)));
      await InfoRelatedWorkProvider.checkin(state.order).then((res) async {
        if (jsonDecode(res.body)["errors"].length == 0) {
          await NoticeDialog.showMessageDialog(event.context,
              text: "Check-in thành công.");
          isSuccessed = true;
        } else {
          NoticeDialog.showErrDialog(event.context,
              errList: jsonDecode(res.body)["errors"],
              firstText: "Check-in thất bại.");
        }
      });
      if (isSuccessed) {
        HistoryRelatedWorkProvider.clearHistoriesList();
        CalendarRelatedWorkProvider.clearRoomGroupsList();
        await CalendarRelatedWorkProvider(
                currentMonth: DateTime(now.year, now.month),
                today: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day))
            .getRoomGroups();
        List<RoomGroup> roomGroupsList =
            GetIt.I<InternalStorage>().read("roomGroupsList");
        int newRidx = roomGroupsList.indexOf(roomGroupsList
            .firstWhere((element) => element.room.id == state.order.room.id));
        List<Order> ordersList = roomGroupsList[newRidx].ordersList;
        int newOidx = ordersList.indexOf(ordersList.firstWhere((element) {
          return element.date == state.order.date &&
              state.order.checkIn
                      .difference(element.checkIn)
                      .compareTo(const Duration(seconds: 1)) <
                  0 &&
              element.subRoomNum == state.order.subRoomNum &&
              element.room.id == state.order.room.id;
        }));
        // ignore: use_build_context_synchronously
        event.context.replace("/info",
            extra: {"ridx": newRidx.toString(), "oidx": newOidx.toString()});
      }
    });
    on<RefreshEvent>((event, emit) {
      emit(state.copyWith(
          order: order, currentStep: 0, renderState: RenderState.waiting));
    });
  }

  @override
  void onTransition(Transition<CheckinPageEvent, CheckinState> transition) {
    super.onTransition(transition);
  }
}
