//
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../model/conversation.dart';
// import '../model/message.dart';
// import '../model/user_model.dart';
// import '../repo/chat_repository.dart';
//
// class ChatProvider extends ChangeNotifier {
//   IChatRepository repo;
//   ChatProvider(this.repo);
//
//   List<Conversation> inbox = [];
//   final Map<String, List<Message>> _messages = {};
//   bool isTyping = false;
//
//   Future<void> loadInbox() async {
//     inbox = await repo.fetchInbox();
//     notifyListeners();
//   }
//
//   Future<void> openConversation(Conversation c) async {
//     if (_messages[c.id] != null) return;
//     _messages[c.id] = await repo.fetchMessages(c.id, c.peer);
//     notifyListeners();
//   }
//
//   List<Message> messagesFor(String id) => _messages[id] ?? [];
//
//   // ← UPDATED: now supports attachments (optional)
//   Future<void> send(
//       String conversationId,
//       String text,
//       OdooUser me, {
//         List<PickedAttachment> attachments = const [],
//       }) async {
//     Message msg;
//
//     if (attachments.isEmpty) {
//       // ── Text-only: original behavior ───────────────────────────────
//       msg = await repo.sendMessage(
//         conversationId: conversationId,
//         text: text,
//         sender: me,
//       );
//     } else {
//       // ── 1) Upload files → get IDs ─────────────────────────────────
//       final uploaded = await repo.uploadAttachments(
//         conversationId: conversationId,
//         picked: attachments,
//       );
//       final ids = uploaded.map((e) => e.id).toList();
//
//       // ── 2) Send message referencing uploaded files ────────────────
//       msg = await repo.sendMessage(
//         conversationId: conversationId,
//         text: text,
//         sender: me,
//         attachmentIds: ids,
//       );
//
//       // If API didn't echo attachments back, add a local view-friendly fallback.
//       if ((msg.attachments.isEmpty) && attachments.isNotEmpty) {
//         msg = Message(
//           id: msg.id,
//           conversationId: msg.conversationId,
//           sender: msg.sender,
//           createdAt: msg.createdAt,
//           type: MessageType.attachment,
//           text: text.isNotEmpty ? text : null,
//           attachments: uploaded.map((u) => MessageAttachment(
//             title: u.name,
//             subtitle: u.url.isNotEmpty ? u.url : 'Attachment',
//             icon: Icons.attach_file,
//           )).toList(),
//           pickedattachments: attachments, // lets UI show local thumbnails if needed
//         );
//       }
//     }
//
//     final list = List<Message>.from(messagesFor(conversationId))..add(msg);
//     _messages[conversationId] = list;
//     notifyListeners();
//   }
//
//   void setTyping(bool value) {
//     isTyping = value;
//     notifyListeners();
//   }
// }


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/conversation.dart';
import '../model/message.dart';
import '../model/user_model.dart';
import '../repo/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  IChatRepository repo;
  ChatProvider(this.repo);

  List<Conversation> inbox = [];

  /// conversationId → list of messages
  final Map<String, List<Message>> _messages = {};

  bool isTyping = false;

  // ─────────────────────────── inbox ───────────────────────────

  Future<void> loadInbox() async {
    try {
      inbox = await repo.fetchInbox(); // repo will fallback to JSON-RPC if needed
      notifyListeners();
    } catch (e) {
      // If repo itself already returns demo inbox on error, this won't run,
      // but keep a catch to avoid crashing UI.
      debugPrint('loadInbox error: $e');
    }
  }


  Future<Conversation> startConversationWith({
    required int partnerId,
    required String partnerName,
  }) async {
    // 1) Ask repo to get or create the mail.channel
    final conv = await repo.getOrCreateDirectChannel(
      partnerId: partnerId,
      partnerName: partnerName,
    );

    // 2) Put it in inbox (or update existing)
    final existingIdx = inbox.indexWhere((c) => c.id == conv.id);
    if (existingIdx == -1) {
      inbox = [...inbox, conv];
    } else {
      inbox[existingIdx] = conv;
    }
    notifyListeners();

    // 3) Load messages for this conversation (this uses mail.channel.channel_fetch_message + write)
    _messages[conv.id] = await repo.fetchMessages(conv.id, conv.peer);
    notifyListeners();

    return conv;
  }


  Future<void> openConversation(Conversation c, {bool forceRefresh = false}) async {
    final existing = _messages[c.id];

    // If we already have messages and no forceRefresh, you can skip the network call
    // (they were already seen once). Comment this out if you want to always re-fetch.
    if (!forceRefresh && (existing != null && existing.isNotEmpty)) {
      _setInboxUnread(c.id, 0);
      return;
    }

    try {
      final msgs = await repo.fetchMessages(c.id, c.peer);
      _messages[c.id] = msgs;

      // Mark as read in UI – backend is already updated via JSON-RPC write(...)
      _setInboxUnread(c.id, 0);
      notifyListeners();
    } catch (e) {
      debugPrint('openConversation error: $e');
    }
  }

  List<Message> messagesFor(String id) => _messages[id] ?? [];

  // ─────────────────────────── send message ────────────────────

  /// Supports text-only and text + attachments.
  Future<void> send(
      String conversationId,
      String text,
      OdooUser me, {
        List<PickedAttachment> attachments = const [],
      }) async {
    Message msg;

    if (attachments.isEmpty) {
      // ── Text only ─────────────────────────────────────────────
      msg = await repo.sendMessage(
        conversationId: conversationId,
        text: text,
        sender: me,
      );
    } else {
      // ── 1) Upload files → get IDs ─────────────────────────────
      final uploaded = await repo.uploadAttachments(
        conversationId: conversationId,
        picked: attachments,
      );
      final ids = uploaded.map((e) => e.id).toList();

      // ── 2) Send message referencing uploaded files ───────────
      msg = await repo.sendMessage(
        conversationId: conversationId,
        text: text,
        sender: me,
        attachmentIds: ids,
      );

      // If backend didn't echo attachments back, build a local view.
      if (msg.attachments.isEmpty && attachments.isNotEmpty) {
        msg = Message(
          id: msg.id,
          conversationId: msg.conversationId,
          sender: msg.sender,
          createdAt: msg.createdAt,
          type: MessageType.attachment,
          text: text.isNotEmpty ? text : null,
          attachments: uploaded
              .map(
                (u) => MessageAttachment(
              title: u.name,
              subtitle: u.url.isNotEmpty ? u.url : 'Attachment',
              icon: Icons.attach_file,
            ),
          )
              .toList(),
          pickedattachments: attachments, // for showing local thumbnails
        );
      }
    }

    // Append to local message list
    final current = List<Message>.from(messagesFor(conversationId))..add(msg);
    _messages[conversationId] = current;

    // Also update the inbox entry (last message + unread = 0 for the sender)
    _updateInboxWithLastMessage(conversationId, msg);

    notifyListeners();
  }

  // ─────────────────────────── typing state ────────────────────

  void setTyping(bool value) {
    if (isTyping == value) return;
    isTyping = value;
    notifyListeners();
  }

  // ─────────────────────────── helpers ─────────────────────────

  void _setInboxUnread(String convId, int unread) {
    final idx = inbox.indexWhere((c) => c.id == convId);
    if (idx == -1) return;

    final old = inbox[idx];
    inbox[idx] = Conversation(
      id: old.id,
      peer: old.peer,
      lastMessage: old.lastMessage,
      unreadCount: unread,
    );
  }

  void _updateInboxWithLastMessage(String convId, Message last) {
    final idx = inbox.indexWhere((c) => c.id == convId);
    if (idx == -1) return;

    final old = inbox[idx];
    inbox[idx] = Conversation(
      id: old.id,
      peer: old.peer,
      lastMessage: last,
      // when *you* send a message, unread on your side is 0
      unreadCount: 0,
    );
  }
}
