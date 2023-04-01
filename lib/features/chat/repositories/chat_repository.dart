import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/models/chat_contact.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/user_model.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  void _saveDataToContactsSubCollection(
    UserModel senderUserData,
    UserModel receiverUserData,
    String text,
    DateTime timeSend,
    String receiverUserId,
  ) async {
    //TODO: users -> receiver user id=> chats->current user id -> set data
    var receiverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      contactId: senderUserData.uid,
      timeSend: timeSend,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(
          receiverChatContact.toMap(),
        );
    //TODO: users -> current user id=> chats->receiver user id-> set data
    var senderChatContact = ChatContact(
      name: receiverUserData.name,
      profilePic: receiverUserData.profilePic,
      contactId: receiverUserData.uid,
      timeSend: timeSend,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .set(
          senderChatContact.toMap(),
        );
  }

  void _saveMessageToMessageSubCollection({
    required String receiverUserId,
    required String text,
    required DateTime timeSend,
    required String messageId,
    required String username,
    required receiverUsername,
    required MessageEnum messageType,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: text,
      type: messageType,
      timeSend: timeSend,
      messageId: messageId,
      isSeen: false,
    );
    //TODO: user -> sender id -> receiver id -> messages -> messages id-> store message
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
    //TODO: user ->receiver id ->  sender id -> messages -> messages id-> store message
    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required UserModel senderUser,
  }) async {
    try {
      var timeSend = DateTime.now();
      UserModel receiverUserData;

      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      var messageId = const Uuid().v1();
      //TODO: user -> receiver user id -> set data
      _saveDataToContactsSubCollection(
        senderUser,
        receiverUserData,
        text,
        timeSend,
        receiverUserId,
      );

      _saveMessageToMessageSubCollection(
        receiverUserId: receiverUserId,
        text: text,
        timeSend: timeSend,
        messageType: MessageEnum.text,
        messageId: messageId,
        username: senderUser.name,
        receiverUsername: receiverUserData.name,
      );
    } catch (e) {
      showSnackBar(
        context: context,
        content: e.toString(),
      );
    }
  }
}
