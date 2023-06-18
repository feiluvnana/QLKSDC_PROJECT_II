import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../blocs/statistic_page_bloc.dart';
import '../data/dependencies/internal_storage.dart';
import '../data/types/render_state.dart';
import '../model/statistic_model.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatisticPageBloc(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<StatisticPageBloc, StatisticState>(
              builder: (context, state) {
            if (state.renderState == RenderState.waiting) {
              BlocProvider.of<StatisticPageBloc>(context)
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
                () => BlocProvider.of<StatisticPageBloc>(context)
                    .add(CompleteRenderEvent()));
            return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 3 * 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: SfCartesianChart(
                                          title: ChartTitle(
                                              text:
                                                  "Tương quan tiền phòng và tiền dịch vụ"),
                                          primaryXAxis: CategoryAxis(
                                              title:
                                                  AxisTitle(text: "Mã phòng")),
                                          primaryYAxis: NumericAxis(
                                              title: AxisTitle(
                                                  text: "Số tiền (đồng)"),
                                              numberFormat:
                                                  NumberFormat.currency(
                                                      locale: "vi_VN",
                                                      decimalDigits: 0,
                                                      customPattern: "#,##0k")),
                                          tooltipBehavior:
                                              TooltipBehavior(enable: true),
                                          legend: Legend(isVisible: true),
                                          series: [
                                            StackedColumnSeries<RoomIncome,
                                                    String>(
                                                name: "Tiền phòng",
                                                enableTooltip: true,
                                                dataSource: (GetIt.I<
                                                                InternalStorage>()
                                                            .read("statistic")
                                                        as Statistic)
                                                    .roomIncome,
                                                xValueMapper: (ri, _) =>
                                                    ri.roomID,
                                                yValueMapper: (ri, _) =>
                                                    ri.room / 1000),
                                            StackedColumnSeries<RoomIncome,
                                                    String>(
                                                name: "Tiền dịch vụ",
                                                dataSource: (GetIt.I<
                                                                InternalStorage>()
                                                            .read("statistic")
                                                        as Statistic)
                                                    .roomIncome,
                                                xValueMapper: (ri, _) =>
                                                    ri.roomID,
                                                yValueMapper: (ri, _) =>
                                                    ri.service / 1000),
                                          ]))),
                              Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: SfCartesianChart(
                                          title: ChartTitle(
                                              text:
                                                  "Tương quan số đơn đã thanh toán và tổng số đơn"),
                                          primaryXAxis: CategoryAxis(
                                              title:
                                                  AxisTitle(text: "Mã phòng")),
                                          primaryYAxis: NumericAxis(
                                              title: AxisTitle(text: "Số đơn")),
                                          legend: Legend(isVisible: true),
                                          series: [
                                            ColumnSeries<Map<String, int>,
                                                    String>(
                                                name: "Đơn đã thanh toán",
                                                dataLabelSettings:
                                                    const DataLabelSettings(
                                                        isVisible: true),
                                                dataSource: List.generate(
                                                    (GetIt.I<InternalStorage>()
                                                                .read(
                                                                    "statistic")
                                                            as Statistic)
                                                        .roomIncome
                                                        .length, (index) {
                                                  var statistic = (GetIt.I<
                                                              InternalStorage>()
                                                          .read("statistic")
                                                      as Statistic);
                                                  var roomID = statistic
                                                      .allOrderNum.keys
                                                      .elementAt(index);
                                                  RoomIncome? ri;
                                                  try {
                                                    ri = statistic.roomIncome
                                                        .firstWhere((element) =>
                                                            element.roomID ==
                                                            roomID);
                                                  } catch (e) {
                                                    ri = null;
                                                  }
                                                  if (ri == null) {
                                                    return {roomID: 0};
                                                  }
                                                  return {
                                                    roomID: ri.completedOrderNum
                                                  };
                                                }),
                                                xValueMapper: (ri, _) =>
                                                    ri.keys.first,
                                                yValueMapper: (ri, _) =>
                                                    ri.values.first),
                                            ColumnSeries<Map<String, int>,
                                                    String>(
                                                name: "Tổng số đơn",
                                                dataLabelSettings:
                                                    const DataLabelSettings(
                                                        isVisible: true),
                                                dataSource: List.generate(
                                                    (GetIt.I<InternalStorage>()
                                                                .read(
                                                                    "statistic")
                                                            as Statistic)
                                                        .roomIncome
                                                        .length, (index) {
                                                  var statistic = (GetIt.I<
                                                              InternalStorage>()
                                                          .read("statistic")
                                                      as Statistic);
                                                  var roomID = statistic
                                                      .allOrderNum.keys
                                                      .elementAt(index);

                                                  return {
                                                    roomID: statistic
                                                        .allOrderNum.values
                                                        .elementAt(index)
                                                  };
                                                }),
                                                xValueMapper: (ri, _) =>
                                                    ri.keys.first,
                                                yValueMapper: (ri, _) =>
                                                    ri.values.first),
                                          ])))
                            ],
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: SfCartesianChart(
                                        title: ChartTitle(
                                            text:
                                                "Tương quan dịch vụ được chọn (trong tổng số ${(GetIt.I<InternalStorage>().read("statistic") as Statistic).allOrderNum.values.last} đơn)"),
                                        primaryXAxis: CategoryAxis(
                                            title:
                                                AxisTitle(text: "Tên dịch vụ")),
                                        primaryYAxis: NumericAxis(
                                            title:
                                                AxisTitle(text: "Số lần đặt")),
                                        series: [
                                          ColumnSeries<ServiceUsage, String>(
                                              enableTooltip: true,
                                              dataSource:
                                                  (GetIt.I<InternalStorage>()
                                                              .read("statistic")
                                                          as Statistic)
                                                      .serviceUsage,
                                              dataLabelSettings:
                                                  const DataLabelSettings(
                                                      isVisible: true),
                                              xValueMapper: (datum, index) =>
                                                  GetIt.I<InternalStorage>()
                                                      .read("servicesList")
                                                      .firstWhere((element) =>
                                                          element.id ==
                                                          datum.serviceID)
                                                      .name,
                                              yValueMapper: (datum, index) =>
                                                  datum.num)
                                        ],
                                      ))),
                              Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: SfCircularChart(
                                          legend: Legend(isVisible: true),
                                          title: ChartTitle(
                                              text:
                                                  "Tương quan hạng ăn được chọn (trong tổng số ${(GetIt.I<InternalStorage>().read("statistic") as Statistic).allOrderNum.values.last} đơn)"),
                                          series: [
                                            PieSeries<Map<String, int>, String>(
                                                dataLabelSettings:
                                                    const DataLabelSettings(
                                                        isVisible: true),
                                                dataSource: List.generate(
                                                    (GetIt.I<InternalStorage>()
                                                                .read(
                                                                    "statistic")
                                                            as Statistic)
                                                        .eatingRank
                                                        .length, (index) {
                                                  return {
                                                    (GetIt.I<InternalStorage>()
                                                                .read(
                                                                    "statistic")
                                                            as Statistic)
                                                        .eatingRank
                                                        .keys
                                                        .elementAt(
                                                            index): (GetIt.I<
                                                                    InternalStorage>()
                                                                .read(
                                                                    "statistic")
                                                            as Statistic)
                                                        .eatingRank
                                                        .values
                                                        .elementAt(index)
                                                  };
                                                }),
                                                xValueMapper: (ri, _) =>
                                                    "Hạng ${ri.keys.first}",
                                                yValueMapper: (ri, _) =>
                                                    ri.values.first),
                                          ])))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          }),
        ],
      ),
    );
  }
}
