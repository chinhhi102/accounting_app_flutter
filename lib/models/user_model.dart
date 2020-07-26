class User {
  String uid;
  String username;
  String password;
  String fullName;
  User({ this.uid, this.username, this.password, this.fullName });
  User.newUser(String _username, String _password, String _fullname) : username = _username, password = _password, fullName = _fullname;
  User.empty() : username = "", password = "", fullName = "";
  toJson() {
    return {
      'username': username,
      'password': password,
      'fullName': fullName
    };
  }
}