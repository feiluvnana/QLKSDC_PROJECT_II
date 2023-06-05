import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:project_ii/data/providers/calendar_related_work_provider.dart';
import 'package:project_ii/data/providers/history_related_work_provider.dart';
import 'package:project_ii/utils/reusables/notice_dialog.dart';
import 'package:project_ii/utils/reusables/room_info_dialog.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/types/render_state.dart';
import '../data/providers/room_related_work_provider.dart';
import '../model/room_model.dart';

abstract class RoomPageEvent {}

class RequireDataEvent extends RoomPageEvent {}

class AddRoomEvent extends RoomPageEvent {
  final BuildContext context;

  AddRoomEvent(this.context);
}

class ModifyRoomEvent extends RoomPageEvent {
  final BuildContext context;

  ModifyRoomEvent(this.context);
}

class DeleteRoomEvent extends RoomPageEvent {
  final BuildContext context;

  DeleteRoomEvent(this.context);
}

class CompleteRenderEvent extends RoomPageEvent {}

class ChooseRowEvent extends RoomPageEvent {
  int index;

  ChooseRowEvent(this.index);
}

class UnchooseRowEvent extends RoomPageEvent {
  int index;

  UnchooseRowEvent(this.index);
}

class RefreshEvent extends RoomPageEvent {}

class RoomState extends Equatable {
  final RenderState renderState;
  final Set<int> currentIndexes;

  const RoomState({required this.renderState, required this.currentIndexes});

  RoomState copyWith({RenderState? renderState, Set<int>? currentIndexes}) {
    return RoomState(
        renderState: renderState ?? this.renderState,
        currentIndexes: currentIndexes ?? this.currentIndexes);
  }

  @override
  List<Object?> get props => [renderState, currentIndexes];
}

class RoomPageBloc extends Bloc<RoomPageEvent, RoomState> {
  RoomPageBloc()
      : super(const RoomState(
            renderState: RenderState.waiting, currentIndexes: <int>{})) {
    GetIt.I<InternalStorage>().expose("roomGroupsList")?.listen((data) {
      if (data == null) add(RefreshEvent());
    });
    on<RequireDataEvent>((event, emit) async {
      await CalendarRelatedWorkProvider(
              currentMonth: DateTime(DateTime.now().year, DateTime.now().month),
              today: DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day))
          .getRoomGroups();
      emit(state.copyWith(renderState: RenderState.rendering));
    });
    on<CompleteRenderEvent>((event, emit) {
      emit(state.copyWith(renderState: RenderState.completed));
    });
    on<ChooseRowEvent>((event, emit) {
      Set<int> newIndexes = state.currentIndexes.toSet();
      newIndexes.add(event.index);
      emit(state.copyWith(currentIndexes: newIndexes));
    });
    on<UnchooseRowEvent>((event, emit) {
      Set<int> newIndexes = state.currentIndexes.toSet();
      newIndexes.remove(event.index);
      emit(state.copyWith(currentIndexes: newIndexes));
    });
    on<AddRoomEvent>((event, emit) async {
      bool isSuccessed = false;
      await (RoomInfoDialog(title: "Nhập thông tin phòng")
          .showRoomInfoDialog(event.context)
          .then((room) async {
        if (room != null) {
          await RoomRelatedWorkProvider.add(room).then((res) async {
            if (jsonDecode(res.body)["errors"].length == 0) {
              await NoticeDialog.showMessageDialog(event.context,
                  text: "Thêm phòng thành công");
              isSuccessed = true;
            } else {
              NoticeDialog.showErrDialog(event.context,
                  errList: jsonDecode(res.body)["errors"],
                  firstText: "Thêm phòng thất bại");
            }
          });
        }
      }));
      if (isSuccessed) {
        CalendarRelatedWorkProvider.clearRoomGroupsList();
        HistoryRelatedWorkProvider.clearHistoriesList();
      }
    });
    on<ModifyRoomEvent>((event, emit) async {
      if (state.currentIndexes.isNotEmpty) {
        emit(state.copyWith(currentIndexes: <int>{state.currentIndexes.first}));
      } else {
        return;
      }
      bool isSuccessed = false;
      await (RoomInfoDialog(
              initialValue: GetIt.I<InternalStorage>()
                  .read("roomGroupsList")[state.currentIndexes.first]
                  .room,
              title:
                  "Nhập thông tin chỉnh sửa phòng ${GetIt.I<InternalStorage>().read("roomGroupsList")[state.currentIndexes.first].room.id}")
          .showRoomInfoDialog(event.context)
          .then((room) async {
        if (room != null) {
          await RoomRelatedWorkProvider.modify(
                  room,
                  GetIt.I<InternalStorage>()
                      .read("roomGroupsList")[state.currentIndexes.first]
                      .room)
              .then((res) async {
            if (jsonDecode(res.body)["errors"].length == 0) {
              await NoticeDialog.showMessageDialog(event.context,
                  text: "Sửa phòng thành công");
              isSuccessed = true;
            } else {
              NoticeDialog.showErrDialog(event.context,
                  errList: jsonDecode(res.body)["errors"],
                  firstText: "Sửa phòng thất bại");
            }
          });
        }
      }));
      if (isSuccessed) {
        CalendarRelatedWorkProvider.clearRoomGroupsList();
        HistoryRelatedWorkProvider.clearHistoriesList();
      }
    });
    on<DeleteRoomEvent>((event, emit) async {
      String notice = "";
      for (int element in state.currentIndexes) {
        Room room =
            GetIt.I<InternalStorage>().read("roomGroupsList")[element].room;
        await RoomRelatedWorkProvider.delete(room).then((res) async {
          if (jsonDecode(res.body)["errors"].length == 0) {
            notice += "Xoá phòng ${room.id} thành công\n";
          } else {
            notice +=
                "Xoá phòng ${room.id} thất bại (Mã lỗi: ${jsonDecode(res.body)["errors"]})\n";
          }
        });
      }
      NoticeDialog.showMessageDialog(event.context, text: notice);
      CalendarRelatedWorkProvider.clearRoomGroupsList();
      HistoryRelatedWorkProvider.clearHistoriesList();
    });
    on<RefreshEvent>((event, emit) {
      emit(state
          .copyWith(renderState: RenderState.waiting, currentIndexes: <int>{}));
    });
  }

  @override
  void onTransition(Transition<RoomPageEvent, RoomState> transition) {
    super.onTransition(transition);
    print("[RoomPageBloc] $transition");
  }
}
