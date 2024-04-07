class ChatUser {
  ChatUser(
      {required this.image,
      required this.about,
      required this.name,
      required this.createdAt,
      required this.isOnline,
      required this.id,
      required this.lastActive,
      required this.email,
      required this.pushToken,
      required this.dateOfBirth,
      required this.gender,
      required this.phoneNumber,
      required this.place,
      required this.profession,
      required this.designation,
      required this.follower,
      required this.easyQuestions,
      required this.mediumQuestions,
      required this.hardQuestions,
      required this.lives,
      required this.following,
      required this.isContentCreator,
      required this.isApproved});
  late String image;
  late String about;
  late String name;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String email;
  late String pushToken;
  late String phoneNumber;
  late String dateOfBirth;
  late String gender;
  late String profession;
  late String place;
  late String designation;
  late int following;
  late int follower;
  late int easyQuestions;
  late int mediumQuestions;
  late int hardQuestions;
  late int lives;
  late bool isContentCreator;
  late bool isApproved;

  // Update fromJson method to include the new field
  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? false;
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
    phoneNumber = json['phoneNumber'] ?? '';
    dateOfBirth = json['dateOfBirth'] ?? '';
    gender = json['gender'] ?? '';
    profession = json['profession'] ?? '';
    place = json['place'] ?? '';
    designation = json['designation'] ?? '';
    following = json['following'] ?? 0;
    follower = json['follower'] ?? 0;
    easyQuestions = json['easyQuestions'] ?? 0;
    mediumQuestions = json['mediumQuestions'] ?? 0;
    hardQuestions = json['hardQuestions'] ?? 0;
    lives = json['lives'] ?? 0;
    // Add the new field
    isContentCreator = json['isContentCreator'] ?? false;
    isApproved = json['isApproved'] ?? false;
  }

  // Update toJson method to include the new field
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['phoneNumber'] = phoneNumber;
    data['dateOfBirth'] = dateOfBirth;
    data['gender'] = gender;
    data['profession'] = profession;
    data['place'] = place;
    data['designation'] = designation;
    data['following'] = following;
    data['follower'] = follower;
    data['easyQuestions'] = easyQuestions;
    data['mediumQuestions'] = mediumQuestions;
    data['hardQuestions'] = hardQuestions;
    data['lives'] = lives;
    // Add the new field
    data['isContentCreator'] = isContentCreator;
    data['isApproved'] = isApproved;
    return data;
  }

  // Similarly, update the toMap method if needed
  Map<String, dynamic> toMap() {
    return {
      'lives': lives,
      'image': image,
      'about': about,
      'name': name,
      'createdAt': createdAt,
      'isOnline': isOnline,
      'id': id,
      'lastActive': lastActive,
      'email': email,
      'pushToken': pushToken,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'place': place,
      'profession': profession,
      'designation': designation,
      'follower': follower,
      'following': following,
      'easyQuestions': easyQuestions,
      'mediumQuestions': mediumQuestions,
      'hardQuestions': hardQuestions,
      // Add the new field
      'isContentCreator': isContentCreator,
      'isApproved': isApproved,
    };
  }

  // If you have a factory constructor for creating an empty object, make sure to include the new field there as well
  factory ChatUser.empty() {
    return ChatUser(
        lives: 0,
        easyQuestions: 0,
        image: '',
        hardQuestions: 0,
        about: '',
        mediumQuestions: 0,
        name: '',
        createdAt: '',
        isOnline: false,
        id: '',
        lastActive: '',
        email: '',
        pushToken: '',
        dateOfBirth: '',
        gender: '',
        phoneNumber: '',
        place: '',
        profession: '',
        designation: '',
        follower: 0,
        following: 0,
        // Initialize the new field
        isContentCreator: false,
        isApproved: false);
  }

  // Add a copyWith method
  ChatUser copyWith({
    String? image,
    String? about,
    String? name,
    String? createdAt,
    bool? isOnline,
    String? id,
    String? lastActive,
    String? email,
    String? pushToken,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? profession,
    String? place,
    String? designation,
    int? following,
    int? follower,
    int? easyQuestions,
    int? mediumQuestions,
    int? hardQuestions,
    int? lives,
    bool? isContentCreator,
    bool? isApproved,
  }) {
    return ChatUser(
      image: image ?? this.image,
      about: about ?? this.about,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
      id: id ?? this.id,
      lastActive: lastActive ?? this.lastActive,
      email: email ?? this.email,
      pushToken: pushToken ?? this.pushToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profession: profession ?? this.profession,
      place: place ?? this.place,
      designation: designation ?? this.designation,
      following: following ?? this.following,
      follower: follower ?? this.follower,
      easyQuestions: easyQuestions ?? this.easyQuestions,
      mediumQuestions: mediumQuestions ?? this.mediumQuestions,
      hardQuestions: hardQuestions ?? this.hardQuestions,
      lives: lives ?? this.lives,
      isContentCreator: isContentCreator ?? this.isContentCreator,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
