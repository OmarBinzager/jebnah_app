class SignUpModel {
  String? fName;
  String? lName;
  String? phone;

  String? password;
  String? referralCode;

  SignUpModel({
    this.fName,
    this.lName,
    this.phone,
    this.password,
    this.referralCode = '',
  });

  SignUpModel.fromJson(Map<String, dynamic> json) {
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];

    password = json['password'];
    referralCode = json['referral_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;

    data['password'] = password;
    data['referral_code'] = referralCode;
    return data;
  }
}
