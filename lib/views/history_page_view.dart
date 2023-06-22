import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../blocs/history_page_bloc.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/types/render_state.dart';
import 'package:flutter/services.dart' as sv;

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryPageBloc(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<HistoryPageBloc, HistoryState>(builder: (context, state) {
            if (state.renderState == RenderState.waiting) {
              BlocProvider.of<HistoryPageBloc>(context).add(RequireDataEvent());
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
                () => BlocProvider.of<HistoryPageBloc>(context)
                    .add(CompleteRenderEvent()));
            return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("STT")),
                      DataColumn(label: Text("Hành động")),
                      DataColumn(label: Text("Thời gian")),
                      DataColumn(label: Text("Người thực hiện")),
                      DataColumn(label: Text("Chi tiết"))
                    ],
                    rows: List.generate(
                        GetIt.I<InternalStorage>().read("historiesList").length,
                        (index) => DataRow(cells: [
                              DataCell(Text(GetIt.I<InternalStorage>()
                                  .read("historiesList")[index]
                                  .id
                                  .toString())),
                              DataCell(Text(GetIt.I<InternalStorage>()
                                  .read("historiesList")[index]
                                  .action)),
                              DataCell(Text(GetIt.I<InternalStorage>()
                                  .read("historiesList")[index]
                                  .time)),
                              DataCell(Text(GetIt.I<InternalStorage>()
                                  .read("historiesList")[index]
                                  .perfomer)),
                              DataCell(GestureDetector(
                                onTap: () async {
                                  await sv.Clipboard.setData(sv.ClipboardData(
                                      text: GetIt.I<InternalStorage>()
                                          .read("historiesList")[index]
                                          .details));
                                  // ignore: use_build_context_synchronously
                                  showBottomSheet(
                                      context: context,
                                      builder: (_) => BottomSheet(
                                            builder: (_) => Text(
                                                "Nội dung thay đổi ${GetIt.I<InternalStorage>().read("historiesList")[index].details}"),
                                            onClosing: () {},
                                          ));
                                },
                                child: Tooltip(
                                    message: GetIt.I<InternalStorage>()
                                        .read("historiesList")[index]
                                        .details,
                                    child: const Icon(Icons.info)),
                              )),
                            ])),
                  ),
                ));
          }),
        ],
      ),
    );
  }
}
