import 'package:field_force_2/model/user_model.dart';
import 'package:flutter/material.dart';
class PickedAttachment {
  final String path;
  final String name;
  final AttachmentType type; // image or file
  PickedAttachment({required this.path, required this.name, required this.type});
}

enum AttachmentType { image, file }

enum MessageType { text, attachment }

class MessageAttachment {
  final String title;
  final String subtitle;
  final IconData icon;

  const MessageAttachment({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class Message {
  final String id;
  final String conversationId;
  final OdooUser sender;
  final DateTime createdAt;
  final MessageType type;
  final String? text;
  final List<MessageAttachment> attachments;
  final List<PickedAttachment>? pickedattachments;

  const Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.createdAt,
    required this.type,
    this.text,
    required this.attachments,
     this.pickedattachments,
  });
}
