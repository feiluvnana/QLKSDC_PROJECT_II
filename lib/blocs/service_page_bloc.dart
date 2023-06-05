import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:project_ii/utils/reusables/notice_dialog.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/types/render_state.dart';
import '../data/providers/history_related_work_provider.dart';
import '../data/providers/service_related_work_provider.dart';
import '../model/service_model.dart';
import '../utils/reusables/service_info_dialog.dart';

abstract class ServicePageEvent {}

class RequireDataEvent extends ServicePageEvent {}

class AddServiceEvent extends ServicePageEvent {
  final BuildContext context;

  AddServiceEvent(this.context);
}

class ModifyServiceEvent extends ServicePageEvent {
  final BuildContext context;

  ModifyServiceEvent(this.context);
}

class DeleteServiceEvent extends ServicePageEvent {
  final BuildContext context;

  DeleteServiceEvent(this.context);
}

class CompleteRenderEvent extends ServicePageEvent {}

class ChooseRowEvent extends ServicePageEvent {
  int index;

  ChooseRowEvent(this.index);
}

class UnchooseRowEvent extends ServicePageEvent {
  int index;

  UnchooseRowEvent(this.index);
}

class RefreshEvent extends ServicePageEvent {}

class ServiceState extends Equatable {
  final RenderState renderState;
  final Set<int> currentIndexes;

  const ServiceState({required this.renderState, required this.currentIndexes});

  ServiceState copyWith({RenderState? renderState, Set<int>? currentIndexes}) {
    return ServiceState(
        renderState: renderState ?? this.renderState,
        currentIndexes: currentIndexes ?? this.currentIndexes);
  }

  @override
  List<Object?> get props => [renderState, currentIndexes];
}

class ServicePageBloc extends Bloc<ServicePageEvent, ServiceState> {
  ServicePageBloc()
      : super(const ServiceState(
            renderState: RenderState.waiting, currentIndexes: <int>{})) {
    GetIt.I<InternalStorage>().expose("servicesList")?.listen((data) {
      if (data == null) add(RefreshEvent());
    });
    on<RequireDataEvent>((event, emit) async {
      await ServiceRelatedWorkProvider.getServicesList();
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
    on<AddServiceEvent>((event, emit) async {
      bool isSuccessed = false;
      await (ServiceInfoDialog(title: "Nhập thông tin dịch vụ")
          .showServiceInfoDialog(event.context)
          .then((service) async {
        if (service != null) {
          await ServiceRelatedWorkProvider.add(service).then((res) async {
            if (jsonDecode(res.body)["errors"].length == 0) {
              if (jsonDecode(res.body)["errors"].length == 0) {
                await NoticeDialog.showMessageDialog(event.context,
                    text: "Thêm dịch vụ thành công");
                isSuccessed = true;
              } else {
                NoticeDialog.showErrDialog(event.context,
                    errList: jsonDecode(res.body)["errors"],
                    firstText: "Thêm dịch vụ thất bại");
              }
            }
          });
        }
      }));
      if (isSuccessed) {
        ServiceRelatedWorkProvider.clearServicesList();
        HistoryRelatedWorkProvider.clearHistoriesList();
      }
    });
    on<ModifyServiceEvent>((event, emit) async {
      if (state.currentIndexes.isNotEmpty) {
        emit(state.copyWith(currentIndexes: <int>{state.currentIndexes.first}));
      } else {
        return;
      }
      bool isSuccessed = false;
      await (ServiceInfoDialog(
              initialValue: GetIt.I<InternalStorage>()
                  .read("servicesList")[state.currentIndexes.first],
              title:
                  "Nhập thông tin chỉnh sửa dịch vụ ${GetIt.I<InternalStorage>().read("servicesList")[state.currentIndexes.first].id}")
          .showServiceInfoDialog(event.context)
          .then((service) async {
        if (service != null) {
          await ServiceRelatedWorkProvider.modify(
                  service,
                  GetIt.I<InternalStorage>()
                      .read("servicesList")[state.currentIndexes.first])
              .then((res) async {
            if (jsonDecode(res.body)["errors"].length == 0) {
              await NoticeDialog.showMessageDialog(event.context,
                  text: "Sửa dịch vụ thành công");
              isSuccessed = true;
            } else {
              NoticeDialog.showErrDialog(event.context,
                  errList: jsonDecode(res.body)["errors"],
                  firstText: "Sửa dịch vụ thất bại");
            }
          });
        }
      }));
      if (isSuccessed) {
        ServiceRelatedWorkProvider.clearServicesList();
        HistoryRelatedWorkProvider.clearHistoriesList();
      }
    });
    on<DeleteServiceEvent>((event, emit) async {
      String notice = "";
      for (int element in state.currentIndexes) {
        Service service =
            GetIt.I<InternalStorage>().read("servicesList")[element];
        await ServiceRelatedWorkProvider.delete(service).then((res) async {
          if (jsonDecode(res.body)["errors"].length == 0) {
            notice += "Xoá dịch vụ ${service.id} thành công\n";
          } else {
            notice +=
                "Xoá dịch vụ ${service.id} thất bại (Mã lỗi: ${jsonDecode(res.body)["errors"]})\n";
          }
        });
      }
      NoticeDialog.showMessageDialog(event.context, text: notice);
      ServiceRelatedWorkProvider.clearServicesList();
      HistoryRelatedWorkProvider.clearHistoriesList();
    });
    on<RefreshEvent>((event, emit) {
      emit(state
          .copyWith(renderState: RenderState.waiting, currentIndexes: <int>{}));
    });
  }
}
