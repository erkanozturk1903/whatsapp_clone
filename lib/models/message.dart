import 'package:whatsapp_clone/common/enums/message_enum.dart';

class Message{
  final String senderId;
  final String receiverId;
  final String text;
  final MessageEnum type;
  final DateTime timeSend;
  final String messageId;
  final bool isSeen;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.timeSend,
    required this.messageId,
    required this.isSeen,
});

  Map<String, dynamic> toMap() {
    return {
      'senderId' : senderId,
      'receiverId' : receiverId,
      'text' : text,
      'type' : type.type,
      'timeSend' : timeSend.millisecondsSinceEpoch,
      'messageId' : messageId,
      'isSeen' : isSeen,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      type: (map['text'] as String).toEnum(),
      timeSend: DateTime.fromMillisecondsSinceEpoch(map['timeSend']),
      messageId: map['messageId'] ?? '',
      isSeen: map['isSeen'] ?? '',
    );
  }


}