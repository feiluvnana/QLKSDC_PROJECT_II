class Statistic {
  final List<RoomIncome> roomIncome;
  final Map<String, int> allOrderNum;
  final List<ServiceUsage> serviceUsage;
  final Map<String, int> eatingRank;

  Statistic.fromJson(Map<String, dynamic> json)
      : roomIncome = List.generate(
            Map.from(json["room_income"]).length,
            (index) => RoomIncome(
                Map.from(json["room_income"]).keys.elementAt(index),
                Map.from(json["room_income"])
                    .values
                    .elementAt(index)
                    .values
                    .elementAt(0),
                Map.from(json["room_income"])
                    .values
                    .elementAt(index)
                    .values
                    .elementAt(1),
                Map.from(json["room_income"])
                    .values
                    .elementAt(index)
                    .values
                    .elementAt(2))),
        allOrderNum = Map.from(json["all_order_num"]),
        serviceUsage = List.generate(
            Map.from(json["service_usage"]).length,
            (index) => ServiceUsage(
                int.parse(
                    Map.from(json["service_usage"]).keys.elementAt(index)),
                Map.from(json["service_usage"])
                    .values
                    .elementAt(index)
                    .values
                    .elementAt(0),
                Map.from(json["service_usage"])
                    .values
                    .elementAt(index)
                    .values
                    .elementAt(1))),
        eatingRank = Map.from(json["eating_rank"]) {
    roomIncome.add(RoomIncome.createSum(roomIncome));
    int sum = 0;
    for (int i = 0; i < allOrderNum.length; i++) {
      sum += allOrderNum.values.elementAt(i);
    }
    allOrderNum.addAll({"Tổng": sum});
  }
}

class RoomIncome {
  final String roomID;
  final double room, service;
  final int completedOrderNum;
  RoomIncome(this.roomID, this.room, this.service, this.completedOrderNum);

  static RoomIncome createSum(List<RoomIncome> list) {
    double sroom = 0, sservice = 0;
    int com = 0;
    for (int i = 0; i < list.length; i++) {
      sroom += list[i].room;
      sservice += list[i].service;
      com += list[i].completedOrderNum;
    }
    return RoomIncome("Tổng", sroom, sservice, com);
  }
}

class ServiceUsage {
  final int serviceID;
  final double num;
  final double percentage;

  ServiceUsage(this.serviceID, this.percentage, this.num);
}
