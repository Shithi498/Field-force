//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import '../model/conversation.dart';
// import '../model/message.dart';
// import '../model/user_model.dart';
// import 'chat_repository.dart'; // <- defines IChatRepository + UploadedAttachment
//
// class MemoryChatRepository implements IChatRepository {
//   // ─────────────────────────── ctor / config ───────────────────────────
//   final String baseUrl;
//   final String sessionCookie;
//   final Duration httpTimeout;
//
//   MemoryChatRepository({
//     required this.baseUrl,
//     required this.sessionCookie,
//     this.httpTimeout = const Duration(seconds: 15),
//   });
//
//   Map<String, String> get _headers => <String, String>{
//     'Accept': 'application/json',
//     'Content-Type': 'application/json',
//     if (sessionCookie.isNotEmpty) 'Cookie': sessionCookie,
//   };
//
//   // ─────────────────────────── demo users ──────────────────────────────
//   final OdooUser me = OdooUser(
//     uid: 999,
//     name: "John",
//     username: "john@test.com",
//     db: "",
//     timezone: "",
//     companyName: "",
//   );
//
//   final OdooUser juliana = OdooUser(
//     uid: 1,
//     name: "Juliana Wills",
//     username: "juliana@test.com",
//     db: "",
//     timezone: "",
//     companyName: "",
//   );
//
//   final OdooUser maria = OdooUser(
//     uid: 2,
//     name: "Maria Anderson",
//     username: "maria@test.com",
//     db: "",
//     timezone: "",
//     companyName: "",
//   );
//
//   // ─────────────────────────── inbox ───────────────────────────────────
//   @override
//   Future<List<Conversation>> fetchInbox({bool useGet = false}) async {
//     final uri = Uri.parse('$baseUrl/api/chat/inbox');
//
//     try {
//       final http.Response res = useGet
//           ? await http.get(uri, headers: _headers).timeout(httpTimeout)
//           : await http
//           .post(
//         uri,
//         headers: _headers,
//         body: jsonEncode({"jsonrpc": "2.0", "params": {}}),
//       )
//           .timeout(httpTimeout);
//
//       print('→ ${useGet ? "GET" : "POST"} $uri');
//       print('🔹 Status: ${res.statusCode}');
//
//       final ct = res.headers['content-type'] ?? '';
//       final bodyTrim = res.body.trimLeft();
//       final looksHtml =
//           bodyTrim.startsWith('<!DOCTYPE') || bodyTrim.startsWith('<html');
//
//       if (res.statusCode != 200 || !ct.contains('application/json') || looksHtml) {
//         _printPreview(res.body);
//         print('⚠️ Non-JSON or error response. Using demo inbox.');
//         return _demoInbox();
//       }
//
//       Map<String, dynamic> parsed;
//       try {
//         parsed = jsonDecode(res.body) as Map<String, dynamic>;
//       } catch (e) {
//         print('⚠️ JSON parse failed: $e');
//         _printPreview(res.body);
//         return _demoInbox();
//       }
//
//       // Expected: { "result": { "conversations": [...] } }
//       final result = (parsed['result'] ?? {}) as Map<String, dynamic>;
//       final list = (result['conversations'] ?? []) as List;
//
//       if (list.isEmpty) {
//         print('ℹ️ API returned 0 conversations. Using demo inbox.');
//         return _demoInbox();
//       }
//
//       return list.map<Conversation>((raw) => _parseConversation(raw)).toList();
//     } catch (e, st) {
//       print('❌ fetchInbox error: $e');
//       print(st);
//       return _demoInbox();
//     }
//   }
//
//   // ─────────────────────────── messages ────────────────────────────────
//   @override
//   Future<List<Message>> fetchMessages(String conversationId, OdooUser peer,
//       {bool useGet = false}) async {
//     final uri = Uri.parse('$baseUrl/api/chat/messages');
//
//     try {
//       final http.Response res = useGet
//           ? await http.get(
//         uri.replace(queryParameters: {'conversation_id': conversationId}),
//         headers: _headers,
//       ).timeout(httpTimeout)
//           : await http
//           .post(
//         uri,
//         headers: _headers,
//         body: jsonEncode({
//           "jsonrpc": "2.0",
//           "params": {"conversation_id": conversationId}
//         }),
//       )
//           .timeout(httpTimeout);
//
//       print('→ ${useGet ? "GET" : "POST"} $uri');
//       print('🔹 Status: ${res.statusCode}');
//
//       final ct = res.headers['content-type'] ?? '';
//       final bodyTrim = res.body.trimLeft();
//       final looksHtml =
//           bodyTrim.startsWith('<!DOCTYPE') || bodyTrim.startsWith('<html');
//
//       if (res.statusCode != 200 || !ct.contains('application/json') || looksHtml) {
//         _printPreview(res.body);
//         print('⚠️ Non-JSON or error response. Using demo messages.');
//         return _demoMessages(conversationId: conversationId, peer: peer);
//       }
//
//       Map<String, dynamic> parsed;
//       try {
//         parsed = jsonDecode(res.body) as Map<String, dynamic>;
//       } catch (e) {
//         print('⚠️ JSON parse failed: $e');
//         _printPreview(res.body);
//         return _demoMessages(conversationId: conversationId, peer: peer);
//       }
//
//       // Expected: { "result": { "messages": [...] } }
//       final result = (parsed['result'] ?? {}) as Map<String, dynamic>;
//       final list = (result['messages'] ?? []) as List;
//
//       if (list.isEmpty) {
//         print('ℹ️ API returned 0 messages. Using demo messages.');
//         return _demoMessages(conversationId: conversationId, peer: peer);
//       }
//
//       return list.map<Message>((raw) => _parseMessage(raw, peer)).toList();
//     } catch (e, st) {
//       print('❌ fetchMessages error: $e');
//       print(st);
//       return _demoMessages(conversationId: conversationId, peer: peer);
//     }
//   }
//
//   // ─────────────────────────── upload ──────────────────────────────────
//   @override
//   Future<List<UploadedAttachment>> uploadAttachments({
//     required String conversationId,
//     required List<PickedAttachment> picked,
//   }) async {
//     // NOTE: If your real endpoint is different, adjust `uploadUrl` and field names.
//     final uploadUrl = Uri.parse('$baseUrl/api/chat/upload');
//
//     try {
//       final req = http.MultipartRequest('POST', uploadUrl);
//       if (sessionCookie.isNotEmpty) req.headers['Cookie'] = sessionCookie;
//
//       // Some Odoo APIs expect JSON-RPC for metadata—but binary upload usually uses fields.
//       req.fields['conversation_id'] = conversationId;
//
//       for (final p in picked) {
//         // We only have local paths; mock repo can't stream here. Adjust if you keep streams.
//         req.files.add(await http.MultipartFile.fromPath(
//           'files',      // <-- adjust to the field your backend expects
//           p.path,
//           filename: p.name,
//         ));
//       }
//
//       final resp = await req.send().timeout(httpTimeout);
//       final body = await resp.stream.bytesToString();
//
//       print('→ MULTIPART $uploadUrl');
//       print('🔹 Status: ${resp.statusCode}');
//
//       final ct = resp.headers['content-type'] ?? '';
//       final looksHtml =
//           body.trimLeft().startsWith('<!DOCTYPE') || body.trimLeft().startsWith('<html');
//
//       if (resp.statusCode != 200 || !ct.contains('application/json') || looksHtml) {
//         _printPreview(body);
//         print('⚠️ Non-JSON or error on upload. Returning synthesized IDs.');
//         return _synthUploaded(conversationId, picked);
//       }
//
//       Map<String, dynamic> parsed;
//       try {
//         parsed = jsonDecode(body) as Map<String, dynamic>;
//       } catch (e) {
//         print('⚠️ JSON parse failed (upload): $e');
//         _printPreview(body);
//         return _synthUploaded(conversationId, picked);
//       }
//
//       // Expected: { "result": { "attachments": [ { id, name, url?, mime?, size? } ] } }
//       final result = (parsed['result'] ?? {}) as Map<String, dynamic>;
//       final list = (result['attachments'] ?? []) as List;
//
//       if (list.isEmpty) {
//         print('ℹ️ API returned 0 uploaded attachments. Returning synthesized IDs.');
//         return _synthUploaded(conversationId, picked);
//       }
//
//       return list.map<UploadedAttachment>((raw) {
//         final id = '${raw['id'] ?? ''}';
//         final name = '${raw['name'] ?? 'Attachment'}';
//         final url = raw['url']?.toString() ?? '';
//         final mime = raw['mime']?.toString() ?? raw['mimeType']?.toString() ?? '';
//         final size = (raw['size'] is num) ? (raw['size'] as num).toInt() : 0;
//         final isImage = mime.startsWith('image/');
//
//         return UploadedAttachment(
//           id: id.isNotEmpty ? id : 'srv_${DateTime.now().microsecondsSinceEpoch}',
//           name: name,
//           url: url,
//           mimeType: mime,
//           size: size,
//           isImage: isImage,
//         );
//       }).toList();
//     } catch (e, st) {
//       print('❌ uploadAttachments error: $e');
//       print(st);
//       return _synthUploaded(conversationId, picked);
//     }
//   }
//
//
//   @override
//   Future<Message> sendMessage({
//     required String conversationId,
//     required String text,
//     required OdooUser sender,
//     List<String>? attachmentIds,
//   }) async {
//     final uri = Uri.parse('$baseUrl/api/chat/send');
//
//     try {
//       final res = await http
//           .post(
//         uri,
//         headers: _headers,
//         body: jsonEncode({
//           "jsonrpc": "2.0",
//           "params": {
//             "conversation_id": conversationId,
//             "text": text,
//             if (attachmentIds != null && attachmentIds.isNotEmpty)
//               "attachments": attachmentIds,
//           }
//         }),
//       )
//           .timeout(httpTimeout);
//
//       print('→ POST $uri');
//       print('🔹 Status: ${res.statusCode}');
//
//       final ct = res.headers['content-type'] ?? '';
//       final bodyTrim = res.body.trimLeft();
//       final looksHtml =
//           bodyTrim.startsWith('<!DOCTYPE') || bodyTrim.startsWith('<html');
//
//       if (res.statusCode != 200 || !ct.contains('application/json') || looksHtml) {
//         _printPreview(res.body);
//         print('⚠️ Non-JSON or error response. Echoing local.');
//         return _echoLocalFlexible(
//           conversationId: conversationId,
//           text: text,
//           sender: sender,
//           hasAttachments: (attachmentIds?.isNotEmpty ?? false),
//         );
//       }
//
//       final parsed = jsonDecode(res.body) as Map<String, dynamic>;
//       final result = (parsed['result'] ?? {}) as Map<String, dynamic>;
//       final raw = result['message'];
//
//       if (raw == null) {
//         print('ℹ️ API returned no message. Echoing local.');
//         return _echoLocalFlexible(
//           conversationId: conversationId,
//           text: text,
//           sender: sender,
//           hasAttachments: (attachmentIds?.isNotEmpty ?? false),
//         );
//       }
//
//       return _parseMessage(raw, sender);
//     } catch (e, st) {
//       print('❌ sendMessage error: $e');
//       print(st);
//       return _echoLocalFlexible(
//         conversationId: conversationId,
//         text: text,
//         sender: sender,
//         hasAttachments: (attachmentIds?.isNotEmpty ?? false),
//       );
//     }
//   }
//
//   // ─────────────────────────── helpers ─────────────────────────────────
//   void _printPreview(String body) {
//     final len = body.length > 400 ? 400 : body.length;
//     final preview = body.substring(0, len);
//     print('🔹 Body preview (${len} chars):\n$preview');
//   }
//
//   Conversation _parseConversation(Map raw) {
//     final id = '${raw['id'] ?? ''}';
//     final unread = (raw['unread'] is num) ? (raw['unread'] as num).toInt() : 0;
//
//     final peerRaw = (raw['peer'] ?? {}) as Map<String, dynamic>;
//     final peer = _parseOdooUser(peerRaw);
//
//     final lastRaw = (raw['last_message'] ?? {}) as Map<String, dynamic>;
//     final last = _parseMessage(lastRaw, peer);
//
//     if (id.isEmpty || last.id.isEmpty || peer.uid == 0) {
//       return _demoInbox().first;
//     }
//
//     return Conversation(
//       id: id,
//       peer: peer,
//       lastMessage: last,
//       unreadCount: unread,
//     );
//   }
//
//   Message _parseMessage(Map raw, OdooUser fallbackSender) {
//     final id = '${raw['id'] ?? ''}';
//     final convId = '${raw['conversation_id'] ?? ''}';
//     final typeStr = '${raw['type'] ?? 'text'}'.toLowerCase();
//     final type =
//     (typeStr == 'attachment') ? MessageType.attachment : MessageType.text;
//
//     // sender
//     OdooUser sender;
//     if (raw['sender'] is Map) {
//       sender = _parseOdooUser(raw['sender'] as Map<String, dynamic>);
//       if (sender.uid == 0) sender = fallbackSender;
//     } else {
//       sender = fallbackSender;
//     }
//
//     final created = _parseDate(raw['created_at']);
//     final text = raw['text']?.toString();
//
//     // attachments
//     final atts = <MessageAttachment>[];
//     if (raw['attachments'] is List) {
//       for (final a in (raw['attachments'] as List)) {
//         if (a is Map) {
//           atts.add(MessageAttachment(
//             title: '${a['title'] ?? 'Attachment'}',
//             subtitle: '${a['subtitle'] ?? ''}',
//             icon: Icons.attach_file,
//           ));
//         }
//       }
//     }
//
//     return Message(
//       id: id,
//       conversationId: convId,
//       sender: sender,
//       createdAt: created,
//       type: type,
//       text: text,
//       attachments: atts,
//     );
//   }
//
//   OdooUser _parseOdooUser(Map<String, dynamic> m) {
//     return OdooUser(
//       uid: (m['uid'] is num)
//           ? (m['uid'] as num).toInt()
//           : (int.tryParse('${m['uid'] ?? 0}') ?? 0),
//       name: '${m['name'] ?? ''}',
//       username: '${m['username'] ?? ''}',
//       db: '${m['db'] ?? ''}',
//       timezone: m['timezone']?.toString() ?? m['tz']?.toString() ?? '',
//       companyName: m['companyName']?.toString() ??
//           m['company_name']?.toString() ??
//           m['company']?.toString() ??
//           '',
//     );
//   }
//
//   DateTime _parseDate(dynamic v) {
//     if (v == null) return DateTime.now();
//     if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
//     if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
//     if (v is String) {
//       try {
//         return DateTime.parse(v).toLocal();
//       } catch (_) {
//         return DateTime.now();
//       }
//     }
//     return DateTime.now();
//   }
//
//   String _guessMimeFromName(String name) {
//     final n = name.toLowerCase();
//     if (n.endsWith('.jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
//     if (n.endsWith('.png')) return 'image/png';
//     if (n.endsWith('.webp')) return 'image/webp';
//     if (n.endsWith('.gif')) return 'image/gif';
//     if (n.endsWith('.heic')) return 'image/heic';
//     if (n.endsWith('.pdf')) return 'application/pdf';
//     if (n.endsWith('.doc')) return 'application/msword';
//     if (n.endsWith('.docx')) {
//       return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
//     }
//     if (n.endsWith('.xls')) return 'application/vnd.ms-excel';
//     if (n.endsWith('.xlsx')) {
//       return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
//     }
//     if (n.endsWith('.txt')) return 'text/plain';
//     return 'application/octet-stream';
//   }
//
//   // ─────────────────────────── fallbacks / demo ────────────────────────
//   List<Conversation> _demoInbox() {
//     return [
//       Conversation(
//         id: 'c1',
//         peer: juliana,
//         lastMessage: Message(
//           id: 'm1',
//           conversationId: 'c1',
//           sender: juliana,
//           createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
//           type: MessageType.text,
//           text:
//           "If you complete Webdesign Task, you can start another task...",
//           attachments: const [],
//         ),
//         unreadCount: 0,
//       ),
//       Conversation(
//         id: 'c2',
//         peer: maria,
//         lastMessage: Message(
//           id: 'm2',
//           conversationId: 'c2',
//           sender: maria,
//           createdAt: DateTime.now().subtract(const Duration(hours: 3)),
//           type: MessageType.text,
//           text: "If you complete Webdesign Task, You can start...",
//           attachments: const [],
//         ),
//         unreadCount: 3,
//       ),
//     ];
//   }
//
//   List<Message> _demoMessages({
//     required String conversationId,
//     required OdooUser peer,
//   }) {
//     return [
//       Message(
//         id: 'cm1',
//         conversationId: conversationId,
//         sender: peer,
//         createdAt: DateTime.now().subtract(const Duration(hours: 2)),
//         type: MessageType.text,
//         text: "Hi 👋 I'll do that task now!",
//         attachments: const [],
//       ),
//       Message(
//         id: 'cm2',
//         conversationId: conversationId,
//         sender: peer,
//         createdAt: DateTime.now()
//             .subtract(const Duration(hours: 2))
//             .add(const Duration(minutes: 2)),
//         type: MessageType.attachment,
//         attachments: const [
//           MessageAttachment(
//               title: 'Webdesign tasks', subtitle: '2 files', icon: Icons.folder),
//           MessageAttachment(
//               title: 'Meeting docs',
//               subtitle: '3 files',
//               icon: Icons.folder_shared),
//         ],
//       ),
//     ];
//   }
//
//   List<UploadedAttachment> _synthUploaded(
//       String conversationId,
//       List<PickedAttachment> picked,
//       ) {
//     final now = DateTime.now().microsecondsSinceEpoch;
//     return List<UploadedAttachment>.generate(picked.length, (i) {
//       final p = picked[i];
//       final id = 'mock_${conversationId}_${now}_$i';
//       final mime = _guessMimeFromName(p.name);
//       return UploadedAttachment(
//         id: id,
//         name: p.name,
//         url: '',
//         mimeType: mime,
//         size: 0,
//         isImage: mime.startsWith('image/'),
//       );
//     });
//   }
//
//   Message _echoLocalFlexible({
//     required String conversationId,
//     required String text,
//     required OdooUser sender,
//     required bool hasAttachments,
//   }) {
//     return Message(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       conversationId: conversationId,
//       sender: sender,
//       createdAt: DateTime.now(),
//       type: hasAttachments ? MessageType.attachment : MessageType.text,
//       text: text.isNotEmpty ? text : null,
//       attachments: hasAttachments
//           ? const [
//         MessageAttachment(
//           title: 'Attachments',
//           subtitle: 'Sent',
//           icon: Icons.attach_file,
//         )
//       ]
//           : const [],
//     );
//   }
// }


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/conversation.dart';
import '../model/message.dart';
import '../model/user_model.dart';
import 'chat_repository.dart';

class MemoryChatRepository implements IChatRepository {
  // ─────────────────────────── ctor / config ───────────────────────────
  final String baseUrl;
  final String sessionCookie;
  final Duration httpTimeout;

  MemoryChatRepository({
    required this.baseUrl,
    required this.sessionCookie,
    this.httpTimeout = const Duration(seconds: 15),
  });

  Uri get _jsonRpcUri => Uri.parse('$baseUrl/web/dataset/call_kw');

  Map<String, String> get _headers => <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (sessionCookie.isNotEmpty) 'Cookie': sessionCookie,
  };
  Future<Map<String, dynamic>> _callKw({
    required String model,
    required String method,
    required List<dynamic> args,
    Map<String, dynamic>? kwargs,
  }) async {
    final payload = {
      "jsonrpc": "2.0",
      "method": "call",
      "params": {
        "model": model,
        "method": method,
        "args": args,
        "kwargs": kwargs ?? {},
      },
    };

    final res = await http
        .post(
      _jsonRpcUri,
      headers: _headers,
      body: jsonEncode(payload),
    )
        .timeout(httpTimeout);

    print('→ JSON-RPC $model.$method $_jsonRpcUri');
    print('🔹 Status: ${res.statusCode}');
    _printPreview(res.body);

    final parsed = jsonDecode(res.body) as Map<String, dynamic>;

    if (parsed.containsKey('error')) {
      final err = parsed['error'] as Map<String, dynamic>;
      final msg = (err['message'] ?? '').toString();
      final data = (err['data'] ?? {}) as Map<String, dynamic>;
      final name = (data['name'] ?? '').toString();
      final debug = (data['debug'] ?? '').toString();

      print('❌ JSON-RPC error: $msg ($name)');
      print('── Odoo debug ──');
      print(debug);
      print('── end debug ──');

      throw Exception('Odoo RPC error: $msg ($name)');
    }

    return parsed;
  }


  /// Create or reuse a direct-message channel with the given partner.
  /// `partnerId` = res.partner id, NOT user id.
  Future<Conversation> getOrCreateDirectChannel({
    required int partnerId,
    required String partnerName,
  }) async {
    try {
      // 1) Try to find an existing DM chat with this partner
      final searchParsed = await _callKw(
        model: 'mail.channel',
        method: 'search_read',
        args: [
          [
            ["channel_type", "=", "chat"],
            ["channel_partner_ids", "in", [partnerId]],
          ],
          [
            "id",
            "name",
            "channel_type",
            "last_message_date",
            "message_unread_counter",
            "description",
          ],
        ],
        kwargs: {
          "limit": 1,
          "order": "last_message_date desc",
          "context": {},
        },
      );

      final searchList = searchParsed['result'] as List<dynamic>? ?? [];
      Map<String, dynamic> ch;

      if (searchList.isNotEmpty && searchList.first is Map) {
        // Found existing channel
        ch = searchList.first as Map<String, dynamic>;
        print(
          'ℹ️ Reusing existing DM channel id=${ch['id']} for partner $partnerId',
        );
      } else {
        // 2) No existing → create new chat channel
        final createParsed = await _callKw(
          model: 'mail.channel',
          method: 'create',
          args: [
            {
              "channel_type": "chat",
              "name": partnerName,
              "channel_partner_ids": [
                [6, 0, [partnerId]] // replace members with this partner (+ current user automatically)
              ],
            }
          ],
        );

        final int newId = int.tryParse("${createParsed['result']}") ?? 0;
        if (newId == 0) {
          throw Exception('Failed to create DM channel');
        }

        print('ℹ️ Created new DM channel id=$newId for partner $partnerId');

        // 3) Read the channel back
        final readParsed = await _callKw(
          model: 'mail.channel',
          method: 'search_read',
          args: [
            [
              ["id", "=", newId],
            ],
            [
              "id",
              "name",
              "channel_type",
              "last_message_date",
              "message_unread_counter",
              "description",
            ],
          ],
          kwargs: {
            "limit": 1,
            "context": {},
          },
        );

        final readList = readParsed['result'] as List<dynamic>? ?? [];
        if (readList.isEmpty || readList.first is! Map) {
          throw Exception('Failed to load created channel $newId');
        }
        ch = readList.first as Map<String, dynamic>;
      }

      // ---- Build Conversation object from 'ch' ----
      final int id = int.tryParse("${ch['id']}") ?? 0;
      if (id == 0) throw Exception('Invalid channel id in response');

      final String name = (ch['name'] ?? partnerName).toString();
      final int unread =
          int.tryParse("${ch['message_unread_counter'] ?? 0}") ?? 0;

      final peer = OdooUser(
        uid: id, // you can later map this to real user/partner
        name: name,
        username: '',
        db: '',
        timezone: '',
        companyName: '',
      );

      final body = (ch['description'] ?? '').toString();
      final rawDate =
          ch['last_message_date'] ?? DateTime.now().toIso8601String();

      final lastMsg = Message(
        id: 'last_$id',
        conversationId: '$id',
        sender: peer,
        createdAt: _parseDate(rawDate),
        type: MessageType.text,
        text: _stripHtml(body),
        attachments: const [],
      );

      return Conversation(
        id: '$id',
        peer: peer,
        lastMessage: lastMsg,
        unreadCount: unread,
      );
    } catch (e, st) {
      print('❌ getOrCreateDirectChannel error: $e');
      print(st);

      // Hard fallback – local-only conversation so UI still works
      final peer = OdooUser(
        uid: partnerId,
        name: partnerName,
        username: '',
        db: '',
        timezone: '',
        companyName: '',
      );

      return Conversation(
        id: 'local_$partnerId',
        peer: peer,
        lastMessage: Message(
          id: 'seed',
          conversationId: 'local_$partnerId',
          sender: peer,
          createdAt: DateTime.now(),
          type: MessageType.text,
          text: '',
          attachments: const [],
        ),
        unreadCount: 0,
      );
    }
  }

  // ─────────────────────────── demo users ──────────────────────────────
  final OdooUser me = OdooUser(
    uid: 999,
    name: "John",
    username: "john@test.com",
    db: "",
    timezone: "",
    companyName: "",
  );

  final OdooUser juliana = OdooUser(
    uid: 1,
    name: "Juliana Wills",
    username: "juliana@test.com",
    db: "",
    timezone: "",
    companyName: "",
  );

  final OdooUser maria = OdooUser(
    uid: 2,
    name: "Maria Anderson",
    username: "maria@test.com",
    db: "",
    timezone: "",
    companyName: "",
  );
  @override
  Future<List<OdooUser>> fetchChatPartners() async {
    try {
      final payload = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "res.partner",
          "method": "search_read",
          "args": [
            [
              ["user_ids", "!=", false]   // ✔ only partners with user accounts
            ],
          ],
          "kwargs": {
            "fields": ["id", "name", "email"],
            "limit": 80,
            "order": "name asc",
          },
        },
      };

      final res = await http
          .post(
        _jsonRpcUri,
        headers: _headers,
        body: jsonEncode(payload),
      )
          .timeout(httpTimeout);

      print('→ JSON-RPC fetchChatPartners $_jsonRpcUri');
      print('🔹 Status: ${res.statusCode}');
      _printPreview(res.body);

      final parsed = jsonDecode(res.body) as Map<String, dynamic>;

      if (parsed.containsKey('error')) {
        print("❌ fetchChatPartners error: ${parsed['error']}");
        return [];
      }

      final List data = parsed['result'] ?? [];
      final List<OdooUser> users = [];

      for (final p in data) {
        if (p is! Map) continue;
        final m = p as Map<String, dynamic>;

        final id = m['id'] is int ? m['id'] : int.tryParse('${m['id']}') ?? 0;
        if (id == 0) continue;

        users.add(
          OdooUser(
            uid: id,
            name: m['name']?.toString() ?? "",
            username: m['email']?.toString() ?? "",
            db: "",
            timezone: "",
            companyName: "",
          ),
        );
      }

      print("✅ partners fetched: ${users.length}");
      return users;
    } catch (e, st) {
      print("❌ fetchChatPartners exception: $e");
      print(st);
      return [];
    }
  }


  @override
  Future<List<Conversation>> fetchInbox({bool useGet = false}) async {
    final uri = Uri.parse('$baseUrl/api/chat/inbox');

    try {
      final http.Response res = useGet
          ? await http.get(uri, headers: _headers).timeout(httpTimeout)
          : await http
          .post(
        uri,
        headers: _headers,
        body: jsonEncode({"jsonrpc": "2.0", "params": {}}),
      )
          .timeout(httpTimeout);

      print('→ ${useGet ? "GET" : "POST"} $uri');
      print('🔹 Status: ${res.statusCode}');

      final ct = res.headers['content-type'] ?? '';
      final bodyTrim = res.body.trimLeft();
      final looksHtml =
          bodyTrim.startsWith('<!DOCTYPE') || bodyTrim.startsWith('<html');

      if (res.statusCode != 200 || !ct.contains('application/json') || looksHtml) {
        _printPreview(res.body);
        print('! Non-JSON or error response. Falling back to Odoo JSON-RPC inbox.');
        return await _fetchInboxFromOdoo();     // ← THIS
      }

      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️ JSON parse failed: $e');
        _printPreview(res.body);
        return await _fetchInboxFromOdoo();
      }

      final result = (parsed['result'] ?? {}) as Map<String, dynamic>;
      final list = (result['conversations'] ?? []) as List;

      if (list.isEmpty) {
        print('ℹ️ API returned 0 conversations. Falling back to Odoo JSON-RPC inbox.');
        return await _fetchInboxFromOdoo();
      }

      return list.map<Conversation>((raw) => _parseConversation(raw)).toList();
    } catch (e, st) {
      print('❌ fetchInbox error: $e');
      print(st);
      return await _fetchInboxFromOdoo();
    }
  }


  Future<List<Conversation>> _fetchInboxFromOdoo() async {
    try {
      // Standard Odoo JSON-RPC search_read on mail.channel
      final payload = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "mail.channel",
          "method": "search_read",
          "args": [
            [
              ["channel_type", "=", "chat"],  // ← only direct messages
            ]
          ],
          "kwargs": {
            "fields": [
              "id",
              "name",
              "channel_type",
              "last_message_date",
              "message_unread_counter",
              "description",
            ],
            "limit": 40,
            "order": "last_message_date desc",
            "context": {},
          },
        },
      };

      final res = await http
          .post(
        _jsonRpcUri, // https://erp.kendroo.io/web/dataset/call_kw
        headers: _headers,
        body: jsonEncode(payload),
      )
          .timeout(httpTimeout);

      print('→ JSON-RPC inbox (mail.channel chat) $_jsonRpcUri');
      print('🔹 Status: ${res.statusCode}');
      _printPreview(res.body);

      final parsed = jsonDecode(res.body) as Map<String, dynamic>;

      // If Odoo returns error
      if (parsed.containsKey('error')) {
        final err = parsed['error'] as Map<String, dynamic>;
        final msg = (err['message'] ?? '').toString();
        final data = (err['data'] ?? {}) as Map<String, dynamic>;
        final name = (data['name'] ?? '').toString();
        final debug = (data['debug'] ?? '').toString();

        print('❌ Odoo mail.channel search_read error: $msg ($name)');
        print('── Odoo debug ──');
        print(debug);
        print('── end debug ──');

        // As a backup, you *can* still fall back to init_messaging or demo
        return _demoInbox();
      }

      // search_read → result is a List[dict]
      final result = parsed['result'] as List<dynamic>? ?? [];
      print('ℹ️ mail.channel(chat) count: ${result.length}');

      if (result.isEmpty) {
        print('ℹ️ No DM channels returned. Using demo inbox.');
        return _demoInbox();
      }

      final List<Conversation> convs = [];

      for (final ch in result) {
        if (ch is! Map) continue;
        final m = ch as Map<String, dynamic>;

        print(
          '  → DM channel id=${m['id']} '
              'name=${m['name']} '
              'type=${m['channel_type']} '
              'unread=${m['message_unread_counter']}',
        );

        final int id = int.tryParse("${m['id']}") ?? 0;
        if (id == 0) continue;

        final String name = (m['name'] ?? 'Chat $id').toString();

        final int unread = int.tryParse(
          "${m['message_unread_counter'] ?? 0}",
        ) ?? 0;

        final peer = OdooUser(
          uid: id,                // for now: use channel id; later you can map to partner
          name: name,
          username: '',
          db: '',
          timezone: '',
          companyName: '',
        );

        final rawBody = m['description'] ?? '';
        final String body = rawBody.toString();

        final rawDate = m['last_message_date'] ??
            DateTime.now().toIso8601String();

        final lastMsg = Message(
          id: 'last_$id',
          conversationId: '$id',
          sender: peer,
          createdAt: _parseDate(rawDate),
          type: MessageType.text,
          text: _stripHtml(body),
          attachments: const [],
        );

        convs.add(
          Conversation(
            id: '$id',
            peer: peer,
            lastMessage: lastMsg,
            unreadCount: unread,
          ),
        );
      }

      if (convs.isEmpty) {
        print('ℹ️ Parsed 0 valid DM channels, using demo inbox.');
        return _demoInbox();
      }

      print('✅ Built ${convs.length} DM conversations from mail.channel');
      return convs;
    } catch (e, st) {
      print('❌ _fetchInboxFromOdoo (mail.channel chat) error: $e');
      print(st);
      return _demoInbox();
    }
  }



  // ─────────────────────────── messages ────────────────────────────────
  @override
  Future<List<Message>> fetchMessages(
      String conversationId,
      OdooUser peer, {
        bool useGet = false,
      }) async {
    final uri = Uri.parse('$baseUrl/api/chat/messages');

    try {
      final http.Response res = useGet
          ? await http
          .get(
        uri.replace(queryParameters: {'conversation_id': conversationId}),
        headers: _headers,
      )
          .timeout(httpTimeout)
          : await http
          .post(
        uri,
        headers: _headers,
        body: jsonEncode({
          "jsonrpc": "2.0",
          "params": {"conversation_id": conversationId}
        }),
      )
          .timeout(httpTimeout);

      print('→ ${useGet ? "GET" : "POST"} $uri');
      print('🔹 Status: ${res.statusCode}');

      final ct = res.headers['content-type'] ?? '';
      final bodyTrim = res.body.trimLeft();
      final looksHtml =
          bodyTrim.startsWith('<!DOCTYPE') || bodyTrim.startsWith('<html');

      if (res.statusCode != 200 || !ct.contains('application/json') || looksHtml) {
        _printPreview(res.body);
        print('⚠️ Non-JSON or error response. Falling back to Odoo JSON-RPC messages.');
        return await _fetchMessagesFromOdoo(conversationId, peer);
      }

      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️ JSON parse failed: $e');
        _printPreview(res.body);
        return await _fetchMessagesFromOdoo(conversationId, peer);
      }

      // Expected: { "result": { "messages": [...] } }
      final result = (parsed['result'] ?? {}) as Map<String, dynamic>;
      final list = (result['messages'] ?? []) as List;

      if (list.isEmpty) {
        print('ℹ️ API returned 0 messages. Falling back to Odoo JSON-RPC messages.');
        return await _fetchMessagesFromOdoo(conversationId, peer);
      }

      return list.map<Message>((raw) => _parseMessage(raw, peer)).toList();
    } catch (e, st) {
      print('❌ fetchMessages error: $e');
      print(st);
      return await _fetchMessagesFromOdoo(conversationId, peer);
    }
  }

  /// Fallback: load messages directly from Odoo (mail.channel.channel_fetch_message)
  Future<List<Message>> _fetchMessagesFromOdoo(
      String conversationId,
      OdooUser peer,
      ) async {
    final int channelId = _extractChannelId(conversationId);
    if (channelId == 0) {
      print('⚠️ Invalid channel id: $conversationId, using demo messages.');
      return _demoMessages(conversationId: conversationId, peer: peer);
    }

    try {
      final payload = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "mail.channel",
          "method": "channel_fetch_message",
          "args": [
            [channelId],
            0, // last_id
            40 // limit
          ],
          "kwargs": {},
        }
      };

      final res = await http
          .post(_jsonRpcUri, headers: _headers, body: jsonEncode(payload))
          .timeout(httpTimeout);

      print('→ JSON-RPC messages $_jsonRpcUri');
      print('🔹 Status: ${res.statusCode}');
      _printPreview(res.body);

      final parsed = jsonDecode(res.body) as Map<String, dynamic>;
      final list = parsed['result'] as List<dynamic>? ?? [];

      if (list.isEmpty) {
        print('ℹ️ Odoo JSON-RPC returned 0 messages, using demo.');
        return _demoMessages(conversationId: '$channelId', peer: peer);
      }

      final messages = <Message>[];
      int lastMsgId = 0;

      for (final raw in list) {
        final msg = _parseOdooMailMessage(
          raw as Map<String, dynamic>,
          peer,
          '$channelId',
        );
        messages.add(msg);
        final idInt = int.tryParse(msg.id) ?? 0;
        if (idInt > lastMsgId) lastMsgId = idInt;
      }

      // Mark channel as seen via write (last_seen_message_id)
      if (lastMsgId > 0) {
        await _markChannelSeen(channelId, lastMsgId);
      }

      return messages;
    } catch (e, st) {
      print('❌ _fetchMessagesFromOdoo error: $e');
      print(st);
      return _demoMessages(conversationId: '$channelId', peer: peer);
    }
  }

  Future<void> _markChannelSeen(int channelId, int lastMessageId) async {
    try {
      final payload = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "mail.channel",
          "method": "write",
          "args": [
            [channelId],
            {"last_seen_message_id": lastMessageId}
          ],
          "kwargs": {},
        }
      };

      final res = await http
          .post(_jsonRpcUri, headers: _headers, body: jsonEncode(payload))
          .timeout(httpTimeout);

      print('→ JSON-RPC mark seen (write) for channel $channelId');
      print('🔹 Status: ${res.statusCode}');
      _printPreview(res.body);
    } catch (e) {
      print('⚠️ _markChannelSeen error: $e');
    }
  }

  int _extractChannelId(String conversationId) {
    // Handles "16" or "discuss.channel_16"
    final digits = RegExp(r'(\d+)$').firstMatch(conversationId);
    if (digits == null) return int.tryParse(conversationId) ?? 0;
    return int.tryParse(digits.group(1)!) ?? 0;
  }

  // ─────────────────────────── upload ──────────────────────────────────
  @override
  Future<List<UploadedAttachment>> uploadAttachments({
    required String conversationId,
    required List<PickedAttachment> picked,
  }) async {
    final uploadUrl = Uri.parse('$baseUrl/api/chat/upload');

    try {
      final req = http.MultipartRequest('POST', uploadUrl);
      if (sessionCookie.isNotEmpty) req.headers['Cookie'] = sessionCookie;

      req.fields['conversation_id'] = conversationId;

      for (final p in picked) {
        req.files.add(await http.MultipartFile.fromPath(
          'files',
          p.path,
          filename: p.name,
        ));
      }

      final resp = await req.send().timeout(httpTimeout);
      final body = await resp.stream.bytesToString();

      print('→ MULTIPART $uploadUrl');
      print('🔹 Status: ${resp.statusCode}');

      final ct = resp.headers['content-type'] ?? '';
      final looksHtml =
          body.trimLeft().startsWith('<!DOCTYPE') || body.trimLeft().startsWith('<html');

      if (resp.statusCode != 200 || !ct.contains('application/json') || looksHtml) {
        _printPreview(body);
        print('⚠️ Non-JSON or error on upload. Returning synthesized IDs.');
        return _synthUploaded(conversationId, picked);
      }

      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️ JSON parse failed (upload): $e');
        _printPreview(body);
        return _synthUploaded(conversationId, picked);
      }

      final result = (parsed['result'] ?? {}) as Map<String, dynamic>;
      final list = (result['attachments'] ?? []) as List;

      if (list.isEmpty) {
        print('ℹ️ API returned 0 uploaded attachments. Returning synthesized IDs.');
        return _synthUploaded(conversationId, picked);
      }

      return list.map<UploadedAttachment>((raw) {
        final id = '${raw['id'] ?? ''}';
        final name = '${raw['name'] ?? 'Attachment'}';
        final url = raw['url']?.toString() ?? '';
        final mime = raw['mime']?.toString() ?? raw['mimeType']?.toString() ?? '';
        final size = (raw['size'] is num) ? (raw['size'] as num).toInt() : 0;
        final isImage = mime.startsWith('image/');

        return UploadedAttachment(
          id: id.isNotEmpty ? id : 'srv_${DateTime.now().microsecondsSinceEpoch}',
          name: name,
          url: url,
          mimeType: mime,
          size: size,
          isImage: isImage,
        );
      }).toList();
    } catch (e, st) {
      print('❌ uploadAttachments error: $e');
      print(st);
      return _synthUploaded(conversationId, picked);
    }
  }

  // ─────────────────────────── send message ────────────────────────────
  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String text,
    required OdooUser sender,
    List<String>? attachmentIds,
  }) async {
    final uri = Uri.parse('$baseUrl/api/chat/send');

    try {
      final res = await http
          .post(
        uri,
        headers: _headers,
        body: jsonEncode({
          "jsonrpc": "2.0",
          "params": {
            "conversation_id": conversationId,
            "text": text,
            if (attachmentIds != null && attachmentIds.isNotEmpty)
              "attachments": attachmentIds,
          }
        }),
      )
          .timeout(httpTimeout);

      print('→ POST $uri');
      print('🔹 Status: ${res.statusCode}');

      final ct = res.headers['content-type'] ?? '';
      final bodyTrim = res.body.trimLeft();
      final looksHtml =
          bodyTrim.startsWith('<!DOCTYPE') || bodyTrim.startsWith('<html');

      if (res.statusCode != 200 || !ct.contains('application/json') || looksHtml) {
        _printPreview(res.body);
        print('⚠️ Non-JSON or error response. Falling back to Odoo JSON-RPC send.');
        return await _sendMessageViaOdoo(
          conversationId: conversationId,
          text: text,
          sender: sender,
          hasAttachments: (attachmentIds?.isNotEmpty ?? false),
        );
      }

      final parsed = jsonDecode(res.body) as Map<String, dynamic>;
      final result = (parsed['result'] ?? {}) as Map<String, dynamic>;
      final raw = result['message'];

      if (raw == null) {
        print('ℹ️ API returned no message. Using Odoo JSON-RPC send.');
        return await _sendMessageViaOdoo(
          conversationId: conversationId,
          text: text,
          sender: sender,
          hasAttachments: (attachmentIds?.isNotEmpty ?? false),
        );
      }

      return _parseMessage(raw, sender);
    } catch (e, st) {
      print('❌ sendMessage error: $e');
      print(st);
      return await _sendMessageViaOdoo(
        conversationId: conversationId,
        text: text,
        sender: sender,
        hasAttachments: (attachmentIds?.isNotEmpty ?? false),
      );
    }
  }

  /// Fallback: use Odoo JSON-RPC (mail.channel.message_post + write for seen)
  Future<Message> _sendMessageViaOdoo({
    required String conversationId,
    required String text,
    required OdooUser sender,
    required bool hasAttachments,
  }) async {
    final int channelId = _extractChannelId(conversationId);
    if (channelId == 0) {
      print('⚠️ Invalid channel id in _sendMessageViaOdoo, echoing local.');
      return _echoLocalFlexible(
        conversationId: conversationId,
        text: text,
        sender: sender,
        hasAttachments: hasAttachments,
      );
    }

    try {
      // 1) send message via message_post
      final payload = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "mail.channel",
          "method": "message_post",
          "args": [
            [channelId],
            {
              "body": text,
              "message_type": "comment",
              "subtype_xmlid": "mail.mt_comment",
            }
          ],
          "kwargs": {},
        }
      };

      final res = await http
          .post(_jsonRpcUri, headers: _headers, body: jsonEncode(payload))
          .timeout(httpTimeout);

      print('→ JSON-RPC send message_post for channel $channelId');
      print('🔹 Status: ${res.statusCode}');
      _printPreview(res.body);

      final parsed = jsonDecode(res.body) as Map<String, dynamic>;
      final msgId = (parsed['result'] as int?) ?? 0;

      if (msgId > 0) {
        // 2) mark seen using write (as you requested)
        await _markChannelSeen(channelId, msgId);

        return Message(
          id: msgId.toString(),
          conversationId: '$channelId',
          sender: sender,
          createdAt: DateTime.now(),
          type: hasAttachments ? MessageType.attachment : MessageType.text,
          text: text.isNotEmpty ? text : null,
          attachments: hasAttachments
              ? [
            MessageAttachment(
              title: 'Attachments',
              subtitle: 'Sent',
              icon: Icons.attach_file,
            )
          ]
              : const [],
        );
      }

      print('ℹ️ message_post did not return id, echoing local.');
      return _echoLocalFlexible(
        conversationId: '$channelId',
        text: text,
        sender: sender,
        hasAttachments: hasAttachments,
      );
    } catch (e, st) {
      print('❌ _sendMessageViaOdoo error: $e');
      print(st);
      return _echoLocalFlexible(
        conversationId: '$channelId',
        text: text,
        sender: sender,
        hasAttachments: hasAttachments,
      );
    }
  }

  // ─────────────────────────── helpers ─────────────────────────────────
  void _printPreview(String body) {
    final len = body.length > 400 ? 400 : body.length;
    final preview = body.substring(0, len);
    print('🔹 Body preview (${len} chars):\n$preview');
  }

  // Parse message from your custom /api/chat/*
  Conversation _parseConversation(Map raw) {
    final id = '${raw['id'] ?? ''}';
    final unread = (raw['unread'] is num) ? (raw['unread'] as num).toInt() : 0;

    final peerRaw = (raw['peer'] ?? {}) as Map<String, dynamic>;
    final peer = _parseOdooUser(peerRaw);

    final lastRaw = (raw['last_message'] ?? {}) as Map<String, dynamic>;
    final last = _parseMessage(lastRaw, peer);

    if (id.isEmpty || last.id.isEmpty || peer.uid == 0) {
      return _demoInbox().first;
    }

    return Conversation(
      id: id,
      peer: peer,
      lastMessage: last,
      unreadCount: unread,
    );
  }

  Message _parseMessage(Map raw, OdooUser fallbackSender) {
    final id = '${raw['id'] ?? ''}';
    final convId = '${raw['conversation_id'] ?? ''}';
    final typeStr = '${raw['type'] ?? 'text'}'.toLowerCase();
    final type =
    (typeStr == 'attachment') ? MessageType.attachment : MessageType.text;

    OdooUser sender;
    if (raw['sender'] is Map) {
      sender = _parseOdooUser(raw['sender'] as Map<String, dynamic>);
      if (sender.uid == 0) sender = fallbackSender;
    } else {
      sender = fallbackSender;
    }

    final created = _parseDate(raw['created_at']);
    final text = raw['text']?.toString();

    final atts = <MessageAttachment>[];
    if (raw['attachments'] is List) {
      for (final a in (raw['attachments'] as List)) {
        if (a is Map) {
          atts.add(
            MessageAttachment(
              title: '${a['title'] ?? 'Attachment'}',
              subtitle: '${a['subtitle'] ?? ''}',
              icon: Icons.attach_file,
            ),
          );
        }
      }
    }

    return Message(
      id: id,
      conversationId: convId,
      sender: sender,
      createdAt: created,
      type: type,
      text: text,
      attachments: atts,
    );
  }

  /// Parse mail.message dict from Odoo JSON-RPC
  Message _parseOdooMailMessage(
      Map<String, dynamic> raw,
      OdooUser fallbackPeer,
      String conversationId,
      ) {
    final id = '${raw['id'] ?? ''}';

    // author_id: [id, name]
    OdooUser sender = fallbackPeer;
    if (raw['author_id'] is List && (raw['author_id'] as List).length >= 2) {
      final lst = raw['author_id'] as List;
      final int uid = (lst[0] is int) ? lst[0] as int : int.tryParse('${lst[0]}') ?? 0;
      final String name = lst[1].toString();
      sender = OdooUser(
        uid: uid,
        name: name,
        username: '',
        db: '',
        timezone: '',
        companyName: '',
      );
    }

    final dateRaw = raw['date'];
    final created = _parseDate(dateRaw);

    String bodyHtml = raw['body']?.toString() ?? '';
    final text = _stripHtml(bodyHtml);

    final List atIds = raw['attachment_ids'] as List? ?? const [];
    final bool hasAttachments = atIds.isNotEmpty;

    return Message(
      id: id,
      conversationId: conversationId,
      sender: sender,
      createdAt: created,
      type: hasAttachments ? MessageType.attachment : MessageType.text,
      text: text.isNotEmpty ? text : null,
      attachments: hasAttachments
          ? const [
        MessageAttachment(
          title: 'Attachments',
          subtitle: '',
          icon: Icons.attach_file,
        )
      ]
          : const [],
    );
  }

  OdooUser _parseOdooUser(Map<String, dynamic> m) {
    return OdooUser(
      uid: (m['uid'] is num)
          ? (m['uid'] as num).toInt()
          : (int.tryParse('${m['uid'] ?? 0}') ?? 0),
      name: '${m['name'] ?? ''}',
      username: '${m['username'] ?? ''}',
      db: '${m['db'] ?? ''}',
      timezone: m['timezone']?.toString() ?? m['tz']?.toString() ?? '',
      companyName: m['companyName']?.toString() ??
          m['company_name']?.toString() ??
          m['company']?.toString() ??
          '',
    );
  }

  DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    if (v is String) {
      try {
        return DateTime.parse(v).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  String _guessMimeFromName(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.gif')) return 'image/gif';
    if (n.endsWith('.heic')) return 'image/heic';
    if (n.endsWith('.pdf')) return 'application/pdf';
    if (n.endsWith('.doc')) return 'application/msword';
    if (n.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (n.endsWith('.xls')) return 'application/vnd.ms-excel';
    if (n.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    if (n.endsWith('.txt')) return 'text/plain';
    return 'application/octet-stream';
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  // ─────────────────────────── fallbacks / demo ────────────────────────
  List<Conversation> _demoInbox() {
    return [
      Conversation(
        id: 'c1',
        peer: juliana,
        lastMessage: Message(
          id: 'm1',
          conversationId: 'c1',
          sender: juliana,
          createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          type: MessageType.text,
          text:
          "If you complete Webdesign Task, you can start another task...",
          attachments: const [],
        ),
        unreadCount: 0,
      ),
      Conversation(
        id: 'c2',
        peer: maria,
        lastMessage: Message(
          id: 'm2',
          conversationId: 'c2',
          sender: maria,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          type: MessageType.text,
          text: "If you complete Webdesign Task, You can start...",
          attachments: const [],
        ),
        unreadCount: 3,
      ),
    ];
  }

  List<Message> _demoMessages({
    required String conversationId,
    required OdooUser peer,
  }) {
    return [
      Message(
        id: 'cm1',
        conversationId: conversationId,
        sender: peer,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        type: MessageType.text,
        text: "Hi 👋 I'll do that task now!",
        attachments: const [],
      ),
      Message(
        id: 'cm2',
        conversationId: conversationId,
        sender: peer,
        createdAt: DateTime.now()
            .subtract(const Duration(hours: 2))
            .add(const Duration(minutes: 2)),
        type: MessageType.attachment,
        attachments: const [
          MessageAttachment(
            title: 'Webdesign tasks',
            subtitle: '2 files',
            icon: Icons.folder,
          ),
          MessageAttachment(
            title: 'Meeting docs',
            subtitle: '3 files',
            icon: Icons.folder_shared,
          ),
        ],
      ),
    ];
  }

  List<UploadedAttachment> _synthUploaded(
      String conversationId,
      List<PickedAttachment> picked,
      ) {
    final now = DateTime.now().microsecondsSinceEpoch;
    return List<UploadedAttachment>.generate(picked.length, (i) {
      final p = picked[i];
      final id = 'mock_${conversationId}_${now}_$i';
      final mime = _guessMimeFromName(p.name);
      return UploadedAttachment(
        id: id,
        name: p.name,
        url: '',
        mimeType: mime,
        size: 0,
        isImage: mime.startsWith('image/'),
      );
    });
  }

  Message _echoLocalFlexible({
    required String conversationId,
    required String text,
    required OdooUser sender,
    required bool hasAttachments,
  }) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      sender: sender,
      createdAt: DateTime.now(),
      type: hasAttachments ? MessageType.attachment : MessageType.text,
      text: text.isNotEmpty ? text : null,
      attachments: hasAttachments
          ? const [
        MessageAttachment(
          title: 'Attachments',
          subtitle: 'Sent',
          icon: Icons.attach_file,
        )
      ]
          : const [],
    );
  }
}
