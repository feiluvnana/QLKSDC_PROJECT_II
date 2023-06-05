import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../blocs/room_page_bloc.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/types/render_state.dart';

class RoomPage extends StatelessWidget {
  const RoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoomPageBloc(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 4,
            child:
                BlocBuilder<RoomPageBloc, RoomState>(builder: (context, state) {
              if (state.renderState == RenderState.waiting) {
                BlocProvider.of<RoomPageBloc>(context).add(RequireDataEvent());
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
                  () => BlocProvider.of<RoomPageBloc>(context)
                      .add(CompleteRenderEvent()));
              return Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Số phòng")),
                        DataColumn(label: Text("Sức chứa")),
                        DataColumn(label: Text("Đơn giá")),
                        DataColumn(label: Text("Loại phòng"))
                      ],
                      rows: List.generate(
                          GetIt.I<InternalStorage>()
                              .read("roomGroupsList")
                              .length,
                          (index) => DataRow(
                                  selected: state.currentIndexes
                                      .any((element) => element == index),
                                  onSelectChanged: (value) {
                                    if (value == null) return;
                                    if (value) {
                                      context
                                          .read<RoomPageBloc>()
                                          .add(ChooseRowEvent(index));
                                    } else {
                                      context
                                          .read<RoomPageBloc>()
                                          .add(UnchooseRowEvent(index));
                                    }
                                  },
                                  cells: [
                                    DataCell(Text(GetIt.I<InternalStorage>()
                                        .read("roomGroupsList")[index]
                                        .room
                                        .id)),
                                    DataCell(Text(GetIt.I<InternalStorage>()
                                        .read("roomGroupsList")[index]
                                        .room
                                        .total
                                        .toString())),
                                    DataCell(Text(GetIt.I<InternalStorage>()
                                        .read("roomGroupsList")[index]
                                        .room
                                        .price
                                        .toInt()
                                        .toString())),
                                    DataCell(Text(GetIt.I<InternalStorage>()
                                        .read("roomGroupsList")[index]
                                        .room
                                        .type)),
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
                        _.read<RoomPageBloc>().add(AddRoomEvent(_));
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
                      onPressed: () =>
                          {_.read<RoomPageBloc>().add(ModifyRoomEvent(_))},
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
                      onPressed: () =>
                          {_.read<RoomPageBloc>().add(DeleteRoomEvent(_))},
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
