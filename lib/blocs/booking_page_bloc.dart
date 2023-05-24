import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:project_ii/data/providers/service_data_provider.dart';
import '../data/enums/RenderState.dart';
import '../data/providers/backend_data_provider.dart';
import '../data/providers/booking_provider.dart';
import '../model/AdditionModel.dart';
import '../model/CatModel.dart';
import '../model/OwnerModel.dart';
import '../model/OrderModel.dart';

abstract class BookingPageEvent {}

class NextStepEvent extends BookingPageEvent {}

class BackStepEvent extends BookingPageEvent {}

class PickImageEvent extends BookingPageEvent {
  final Uint8List? bytes;

  PickImageEvent(this.bytes);
}

class RequireDataEvent extends BookingPageEvent {}

class CompleteRenderEvent extends BookingPageEvent {}

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

class DataSubmittedEvent extends BookingPageEvent {}

class Step1State extends Equatable {
  final GlobalKey<FormState> formKey1;
  final Owner owner;

  const Step1State(this.formKey1, this.owner);

  @override
  List<Object?> get props => [owner];

  Step1State copyWith(
      {String? ownerName, String? ownerGender, String? ownerTel}) {
    return Step1State(
        formKey1,
        Owner.fromJson({
          "owner_name": ownerName ?? owner.name,
          "owner_gender": ownerGender ?? owner.gender,
          "owner_tel": ownerTel ?? owner.tel
        }));
  }
}

class Step2State extends Equatable {
  final GlobalKey<FormState> formKey2;
  final Cat cat;
  /*
  final String catName, catWeightRank, catAge, catPhysicalCondition;
  final String? catWeight, catGender, catAppearance, catSpecies;
  final int catSterilization, catVaccination;
  final Uint8List? catImage;*/

  const Step2State(this.formKey2, this.cat);

  @override
  List<Object?> get props => [cat];

  Step2State copyWith(
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
      Owner? owner,
      bool keepNullable = true}) {
    return (!keepNullable)
        ? Step2State(
            formKey2,
            Cat.fromJson({
              "cat_weight_rank": catWeightRank ?? cat.weightRank,
              "cat_name": catName ?? cat.name,
              "cat_age": catAge ?? cat.age,
              "cat_physical_condition":
                  catPhysicalCondition ?? cat.physicalCondition,
              "cat_sterilization": catSterilization ?? cat.sterilization,
              "cat_vaccination": catVaccination ?? cat.vaccination,
              "cat_appearance": cat.appearance,
              "cat_gender": cat.gender,
              "cat_image": (catImage == null) ? null : base64Encode(catImage),
              "cat_species": cat.species,
              "cat_weight": cat.weight,
            }, Owner.empty()))
        : Step2State(
            formKey2,
            Cat.fromJson({
              "cat_weight_rank": catWeightRank ?? cat.weightRank,
              "cat_name": catName ?? cat.name,
              "cat_age": catAge ?? cat.age,
              "cat_physical_condition":
                  catPhysicalCondition ?? cat.physicalCondition,
              "cat_sterilization": catSterilization ?? cat.sterilization,
              "cat_vaccination": catVaccination ?? cat.vaccination,
              "cat_appearance": catAppearance ?? cat.appearance,
              "cat_gender": catGender ?? cat.gender,
              "cat_image": (catImage == null)
                  ? ((cat.image == null) ? null : base64Encode(cat.image!))
                  : base64Encode(catImage),
              "cat_species": catSpecies ?? cat.species,
              "cat_weight": catWeight ?? cat.weight,
            }, Owner.empty()));
  }
}

class Step3State extends Equatable {
  final GlobalKey<FormState> formKey3;
  final Order order;

  const Step3State(this.formKey3, this.order);

  @override
  List<Object?> get props => [order];
  Future<Step3State> copyWith(
      {List<Addition>? additionsList,
      DateTime? orderCheckIn,
      DateTime? orderCheckOut,
      String? orderAttention,
      String? orderNote,
      String? roomID,
      int? subRoomNum,
      int? eatingRank,
      bool keepNullable = true}) async {
    return (!keepNullable)
        ? Step3State(
            formKey3,
            Order.fromJson(
                {
                  "order_date": DateTime.now().toString(),
                  "order_checkin": (orderCheckIn != null)
                      ? orderCheckIn.toString()
                      : order.checkIn.toString(),
                  "order_checkout": (orderCheckOut != null)
                      ? orderCheckOut.toString()
                      : order.checkOut.toString(),
                  "order_incharge": GetStorage().read("name"),
                  "order_subroom_num": subRoomNum ?? order.subRoomNum,
                  "order_eating_rank": eatingRank ?? order.eatingRank,
                  "order_attention": order.attention,
                  "order_note": order.note,
                  "additionsList": additionsList ?? order.additionsList
                },
                roomID == null
                    ? order.room
                    : await BackendDataProvider(
                            currentMonth: DateTime.now(), today: DateTime.now())
                        .getRoomFromID(roomID),
                Cat.empty()))
        : Step3State(
            formKey3,
            Order.fromJson(
                {
                  "order_date": DateTime.now().toString(),
                  "order_checkin": (orderCheckIn != null)
                      ? orderCheckIn.toString()
                      : order.checkIn.toString(),
                  "order_checkout": (orderCheckOut != null)
                      ? orderCheckOut.toString()
                      : order.checkOut.toString(),
                  "order_incharge": GetStorage().read("name"),
                  "order_subroom_num": subRoomNum ?? order.subRoomNum,
                  "order_eating_rank": eatingRank ?? order.eatingRank,
                  "order_attention": orderAttention ?? order.attention,
                  "order_note": orderNote ?? order.note,
                  "additionsList": additionsList ?? order.additionsList
                },
                roomID == null
                    ? order.room
                    : await BackendDataProvider(
                            currentMonth: DateTime.now(), today: DateTime.now())
                        .getRoomFromID(roomID),
                Cat.empty()));
  }
}

class BookingState extends Equatable {
  final Step1State step1State;
  final Step2State step2State;
  final Step3State step3State;
  final RenderState renderState;
  final int currentStep;

  const BookingState(
      {required this.step1State,
      required this.step2State,
      required this.step3State,
      required this.currentStep,
      required this.renderState});

  @override
  List<Object?> get props =>
      [step1State, step2State, step3State, currentStep, renderState];

  BookingState copyWith(
      {Step1State? step1State,
      Step2State? step2State,
      Step3State? step3State,
      int? currentStep,
      RenderState? renderState}) {
    return BookingState(
        step1State: step1State ?? this.step1State,
        step2State: step2State ?? this.step2State,
        step3State: step3State ?? this.step3State,
        currentStep: currentStep ?? this.currentStep,
        renderState: renderState ?? this.renderState);
  }
}

class BookingPageBloc extends Bloc<BookingPageEvent, BookingState> {
  BookingPageBloc()
      : super(BookingState(
            step1State: Step1State(GlobalKey<FormState>(), Owner.empty()),
            step2State: Step2State(GlobalKey<FormState>(), Cat.empty()),
            step3State: Step3State(GlobalKey<FormState>(), Order.empty()),
            currentStep: 0,
            renderState: RenderState.waiting)) {
    on<RequireDataEvent>((event, emit) async {
      await ServiceDataProvider.getServices();
      emit(state.copyWith(renderState: RenderState.rendering));
    });
    on<NextStepEvent>((event, emit) async {
      if (state.currentStep == 0) {
        if (state.step1State.formKey1.currentState?.validate() != true) return;
        state.step1State.formKey1.currentState?.save();
        emit(state.copyWith(currentStep: 1));
      } else if (state.currentStep == 1) {
        if (state.step2State.formKey2.currentState?.validate() != true) return;
        state.step2State.formKey2.currentState?.save();
        emit(state.copyWith(currentStep: 2));
      } else if (state.currentStep == 2) {
        if (state.step3State.formKey3.currentState?.validate() != true) return;
        state.step3State.formKey3.currentState?.save();
        add(DataSubmittedEvent());
      }
    });
    on<BackStepEvent>((event, emit) {
      if (state.currentStep == 1) {
        state.step2State.formKey2.currentState?.save();
        emit(state.copyWith(currentStep: 0));
      } else if (state.currentStep == 2) {
        state.step3State.formKey3.currentState?.save();
        emit(state.copyWith(currentStep: 1));
      }
    });
    on<PickImageEvent>((event, emit) async {
      emit(state.copyWith(
          step2State: state.step2State.copyWith(catImage: event.bytes)));
    });
    on<CompleteRenderEvent>((event, emit) {
      emit(state.copyWith(renderState: RenderState.completed));
    });
    on<ChangeStep1StateEvent>((event, emit) {
      emit(state.copyWith(
          step1State: state.step1State.copyWith(
              ownerName: event.name,
              ownerGender: event.gender,
              ownerTel: event.tel)));
    });
    on<ChangeStep2StateEvent>((event, emit) {
      emit(state.copyWith(
          step2State: state.step2State.copyWith(
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
              catWeightRank: event.weightRank)));
    });
    on<ChangeStep3StateEvent>((event, emit) async {
      emit(state.copyWith(
          step3State: await state.step3State.copyWith(
              additionsList: event.additionsList,
              orderAttention: event.attention,
              orderCheckIn: event.checkIn,
              orderCheckOut: event.checkOut,
              orderNote: event.note,
              eatingRank: event.eatingRank,
              roomID: event.roomID,
              subRoomNum: event.subRoomNum)));
    });
    on<DataSubmittedEvent>((event, emit) async {
      int ownerID = await BookingProvider.sendOwnerInfo(state.step1State.owner);
      int catID =
          await BookingProvider.sendCatInfo(state.step2State.cat, ownerID);
      print(await BookingProvider.sendOrderInfo(state.step3State.order, catID));
    });
  }

  @override
  void onTransition(Transition<BookingPageEvent, BookingState> transition) {
    super.onTransition(transition);
    print("[BookingPageBloc] $transition");
  }
}


  
/*
Future<void> sendDataToDatabase() async {
    int ownerID = jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setOwnerInfo.php",
            FormData({
              "sessionID": GetStorage().read("sessionID"),
              "ownerName": ownerNameController.text,
              "ownerTel": ownerTelController.text,
              "ownerGender": ownerGender
            })))
        .body)["owner_id"];
    int catID = jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setCatInfo.php",
            FormData({
              "sessionID": GetStorage().read("sessionID"),
              "ownerID": ownerID,
              "catName": catNameController.text,
              "catAge": catAgeController.text,
              "catImage": (catImage == null)
                  ? null
                  : base64Encode(catImage as List<int>),
              "catVaccination": catVaccination,
              "catSpecies": catSpeciesController.text == ""
                  ? null
                  : catSpeciesController.text,
              "catAppearance": catAppearanceController.text == ""
                  ? null
                  : catAppearanceController.text,
              "catSterilization": catSterilization,
              "catPhysicalCondition": catPhysicalConditionController.text,
              "catGender": catGender,
              "catWeight": catWeightController.text == ""
                  ? null
                  : catWeightController.text,
              "catWeightRank": catWeightRank
            })))
        .body)["cat_id"];
    String status = jsonDecode((await GetConnect().post(
            "http://localhost/php-crash/setOrderInfo.php",
            FormData({
              "sessionID": GetStorage().read("sessionID"),
              "catID": catID,
              "roomID": roomID,
              "subRoomNum": subRoomNum,
              "checkIn": orderCheckIn.toString(),
              "checkOut": orderCheckOut.toString(),
              "attention": orderAttentionController.text,
              "note": orderNoteController.text,
              "eatingRank": eatingRank,
              "inCharge": GetStorage().read("name"),
              "additionsList":
                  jsonEncode(List.generate(numberOfAdditions, (index) {
                List<Service> servicesList =
                    Get.find<InternalStorage>().read("servicesList");
                if (servicesList
                        .firstWhere(
                            (element) => element.id == additionsList[index])
                        .name ==
                    "Đón mèo") {
                  additionTimeList[index] = orderCheckIn;
                }
                if (servicesList
                        .firstWhere(
                            (element) => element.id == additionsList[index])
                        .name ==
                    "Trả mèo") {
                  additionTimeList[index] = orderCheckOut;
                }
                return {
                  "serviceID": servicesList
                      .firstWhere(
                          (element) => element.id == additionsList[index])
                      .id,
                  "additionTime": (additionTimeList[index] == null)
                      ? null
                      : additionTimeList[index].toString(),
                  "additionQuantity":
                      (additionQuantityController[index] == null)
                          ? null
                          : additionQuantityController[index]?.text,
                  "additionDistance":
                      (additionDistanceController[index] == null)
                          ? null
                          : additionDistanceController[index]?.text,
                };
              }))
            })))
        .body)["status"];
    await Get.defaultDialog(
      barrierDismissible: true,
      title: "Thông báo",
      content: Text((status != "successed")
          ? "Đặt phòng thất bại do có thể đã có khách đặt"
          : "Đặt phòng thành công"),
    ).then((value) => _isSubmitClicked = false);
    if (status == "successed") {
      await RoomGroupDataProvider(
              currentMonth: DateTime.now(), today: DateTime.now())
          .getRoomGroups();
    }
  }
  */
