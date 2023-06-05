import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:project_ii/data/dependencies/internal_storage.dart';
import 'package:project_ii/data/providers/service_related_work_provider.dart';
import 'package:project_ii/utils/reusables/notice_dialog.dart';
import '../data/providers/calendar_related_work_provider.dart';
import '../data/types/render_state.dart';
import '../data/providers/booking_related_work_provider.dart';
import '../model/addition_model.dart';
import '../model/cat_model.dart';
import '../model/owner_model.dart';
import '../model/order_model.dart';

abstract class BookingPageEvent {}

class NextStepEvent extends BookingPageEvent {
  final BuildContext context;

  NextStepEvent(this.context);
}

class BackStepEvent extends BookingPageEvent {}

class PickImageEvent extends BookingPageEvent {
  final Uint8List? bytes;

  PickImageEvent(this.bytes);
}

class RequireDataEvent extends BookingPageEvent {}

class CompleteRenderEvent extends BookingPageEvent {}

class RefreshEvent extends BookingPageEvent {}

class ChangeStep1StateEvent extends BookingPageEvent {
  final String? name, tel, gender;

  ChangeStep1StateEvent({this.name, this.tel, this.gender});
}

class ChangeStep2StateEvent extends BookingPageEvent {
  final String? weightRank,
      name,
      species,
      physicalCondition,
      appearance,
      gender;
  final Uint8List? image;
  final int? age, sterilization, vaccination;
  final double? weight;

  ChangeStep2StateEvent(
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

class ChangeStep3StateEvent extends BookingPageEvent {
  final List<Addition>? additionsList;
  final DateTime? checkIn, checkOut;
  final String? attention, note;
  final String? roomID;
  final int? eatingRank, subRoomNum;

  ChangeStep3StateEvent(
      {this.additionsList,
      this.checkIn,
      this.checkOut,
      this.attention,
      this.note,
      this.roomID,
      this.eatingRank,
      this.subRoomNum});
}

class SubmitDataEvent extends BookingPageEvent {
  final BuildContext context;

  SubmitDataEvent(this.context);
}

class BookingState extends Equatable {
  final GlobalKey<FormState> formKey1, formKey2, formKey3;
  final Order order;
  final RenderState renderState;
  final int currentStep;

  const BookingState(this.formKey1, this.formKey2, this.formKey3,
      {required this.order,
      required this.currentStep,
      required this.renderState});

  @override
  List<Object?> get props => [order, currentStep, renderState];

  BookingState copyWith(
      {Order? order, int? currentStep, RenderState? renderState}) {
    return BookingState(formKey1, formKey2, formKey3,
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
        "additions_list": jsonDecode(jsonEncode((additionsList != null)
            ? List.generate(
                additionsList.length, (index) => additionsList[index].toJson())
            : List.generate(order.additionsList?.length ?? 0,
                (index) => order.additionsList![index].toJson()))),
        "room": roomID == null
            ? order.room.toJson()
            : GetIt.I<InternalStorage>()
                .read("roomGroupsList")
                .firstWhere((element) => element.room.id == roomID)
                .room
                .toJson(),
        "cat": cat == null ? order.cat.toJson() : cat.toJson()
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
            GlobalKey<FormState>(),
            order: Order.empty(),
            currentStep: 0,
            renderState: RenderState.waiting)) {
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
    on<ChangeStep1StateEvent>((event, emit) {
      emit(state.copyWith(
          order: state.modifyOrder(
              cat: state.modifyCat(
                  owner: state.modifyOwner(
                      ownerName: event.name,
                      ownerGender: event.gender,
                      ownerTel: event.tel)))));
    });
    on<ChangeStep2StateEvent>((event, emit) {
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
    on<ChangeStep3StateEvent>((event, emit) async {
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
      bool isSuccessed = false;
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
          order: Order.empty(),
          currentStep: 0,
          renderState: RenderState.waiting));
    });
  }

  @override
  void onTransition(Transition<BookingPageEvent, BookingState> transition) {
    super.onTransition(transition);
    print("[BookingPageBloc] $transition");
  }
}
