import 'package:com.example.while_app/data/model/chat_user.dart';
import 'package:com.example.while_app/view_model/firebasedata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userDataProvider = FutureProvider<ChatUser>((ref) async {
  return ref.watch(userProvider).getUsers();
});
