import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../blocs/service_page_bloc.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/enums/RenderState.dart';

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
                  const Duration(milliseconds: 100),
                  () => BlocProvider.of<ServicePageBloc>(context)
                      .add(CompleteRenderEvent()));
              return Padding(
                  padding: const EdgeInsets.all(20),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("STT")),
                      DataColumn(label: Text("Tên dịch vụ")),
                      DataColumn(label: Text("Đơn giá")),
                    ],
                    rows: List.generate(
                        GetIt.I<InternalStorage>().read("servicesList").length,
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
                                ])),
                  ));
            }),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(foregroundColor: Colors.black),
                    onPressed: () async {},
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
                    onPressed: () => {},
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
                    onPressed: () => {},
                    child: Container(
                      width: 50,
                      alignment: Alignment.center,
                      child: const Text("Xóa"),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
