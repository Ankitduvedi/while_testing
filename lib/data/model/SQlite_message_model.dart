import 'dart:convert';
import 'dart:typed_data';
import 'message.dart';
import 'package:http/http.dart' as http;

class MessageWithImage extends Message_Model {
  MessageWithImage({
    required String toId,
    required String msg,
    required String read,
    required Type type,
    required String fromId,
    required String sent,
    this.image,
  }) : super(
          toId: toId,
          msg: msg,
          read: read,
          type: type,
          fromId: fromId,
          sent: sent,
        );

  Uint8List? image;

  static Future<MessageWithImage> fromJson(Map<String, dynamic> json) async {
    Uint8List? image;
    if (json['type'] == 'image') {
      image = await downloadAndSaveImage(json['msg']);
    }
    return MessageWithImage(
      toId: json['toId'].toString(),
      msg: json['msg'].toString(),
      read: json['read'].toString(),
      type: json['type'].toString() == Type.image.name ? Type.image : Type.text,
      fromId: json['fromId'].toString(),
      sent: json['sent'].toString(),
      image: image,
    );
  }

  static Future<MessageWithImage> fromJson2(Map<String, dynamic> json) async {
    Uint8List? image;
    if (json['type'] == 'image') {
      image = json['image'];
    }
    return MessageWithImage(
      toId: json['toId'].toString(),
      msg: json['msg'].toString(),
      read: json['read'].toString(),
      type: json['type'].toString() == Type.image.name ? Type.image : Type.text,
      fromId: json['fromId'].toString(),
      sent: json['sent'].toString(),
      image: image,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    // if (image != null) {
    data['image'] = image != null ? image! : null;
    // }
    return data;
  }
}

Future<Uint8List>? downloadAndSaveImage(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  } catch (e) {
    print('Error: $e');
    return Uint8List(0);
  }
}
