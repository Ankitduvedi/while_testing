class AdCarousel {
  final String id;
  final String organisation;
  final String videoUrl;
  final String thumbnail;
  final String title;
  final String description;
  final List likes;
  final int views;
  final String category;
  final String playStoreURL;
  final String website;

  AdCarousel(
      {required this.id,
      required this.playStoreURL,
      required this.website,
      required this.organisation,
      required this.videoUrl,
      required this.thumbnail,
      required this.title,
      required this.description,
      required this.likes,
      required this.views,
      required this.category});

  factory AdCarousel.fromMap(Map<String, dynamic> map) {
    return AdCarousel(
      thumbnail: map['thumbnail'] as String,
      playStoreURL: map['playStoreURL'] as String,
      website: map['website'] as String,
      description: map['description'] as String,
      likes: List.from(map['likes']),
      title: map['title'] as String,
      organisation: map['organisation'] as String,
      videoUrl: map['videoUrl'] as String,
      id: map['id'] as String,
      views: map['views'] as int,
      category: map['category'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['thumbnail'] = thumbnail;
    map['description'] = description;
    map['likes'] = likes;
    map['title'] = title;
    map['organisation'] = organisation;
    map['videoUrl'] = videoUrl;
    map['id'] = id;
    map['views'] = views;
    map['category'] = category;
    map['playStoreURL'] = playStoreURL;
    map['website'] = website;
    return map;
  }
}
