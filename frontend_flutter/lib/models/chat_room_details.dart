import 'package:meta/meta.dart';
import 'dart:convert';

List<ChatRoomsDetails> chatRoomsDetailsFromJson(String str) =>
    List<ChatRoomsDetails>.from(
        json.decode(str).map((x) => ChatRoomsDetails.fromJson(x)));

String chatRoomsDetailsToJson(List<ChatRoomsDetails> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatRoomsDetails {
  final String collectionId;
  final String collectionName;
  final DateTime created;
  final String id;
  final String idChatRoom;
  final Messages messages;
  final String timestamp;
  final DateTime updated;

  ChatRoomsDetails({
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.id,
    required this.idChatRoom,
    required this.messages,
    required this.timestamp,
    required this.updated,
  });

  factory ChatRoomsDetails.fromJson(Map<String, dynamic> json) =>
      ChatRoomsDetails(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        created: DateTime.parse(json["created"]),
        id: json["id"],
        idChatRoom: json["id_chat_room"],
        messages: Messages.fromJson(json["messages"]),
        timestamp: json["timestamp"],
        updated: DateTime.parse(json["updated"]),
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created.toIso8601String(),
        "id": id,
        "id_chat_room": idChatRoom,
        "messages": messages.toJson(),
        "timestamp": timestamp,
        "updated": updated.toIso8601String(),
      };
}

class Messages {
  final String message;
  final String senderId;

  Messages({
    required this.message,
    required this.senderId,
  });

  factory Messages.fromJson(Map<String, dynamic> json) => Messages(
        message: json["message"],
        senderId: json["sender_id"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "sender_id": senderId,
      };
}
