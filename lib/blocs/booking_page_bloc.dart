import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:project_ii/data/dependencies/internal_storage.dart';
import 'package:project_ii/data/providers/service_related_work_provider.dart';
import 'package:project_ii/utils/reusables/notice_dialog.dart';
import '../data/providers/booking_related_work_provider.dart';
import '../data/providers/calendar_related_work_provider.dart';
import '../data/types/render_state.dart';
import '../data/providers/addition_model.dart';
import '../models/cat_model.dart';
import '../models/owner_model.dart';
import '../models/order_model.dart';

abstract class BookingPageEvent {}

class NextStepEvent extends BookingPageEvent {
  final BuildContext context;

  NextStepEvent(this.context);
}

class BackStepEvent extends BookingPageEvent {}

class RequireDataEvent extends BookingPageEvent {}

class CompleteRenderEvent extends BookingPageEvent {}

class RefreshEvent extends BookingPageEvent {}

class ModifyOwnerEvent extends BookingPageEvent {
  final String? name, tel, gender;

  ModifyOwnerEvent({this.name, this.tel, this.gender});
}

class ModifyOrderEvent extends BookingPageEvent {
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

class ModifyPickupEvent extends BookingPageEvent {
  final DateTime? pickupTime;
  final String? distance;

  ModifyPickupEvent({this.distance, this.pickupTime});
}

class TogglePickupEvent extends BookingPageEvent {}

class SubmitDataEvent extends BookingPageEvent {
  final BuildContext context;

  SubmitDataEvent(this.context);
}

class BookingState extends Equatable {
  final GlobalKey<FormState> formKey1, formKey2;
  final Order order;
  final RenderState renderState;
  final int currentStep;
  final bool isPickedup;
  final DateTime? pickupTime;
  final String? distance;

  const BookingState(this.formKey1, this.formKey2,
      {required this.order,
      required this.currentStep,
      required this.renderState,
      required this.isPickedup,
      this.pickupTime,
      this.distance});

  @override
  List<Object?> get props => [order, currentStep, renderState, isPickedup];

  BookingState copyWith(
      {Order? order,
      int? currentStep,
      RenderState? renderState,
      bool? isPickedup,
      DateTime? pickupTime,
      String? distance}) {
    return BookingState(formKey1, formKey2,
        order: order ?? this.order,
        currentStep: currentStep ?? this.currentStep,
        renderState: renderState ?? this.renderState,
        isPickedup: isPickedup ?? this.isPickedup,
        pickupTime: pickupTime ?? this.pickupTime,
        distance: distance ?? this.distance);
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
        "is_checkedout": order.isCheckedout ? 1 : 0,
        "is_checkedin": order.isCheckedin ? 1 : 0,
        "is_walkedin": order.isWalkedin ? 1 : 0,
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

class BookingPageBloc extends Bloc<BookingPageEvent, BookingState> {
  BookingPageBloc()
      : super(BookingState(GlobalKey<FormState>(), GlobalKey<FormState>(),
            order: Order.empty(),
            currentStep: 0,
            renderState: RenderState.waiting,
            isPickedup: false)) {
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
        add(SubmitDataEvent(event.context));
      }
    });
    on<BackStepEvent>((event, emit) {
      if (state.currentStep == 1) {
        state.formKey2.currentState?.save();
        emit(state.copyWith(currentStep: 0));
      }
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
    on<TogglePickupEvent>(
      (event, emit) => emit(state.copyWith(isPickedup: !state.isPickedup)),
    );
    on<SubmitDataEvent>((event, emit) async {
      bool isSuccessed = false;
      List<Addition>? list;
      if (state.isPickedup) {
        int id = GetIt.I<InternalStorage>()
            .read("servicesList")
            .firstWhere((element) => "Đón mèo" == element.name)
            .id;

        list = [
          Addition.fromJson({
            "service_id": id,
            "distance": state.distance,
            "quantity": null,
            "time": state.pickupTime
          })
        ];

        emit(state.copyWith(
            order: state.modifyOrder(
          additionsList: list,
        )));
      }
      await BookingRelatedWorkProvider.sendOrderInfo(state.order)
          .then((res) async {
        if (jsonDecode(res.body)["errors"].length == 0) {
          NoticeDialog.showMessageDialog(event.context,
              text: "Đặt phòng thành công.");
          isSuccessed = true;
        } else {
          NoticeDialog.showErrDialog(event.context,
              errList: jsonDecode(res.body)["errors"],
              firstText: "Đặt phòng thất bại.");
        }
      });
      if (isSuccessed) CalendarRelatedWorkProvider.clearRoomGroupsList();
    });
    on<RefreshEvent>((event, emit) {
      emit(state.copyWith(
          order: Order.empty(true),
          currentStep: 0,
          renderState: RenderState.waiting));
    });
  }

  @override
  void onTransition(Transition<BookingPageEvent, BookingState> transition) {
    super.onTransition(transition);
  }
}
