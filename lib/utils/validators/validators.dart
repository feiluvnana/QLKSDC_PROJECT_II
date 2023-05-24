class Validators {
  late final DateTime? checkIn, checkOut;

  Validators({this.checkIn, this.checkOut});

  String? Function(String?)? usernameValidator = (value) {
    if (value == null || value.isEmpty) return "Không để trống tài khoản";
    if (!RegExp(r"^\w{5,}$").hasMatch(value)) {
      return "Tài khoản chỉ chứa chữ cái, số hoặc dấu _ và dài hơn 5 ký tự";
    }
    return null;
  };
  String? Function(String?)? passwordValidator = (value) {
    if (value == null || value.isEmpty) return "Không để trống mật khẩu";
    if (!RegExp(r"^\w{5,}$").hasMatch(value)) {
      return "Mật khẩu chỉ chứa chữ cái, số hoặc dấu _ và dài hơn 8 ký tự";
    }
    return null;
  };
  String? Function(Object?)? notNullValidator = (value) {
    if (value == null) return "Không để trống";
    return null;
  };
  String? Function(DateTime?)? checkInValidator = (value) {
    if (null == null) return null;
  };
}
