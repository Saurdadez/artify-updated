class BookCommissionModel {
  String firstName;
  String lastName;
  String email;
  String commissioner;
  String zipCode;
  String descriptionRequest;
  String contactNumber;
  String city;
  //String artReference;
  String address;
  List<String> artReference;

  BookCommissionModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.zipCode,
    required this.descriptionRequest,
    required this.contactNumber,
    required this.city,
    required this.artReference,
    required this.commissioner,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'commissioner': email,
      'zipCode': zipCode,
      'descriptionRequest': descriptionRequest,
      'contactNumber': contactNumber,
      'city': city,
      'artReference': artReference,
      'address': address,
    };
  }
}
