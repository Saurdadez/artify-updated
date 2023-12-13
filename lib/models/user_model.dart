class UserObject {
  List<String> followers;
  List<String> following;
  String email;
  String username;
  String firstName;
  String lastName;
  List<String> interests;
  List<String> commissions;
  List<String> userLiked;
  List<String> userFavorites;
  String contactNumber;
  String streetAddress;
  String cityAddress;
  String zip;
  String country;
  double credits;
  String profileUrl;
  String dateCreated;

  UserObject({
    required this.followers,
    required this.dateCreated,
    required this.following,
    required this.profileUrl,
    required this.userLiked,
    required this.userFavorites,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.interests,
    required this.zip,
    required this.commissions,
    required this.contactNumber,
    required this.streetAddress,
    required this.cityAddress,
    required this.country,
    required this.credits,
  });

  List<String> get getFollowers => followers;
  List<String> get getFollowing => following;
  String get getEmail => email;
  String get getUsername => username;
  List<String> get getInterests => interests;
  List<String> get getCommissions => commissions;
  String get getContactNumber => contactNumber;
  String get getStreetAddress => streetAddress;
  String get getCityAddress => cityAddress;
  String get getZip => zip;
  String get getCountry => country;
  double get getCredits => credits;
}
