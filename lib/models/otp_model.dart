class VerifyOtpRequest {
  final String otp;

  VerifyOtpRequest({required this.otp});

  Map<String, dynamic> tojson() {
    return {'otp': otp};
  }
}



class LoginRequest {
  final String mobile;

  LoginRequest({required this.mobile});

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
    };
  }
}

