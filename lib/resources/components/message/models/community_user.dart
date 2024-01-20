class CommunityUser {
  CommunityUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    // required this.isOnline,
    required this.id,
    // required this.lastActive,
    required this.email,
    // required this.pushToken,
    required this.type,
    required this.noOfUsers,
    required this.domain,
    required this.admin,
    required this.timeStamp,
    required this.easyQuestions,
    required this.mediumQuestions,
    required this.hardQuestions,
  });
  late String image;
  late String about;
  late String name;
  late String createdAt;
  // late bool isOnline;
  late String id;
  // late String lastActive;
  late String email;
  // late String pushToken;
  late String type;
  late String noOfUsers;
  late String domain;
  late String admin;
  late String timeStamp;
  late int easyQuestions;
  late int mediumQuestions;
  late int hardQuestions;

  CommunityUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    // isOnline = json['is_online'] ?? '';
    id = json['id'] ?? '';
    // lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    // pushToken = json['push_token'] ?? '';
    type = json['type'] ?? '';
    noOfUsers = json['noOfUsers'] ?? '';
    domain = json['domain'] ?? '';
    admin = json['admin'] ?? '';
    timeStamp = json['timeStamp'] ?? '';
    easyQuestions = json['easyQuestions'] ?? '';
    mediumQuestions = json['mediumQuestions'] ?? '';
    hardQuestions = json['hardQuestions'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    // data['is_online'] = isOnline;
    data['id'] = id;
    // data['last_active'] = lastActive;
    data['email'] = email;
    // data['push_token'] = pushToken;
    data['type'] = type;
    data['noOfUsers'] = noOfUsers;
    data['domain'] = domain;
    data['admin'] = admin;
    data['timeStamp'] = timeStamp;
    data['easyQuestions'] = easyQuestions;
    data['mediumQuestions'] = mediumQuestions;
    data['hardQuestions'] = hardQuestions;
    return data;
  }
}
