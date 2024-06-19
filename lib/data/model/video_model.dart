class Video {
  final String id;
  final String uploadedBy;
  final String videoUrl;
  final String thumbnail;
  final String title;
  final String description;
  final List likes;
  final int views;
  final String category;
  final String creatorName;
  final String maxVideoRes;

  Video({
    required this.id,
    required this.uploadedBy,
    required this.videoUrl,
    required this.thumbnail,
    required this.title,
    required this.description,
    required this.likes,
    required this.views,
    required this.category,
    required this.creatorName,
    required this.maxVideoRes,
  });

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
        thumbnail: map['thumbnail'] as String,
        creatorName: map['creatorName'] as String,
        description: map['description'] as String,
        likes: List.from(map['likes']),
        title: map['title'] as String,
        uploadedBy: map['uploadedBy'] as String,
        videoUrl: map['videoUrl'] as String,
        id: map['id'] as String,
        views: map['views'] as int,
        category: map['category'] as String,
        maxVideoRes: map['maxVideoRes'] as String);
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['thumbnail'] = thumbnail;
    map['creatorName'] = creatorName;
    map['description'] = description;
    map['likes'] = likes;
    map['title'] = title;
    map['uploadedBy'] = uploadedBy;
    map['videoUrl'] = videoUrl;
    map['id'] = id;
    map['views'] = views;
    map['category'] = category;
    map['maxVideoRes'] = maxVideoRes;
    return map;
  }
}
