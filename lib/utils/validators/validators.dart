class Validators {
  final DateTime? checkIn, checkOut;
  final String? weightRank;

  Validators({this.checkIn, this.checkOut, this.weightRank}) {
    checkInValidator = (value) {
      print("executed");
      if (value == null) return "Không để trống";
      if (checkOut == null) return null;
      if (value.isAfter(checkOut!)) return "Phải check-in trước check-out";
      return null;
    };
    checkOutValidator = (value) {
      print("executed");
      if (value == null) return "Không để trống";
      if (checkIn == null) return null;
      if (checkIn!.isAfter(value)) return "Phải check-out sau check-in";
      return null;
    };
    weightValidator = (value) {
      if (value == null || value.isEmpty || weightRank == null) return null;
      if (double.tryParse(value) == null) {
        return "Cân nặng mèo không phải số";
      }
      if (weightRank == "< 3kg" && double.parse(value) < 3) return null;
      if (weightRank == "3-6kg" &&
          double.parse(value) >= 3 &&
          double.parse(value) <= 6) return null;
      if (weightRank == "> 6kg" && double.parse(value) > 6) return null;
      return "Cân nặng phải nằm trong hạng cân";
    };
  }

  String? Function(String?)? usernameValidator = (value) {
    if (value == null || value.isEmpty) return "Không để trống";
    if (!RegExp(r"^\w{5,}$").hasMatch(value)) {
      return "Tài khoản chỉ chứa chữ cái, số hoặc dấu _ và dài hơn 5 ký tự";
    }
    return null;
  };
  String? Function(String?)? passwordValidator = (value) {
    if (value == null || value.isEmpty) return "Không để trống";
    if (!RegExp(r"^\w{5,}$").hasMatch(value)) {
      return "Mật khẩu chỉ chứa chữ cái, số hoặc dấu _ và dài hơn 8 ký tự";
    }
    return null;
  };
  String? Function(Object?)? notNullValidator = (value) {
    if (value == null) return "Không để trống";
    return null;
  };
  String? Function(DateTime?)? checkInValidator, checkOutValidator;
  String? Function(String?)? multilineTextCanNullValidator = (value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[^]{1,200}$', unicode: true, multiLine: true)
        .hasMatch(value)) {
      return "Văn bản không đúng định dạng";
    }
    return null;
  };

  String? Function(String?)? multilineTextCanNotNullValidator = (value) {
    if (value == null || value.isEmpty) return "Không để trống";
    if (!RegExp(r'^[^]{1,200}$', unicode: true, multiLine: true)
        .hasMatch(value)) {
      return "Văn bản không đúng định dạng";
    }
    return null;
  };

  String? Function(String?)? nameValidator = (value) {
    if (value == null || value.isEmpty) return "Không để trống";
    if (!RegExp(r'^[\p{L}\s]{1,50}$', unicode: true).hasMatch(value)) {
      return "Tên không đúng định dạng";
    }
    return null;
  };

  String? Function(String?)? speciesValidator = (value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[\p{L}\s]{1,30}$', unicode: true).hasMatch(value)) {
      return "Giống mèo không đúng định dạng";
    }
    return null;
  };

  String? Function(String?)? weightValidator;
  String? Function(String?)? ageValidator = (value) {
    if (value == null) return "Không để trống";
    if (int.tryParse(value) == null) return "Tuổi phải là số nguyên dương";
    if (int.parse(value) < 0) return "Tuổi phải là số nguyên dương";
    return null;
  };

  String? Function(String?)? telValidator = (value) {
    if (value == null || value.isEmpty) {
      return "Không để trống số điện thoại";
    }
    if (!RegExp(r'^0\d{9}$').hasMatch(value)) {
      return "Số điện thoại không đúng định dạng";
    }
    return null;
  };
}
