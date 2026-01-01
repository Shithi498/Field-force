import 'package:field_force_2/model/user_model.dart';

import 'message.dart';


class Conversation {
  final String id;
  final OdooUser peer;
  final Message lastMessage;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.peer,
    required this.lastMessage,
    this.unreadCount = 0,
  });
}
