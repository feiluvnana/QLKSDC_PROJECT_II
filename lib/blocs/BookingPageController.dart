import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:project_ii/data/providers/service_data_provider.dart';
import '../data/enums/RenderState.dart';
import '../model/CatModel.dart';
import '../model/OwnerModel.dart';

abstract class BookingPageEvent {}

class NextStepEvent extends BookingPageEvent {}

class BackStepEvent extends BookingPageEvent {}

class PickImageEvent extends BookingPageEvent {}

class RequireDataEvent extends BookingPageEvent {}

class CompleteRenderEvent extends BookingPageEvent {}

class ChangeStep1StateEvent extends BookingPageEvent {
  final String? name, tel, gender;

  ChangeStep1StateEvent({this.name, this.tel, this.gender});
}

class DataSubmittedEvent extends BookingPageEvent {}

class Step1State extends Equatable {
  final GlobalKey<FormState> formKey1 = GlobalKey();
  final Owner owner;

  Step1State(this.owner);

  @override
  List<Object?> get props => [owner];

  Step1State copyWith(
      {String? ownerName, String? ownerGender, String? ownerTel}) {
    return Step1State(Owner.fromJson({
      "ownerID": -1,
      "ownerName": ownerName ?? owner.name,
      "ownerGender": ownerGender ?? owner.gender,
      "ownerTel": ownerTel ?? owner.tel
    }));
  }
}

class Step2State extends Equatable {
  final GlobalKey<FormState> formKey2 = GlobalKey();
  final Cat cat;
  /*
  final String catName, catWeightRank, catAge, catPhysicalCondition;
  final String? catWeight, catGender, catAppearance, catSpecies;
  final int catSterilization, catVaccination;
  final Uint8List? catImage;*/

  Step2State(this.cat);

  @override
  List<Object?> get props => [cat];

  Step2State copyWith(
      {String? catName,
      String? catWeightRank,
      String? catAge,
      String? catPhysicalCondition,
      String? catWeight,
      String? catGender,
      String? catAppearance,
      String? catSpecies,
      int? catSterilization,
      int? catVaccination,
      Uint8List? catImage,
      Owner? owner,
      bool keepNullable = true}) {
    return (!keepNullable)
        ? Step2State(Cat.fromJson({
            "catID": -1,
            "catWeightRank": catWeightRank ?? cat.weightRank,
            "catName": catName ?? cat.name,
            "catAge": catAge ?? cat.age,
            "catPhysicalCondition":
                catPhysicalCondition ?? cat.physicalCondition,
            "catSterilization": catSterilization ?? cat.sterilization,
            "catVaccination": catVaccination ?? cat.vaccination,
            "catAppearance": cat.appearance,
            "catGender": cat.gender,
            "catImage": cat.image,
            "catSpecies": cat.species,
            "catWeight": cat.weight,
            "owner": owner?.toJson() ?? cat.owner.toJson()
          }))
        : Step2State(Cat.fromJson({
            "catID": -1,
            "catWeightRank": catWeightRank ?? cat.weightRank,
            "catName": catName ?? cat.name,
            "catAge": catAge ?? cat.age,
            "catPhysicalCondition":
                catPhysicalCondition ?? cat.physicalCondition,
            "catSterilization": catSterilization ?? cat.sterilization,
            "catVaccination": catVaccination ?? cat.vaccination,
            "catAppearance": catAppearance ?? cat.appearance,
            "catGender": catGender ?? cat.gender,
            "catImage": catImage ?? cat.image,
            "catSpecies": catSpecies ?? cat.species,
            "catWeight": catWeight ?? cat.weight,
            "owner": owner?.toJson() ?? cat.owner.toJson()
          }));
  }
}

class AdditionState extends Equatable {
  final List<int> additionsList;
  final List<DateTime?> additionTimesList;
  final List<int?> additionQuantitiesList;
  final List<String?> additionDistancesList;

  @override
  List<Object?> get props => [
        additionDistancesList,
        additionQuantitiesList,
        additionsList,
        additionTimesList
      ];

  const AdditionState(
      {required this.additionsList,
      required this.additionTimesList,
      required this.additionQuantitiesList,
      required this.additionDistancesList});

  AdditionState copyWith(
      {List<int>? additionsList,
      List<DateTime?>? additionTimesList,
      List<int?>? additionQuantitiesList,
      List<String?>? additionDistancesList}) {
    return AdditionState(
        additionsList: additionsList ?? this.additionsList,
        additionTimesList: additionTimesList ?? this.additionTimesList,
        additionQuantitiesList:
            additionQuantitiesList ?? this.additionQuantitiesList,
        additionDistancesList:
            additionDistancesList ?? this.additionDistancesList);
  }
}

class Step3State extends Equatable {
  final GlobalKey<FormState> formKey3 = GlobalKey();
  final DateTime orderCheckIn, orderCheckOut;
  final String roomID;
  final String? orderNote, orderAttention;
  final int subRoomNum, numberOfAdditions, eatingRank;
  final AdditionState additionStates;

  Step3State(
      {required this.additionStates,
      required this.orderCheckIn,
      required this.orderCheckOut,
      this.orderAttention,
      this.orderNote,
      required this.roomID,
      required this.subRoomNum,
      required this.numberOfAdditions,
      required this.eatingRank});

  @override
  List<Object?> get props => [
        additionStates,
        orderCheckIn,
        orderCheckOut,
        orderAttention,
        orderNote,
        roomID,
        subRoomNum,
        numberOfAdditions,
        eatingRank
      ];
  Step3State copyWith(
      {AdditionState? additionStates,
      DateTime? orderCheckIn,
      DateTime? orderCheckOut,
      String? orderAttention,
      String? orderNote,
      String? roomID,
      int? subRoomNum,
      int? numberOfAdditions,
      int? eatingRank,
      bool keepNullable = true}) {
    return (!keepNullable)
        ? Step3State(
            additionStates: additionStates ?? this.additionStates,
            orderCheckIn: orderCheckIn ?? this.orderCheckIn,
            orderCheckOut: orderCheckOut ?? this.orderCheckOut,
            roomID: roomID ?? this.roomID,
            subRoomNum: subRoomNum ?? this.subRoomNum,
            numberOfAdditions: numberOfAdditions ?? this.subRoomNum,
            eatingRank: eatingRank ?? this.eatingRank,
            orderAttention: orderAttention,
            orderNote: orderNote)
        : Step3State(
            additionStates: additionStates ?? this.additionStates,
            orderCheckIn: orderCheckIn ?? this.orderCheckIn,
            orderCheckOut: orderCheckOut ?? this.orderCheckOut,
            roomID: roomID ?? this.roomID,
            subRoomNum: subRoomNum ?? this.subRoomNum,
            numberOfAdditions: numberOfAdditions ?? this.subRoomNum,
            eatingRank: eatingRank ?? this.eatingRank,
            orderAttention: orderAttention ?? this.orderAttention,
            orderNote: orderNote ?? this.orderNote);
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
  List<Object?> get props => [step1State, step2State, step3State, currentStep];

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
            step1State: Step1State(Owner.fromJson({
              "ownerID": -1,
              "ownerName": "",
              "ownerGender": "",
              "ownerTel": ""
            })),
            step2State: Step2State(Cat.fromJson({
              "catID": -1,
              "catWeightRank": "",
              "catName": "",
              "catAge": -1,
              "catPhysicalCondition": "",
              "catSterilization": -1,
              "catVaccination": -1,
              "owner": {
                "ownerID": -1,
                "ownerName": "",
                "ownerGender": "",
                "ownerTel": ""
              }
            })),
            step3State: Step3State(
                additionStates: const AdditionState(
                    additionsList: [],
                    additionTimesList: [],
                    additionQuantitiesList: [],
                    additionDistancesList: []),
                orderCheckIn: DateTime.now(),
                orderCheckOut: DateTime.now(),
                roomID: "",
                subRoomNum: -1,
                numberOfAdditions: 0,
                eatingRank: -1),
            currentStep: 0,
            renderState: RenderState.waiting)) {
    on<RequireDataEvent>((event, emit) async {
      await ServiceDataProvider().getServices();
      emit(state.copyWith(renderState: RenderState.rendering));
    });
    on<NextStepEvent>((event, emit) {
      if (state.step1State.formKey1.currentState?.validate() != true ||
          state.step2State.formKey2.currentState?.validate() != true ||
          state.step3State.formKey3.currentState?.validate() != true) {
        emit(state.copyWith(renderState: RenderState.rendering));
      } else if (state.currentStep < 2) {
        emit(state.copyWith(
            currentStep: state.currentStep + 1,
            renderState: RenderState.rendering));
      }
    });
    on<BackStepEvent>((event, emit) {
      if (state.currentStep > 0) {
        emit(state.copyWith(
            currentStep: state.currentStep - 1,
            renderState: RenderState.rendering));
      }
    });
    on<PickImageEvent>((event, emit) => null);
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
