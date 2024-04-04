class Counsellor {
  Counsellor(
      {required this.about,
      required this.joinedAt,
      required this.id,
      required this.place,
      required this.profession,
      required this.designation,
      required this.categories,
      required this.isApproved});

  late String about;
  late String joinedAt;
  late String id;
  late String profession;
  late String place;
  late String designation;
  late List<String> categories;
  late bool isApproved;

  // Update fromJson method to include the new field
  Counsellor.fromJson(Map<String, dynamic> json) {
    about = json['about'] ?? '';
    joinedAt = json['created_at'] ?? '';
    id = json['id'] ?? '';
    profession = json['profession'] ?? '';
    place = json['place'] ?? '';
    designation = json['designation'] ?? '';
    categories = json['categories'] ?? [];

    isApproved = json['isApproved'] ?? false;
  }

  // Update toJson method to include the new field
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['about'] = about;

    data['created_at'] = joinedAt;

    data['id'] = id;
    data['categories'] = categories;

    data['profession'] = profession;
    data['place'] = place;
    data['designation'] = designation;
    // Add the new field

    data['isApproved'] = isApproved;
    return data;
  }

  // If you have a factory constructor for creating an empty object, make sure to include the new field there as well
  factory Counsellor.empty() {
    return Counsellor(
        joinedAt: '',
        id: '',
        place: '',
        profession: '',
        designation: '',
        about: '',
        // Initialize the new field
        categories: [],
        isApproved: false);
  }
}
