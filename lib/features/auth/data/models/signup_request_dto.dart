class SignupRequestDto {
  final String name;
  final String email;
  final String password;

  const SignupRequestDto({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
  };
}
