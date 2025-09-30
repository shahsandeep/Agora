import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRepo {

  FirebaseRepo._privateConstructor();

 
  static final FirebaseRepo _instance = FirebaseRepo._privateConstructor();


  factory FirebaseRepo() {
    return _instance;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? videoCallStream(
      {bool isCaller = true,
      String? channelName,
      bool isFromMain = false,
      String? status}) {
    String userId = isCaller ? '1' : '2';
    String filterValue = isCaller ? 'callerId' : 'receiverId';

    if (isFromMain) {
      if (status != null) {
        return FirebaseFirestore.instance
            .collection('call')
            .where('status', isEqualTo: status)
            .where('receiverId', isEqualTo: userId)
            .snapshots();
      }
      return FirebaseFirestore.instance
          .collection('call')
          .where('receiverId', isEqualTo: userId)
          .snapshots();
    }
    if (channelName != null) {
      return FirebaseFirestore.instance
          .collection('call')
          .where('channelName', isEqualTo: channelName)
          .snapshots();
    }

    return FirebaseFirestore.instance
        .collection('call')
        .where(filterValue, isEqualTo: userId)
        .snapshots();
  }

  Future<void> createOrUpdateCallDocument({
    required String callerId,
    required String callerName,
    required String receiverName,
    required String channelId,
    required String receiverId,
    required String status,
    required String callType,
  }) async {
    try {
      CollectionReference calls = FirebaseFirestore.instance.collection('call');

      Map<String, dynamic> callData = {
        'callerId': callerId,
        'callerName': callerName,
        'channelName': channelId,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'status': status,
        'callType': callType,
      };

      await calls.doc(channelId).set(callData, SetOptions(merge: true));

      print("Call document added/updated successfully!");
    } catch (e) {
      print("Error adding/updating call document: $e");
    }
  }
}
