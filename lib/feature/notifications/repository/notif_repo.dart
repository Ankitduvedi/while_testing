import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.while.while_app/core/enums/firebase_providers.dart';
import 'package:com.while.while_app/data/model/failure.dart';
import 'package:com.while.while_app/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final notifRepositoryProvider = Provider<NotifRepository>((ref) {
  return NotifRepository(ref: ref);
});

class NotifRepository {
  final Ref _ref;
  NotifRepository({required Ref ref}) : _ref = ref;
  FirebaseFirestore get firestore => _ref.read(fireStoreProvider);

  Future<Either<Failure, bool>> addNotification(
      String notificationText, String userId) async {
    try {
      await firestore
          .collection('notifications')
          .doc(userId)
          .collection('notifs')
          .add({
        'timeStamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'notificationText': notificationText
      });
      return right(true);
    } catch (e) {
      return left(Failure(message: "Unable to add notification"));
    }
  }

  Future<Either<Failure, bool>> markAllNotificationsAsRead() async {
    try {
      var collection = _ref
          .read(fireStoreProvider)
          .collection('notifications')
          .doc(_ref.read(userDataProvider).userData!.id)
          .collection('notifs');
      var snapshots = await collection.where('isRead', isEqualTo: false).get();

      // Write batch to update all documents as read
      WriteBatch batch = _ref.read(fireStoreProvider).batch();
      for (var doc in snapshots.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      return right(true);
    } catch (e) {
      return left(Failure(message: "Unable to mark notifications update"));
    }
  }
}
