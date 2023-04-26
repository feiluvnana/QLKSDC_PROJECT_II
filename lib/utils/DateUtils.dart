class DateUtils {
  static bool isLeapYear(Map<String, int> date) {
    if (date["year"]! % 400 == 0) {
      return true;
    }
    if (date["year"]! % 100 != 0 && date["year"]! % 4 == 0) {
      return true;
    }
    return false;
  }

  static int daysInMonth(Map<String, int> date) {
    switch (date["month"]) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      case 2:
        if (isLeapYear(date)) {
          return 29;
        } else {
          return 28;
        }
      default:
        return 30;
    }
  }

  static String daysInWeek(int index) {
    switch (index) {
      case 1:
        return "T2";
      case 2:
        return "T3";
      case 3:
        return "T4";
      case 4:
        return "T5";
      case 5:
        return "T6";
      case 6:
        return "T7";
      default:
        return "CN";
    }
  }

  static String dateTimeToString(DateTime date) {
    return "${date.hour}:${(date.minute < 10) ? "0${date.minute}" : date.minute} ${date.day}/${date.month}/${date.year}";
  }
}
