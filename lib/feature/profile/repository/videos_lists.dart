import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/data/model/video_model.dart';

class VideoList {
  // Static method to get the list of video URLs
  static List<Video> getVideoList(QuerySnapshot snapshot) {
    List<Video> videoList = [];
    // print(snapshot.docs.first.id);
    for (QueryDocumentSnapshot docu in snapshot.docs) {
      // Create a Video object using the data and add it to the list
      Video video = Video(
          category: docu.get('category'),
          id: docu.id,
          uploadedBy: docu.get('uploadedBy'),
          videoUrl: docu.get('videoUrl'),
          title: docu.get('title'),
          description: docu.get('description'),
          thumbnail: docu.get('thumbnail'),
          likes: docu.get('likes'),
          views: docu.get('views'));
      //Video video = Video.fromMap(docu.data() as Map<String, dynamic>);
      videoList.add(video);
    }
    return videoList;
  }
}
