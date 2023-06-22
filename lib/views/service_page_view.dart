import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../blocs/service_page_bloc.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/types/render_state.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServicePageBloc(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 4,
            child: BlocBuilder<ServicePageBloc, ServiceState>(
                builder: (context, state) {
              if (state.renderState == RenderState.waiting) {
                BlocProvider.of<ServicePageBloc>(context)
                    .add(RequireDataEvent());
                return const Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                      Text('Đang tải...'),
                    ],
                  ),
                );
              }
              Future.delayed(
                  Duration.zero,
                  () => BlocProvider.of<ServicePageBloc>(context)
                      .add(CompleteRenderEvent()));
              return Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Mã dịch vụ")),
                        DataColumn(label: Text("Tên dịch vụ")),
                        DataColumn(label: Text("Đơn giá")),
                        DataColumn(label: Text("Thông tin cần thiết"))
                      ],
                      rows: List.generate(
                          GetIt.I<InternalStorage>()
                              .read("servicesList")
                              .length,
                          (index) => DataRow(
                                  selected: state.currentIndexes
                                      .any((element) => element == index),
                                  onSelectChanged: (value) {
                                    if (value == null) return;
                                    if (value) {
                                      context
                                          .read<ServicePageBloc>()
                                          .add(ChooseRowEvent(index));
                                    } else {
                                      context
                                          .read<ServicePageBloc>()
                                          .add(UnchooseRowEvent(index));
                                    }
                                  },
                                  cells: [
                                    DataCell(Text(GetIt.I<InternalStorage>()
                                        .read("servicesList")[index]
                                        .id
                                        .toString())),
                                    DataCell(Text(GetIt.I<InternalStorage>()
                                        .read("servicesList")[index]
                                        .name)),
                                    DataCell(Text(GetIt.I<InternalStorage>()
                                        .read("servicesList")[index]
                                        .price
                                        .toInt()
                                        .toString())),
                                    DataCell(Text(
                                        "${GetIt.I<InternalStorage>().read("servicesList")[index].distanceNeed ? "Thông tin vị trí\n" : ""}${GetIt.I<InternalStorage>().read("servicesList")[index].timeNeed ? "Thời gian\n" : ""}${GetIt.I<InternalStorage>().read("servicesList")[index].quantityNeed ? "Số lượng\n" : ""}"))
                                  ])),
                    ),
                  ));
            }),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Builder(builder: (_) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black),
                      onPressed: () {
                        _.read<ServicePageBloc>().add(AddServiceEvent(_));
                      },
                      child: Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: const Text("Thêm"),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfffaf884),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        _.read<ServicePageBloc>().add(ModifyServiceEvent(_));
                      },
                      child: Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: const Text("Sửa"),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffff6961),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        _.read<ServicePageBloc>().add(DeleteServiceEvent(_));
                      },
                      child: Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: const Text("Xóa"),
                      ),
                    ),
                  ],
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
