import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:project_ii/data/providers/info_related_work_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/providers/calendar_related_work_provider.dart';
import '../model/CatModel.dart';
import '../model/OrderModel.dart';
import '../model/AdditionModel.dart';
import '../model/OwnerModel.dart';
import '../model/RoomGroupModel.dart';

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

class SaveChangesEvent extends InformationPageEvent {}

class CancelOrderEvent extends InformationPageEvent {}

class CheckoutEvent extends InformationPageEvent {}

class GotoHomePage extends InformationPageEvent {
  final BuildContext context;

  GotoHomePage(this.context);
}

class InformationState extends Equatable {
  final GlobalKey<FormState> formKey1, formKey2, formKey3, formKey4;
  final bool isEditing1, isEditing2, isEditing3, isEditing4;
  final Order modifiedOrder, order;

  const InformationState(
      this.formKey1, this.formKey2, this.formKey3, this.formKey4,
      {required this.isEditing1,
      required this.isEditing2,
      required this.isEditing3,
      required this.isEditing4,
      required this.modifiedOrder,
      required this.order});

  InformationState copyWith({
    bool? isEditing1,
    bool? isEditing2,
    bool? isEditing3,
    bool? isEditing4,
    Order? order,
  }) {
    return InformationState(formKey1, formKey2, formKey3, formKey4,
        isEditing1: isEditing1 ?? this.isEditing1,
        isEditing2: isEditing2 ?? this.isEditing2,
        isEditing3: isEditing3 ?? this.isEditing3,
        isEditing4: isEditing4 ?? this.isEditing4,
        modifiedOrder: order ?? modifiedOrder,
        order: this.order);
  }

  Future<Order> modifyOrder(
      {List<Addition>? additionsList,
      DateTime? orderCheckIn,
      DateTime? orderCheckOut,
      String? orderAttention,
      String? orderNote,
      String? roomID,
      int? subRoomNum,
      int? eatingRank,
      Cat? cat}) async {
    return Order.fromJson(
        {
          "order_date": DateTime.now().toString(),
          "order_checkin": (orderCheckIn != null)
              ? orderCheckIn.toString()
              : modifiedOrder.checkIn.toString(),
          "order_checkout": (orderCheckOut != null)
              ? orderCheckOut.toString()
              : modifiedOrder.checkOut.toString(),
          "order_incharge":
              (await SharedPreferences.getInstance()).getString("name"),
          "order_subroom_num": subRoomNum ?? modifiedOrder.subRoomNum,
          "order_eating_rank": eatingRank ?? modifiedOrder.eatingRank,
          "order_attention": orderAttention ?? modifiedOrder.attention,
          "order_note": orderNote ?? modifiedOrder.note,
          "additionsList": additionsList ?? modifiedOrder.additionsList
        },
        roomID == null
            ? modifiedOrder.room
            : await CalendarRelatedWorkProvider(
                    currentMonth: DateTime.now(), today: DateTime.now())
                .getRoomFromID(roomID),
        cat ?? order.cat);
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
      "cat_weight_rank": catWeightRank ?? modifiedOrder.cat.weightRank,
      "cat_name": catName ?? modifiedOrder.cat.name,
      "cat_age": catAge ?? modifiedOrder.cat.age,
      "cat_physical_condition":
          catPhysicalCondition ?? modifiedOrder.cat.physicalCondition,
      "cat_sterilization": catSterilization ?? modifiedOrder.cat.sterilization,
      "cat_vaccination": catVaccination ?? modifiedOrder.cat.vaccination,
      "cat_appearance": catAppearance ?? modifiedOrder.cat.appearance,
      "cat_gender": catGender ?? modifiedOrder.cat.gender,
      "cat_image": (catImage == null)
          ? ((modifiedOrder.cat.image == null)
              ? null
              : base64Encode(modifiedOrder.cat.image!))
          : base64Encode(catImage),
      "cat_species": catSpecies ?? modifiedOrder.cat.species,
      "cat_weight": catWeight ?? modifiedOrder.cat.weight,
    }, owner ?? modifiedOrder.cat.owner);
  }

  Owner modifyOwner(
      {String? ownerName, String? ownerGender, String? ownerTel}) {
    return Owner.fromJson({
      "owner_name": ownerName ?? modifiedOrder.cat.owner.name,
      "owner_gender": ownerGender ?? modifiedOrder.cat.owner.gender,
      "owner_tel": ownerTel ?? modifiedOrder.cat.owner.tel
    });
  }

  @override
  List<Object?> get props =>
      [modifiedOrder, isEditing1, isEditing2, isEditing3, isEditing4];
}

class InformationPageBloc extends Bloc<InformationPageEvent, InformationState> {
  final int ridx, oidx;
  InformationPageBloc(this.ridx, this.oidx)
      : super(InformationState(GlobalKey<FormState>(), GlobalKey<FormState>(),
            GlobalKey<FormState>(), GlobalKey<FormState>(),
            isEditing1: false,
            isEditing2: false,
            isEditing3: false,
            isEditing4: false,
            modifiedOrder: (GetIt.I<InternalStorage>()
                    .read("roomGroupsList")[ridx] as RoomGroup)
                .ordersList[oidx],
            order: (GetIt.I<InternalStorage>().read("roomGroupsList")[ridx]
                    as RoomGroup)
                .ordersList[oidx])) {
    on<ToggleModifyCatEvent>(
        (event, emit) => emit(state.copyWith(isEditing1: !(state.isEditing1))));
    on<ToggleModifyOwnerEvent>(
        (event, emit) => emit(state.copyWith(isEditing2: !(state.isEditing2))));
    on<ToggleModifyOrderEvent>(
        (event, emit) => emit(state.copyWith(isEditing3: !(state.isEditing3))));
    on<ModifyCatEvent>(
      (event, emit) async {
        emit(state.copyWith(
            order: await state.modifyOrder(
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
    on<ModifyOwnerEvent>((event, emit) async {
      emit(state.copyWith(
          order: await state.modifyOrder(
              cat: state.modifyCat(
                  owner: state.modifyOwner(
                      ownerGender: event.gender,
                      ownerName: event.name,
                      ownerTel: event.tel)))));
    });
    on<ModifyOrderEvent>((event, emit) async {
      emit(state.copyWith(
          order: await state.modifyOrder(
              additionsList: event.additionsList,
              orderAttention: event.attention,
              orderCheckIn: event.checkIn,
              orderCheckOut: event.checkOut,
              orderNote: event.note,
              subRoomNum: event.subRoomNum,
              eatingRank: event.eatingRank,
              roomID: event.roomID)));
    });
    on<GotoHomePage>((event, emit) => event.context.go("/home"));
    on<SaveChangesEvent>((event, emit) {
      print("fired");
      InfoRelatedWorkProvider.saveChanges(state.modifiedOrder, state.order);
    });
    on<CancelOrderEvent>((event, emit) {});
    on<CheckoutEvent>((event, emit) {});
  }

  @override
  void onTransition(
      Transition<InformationPageEvent, InformationState> transition) {
    super.onTransition(transition);
    print("[InformationPageBloc] $transition");
  }
}
