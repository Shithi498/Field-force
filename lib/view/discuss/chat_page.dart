//
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import '../../model/conversation.dart';
// import '../../model/message.dart';
// import '../../model/user_model.dart';
// import '../../provider/auth_provider.dart';
// import '../../provider/chat_provider.dart';
//
//
// class ChatPage extends StatefulWidget {
//   final Conversation? conv;
//   const ChatPage({super.key, this.conv});
//
//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _ctrl = TextEditingController();
//   final ScrollController _scroll = ScrollController();
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     _scroll.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final chat = context.watch<ChatProvider>();
//     final auth = context.watch<AuthProvider>();
//     final messages = chat.messagesFor(widget.conv!.id);
//
//     if (auth.user == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(widget.conv!.peer.name),
//           actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))],
//         ),
//         body: const Center(child: Text('Please log in to continue…')),
//       );
//     }
//     final me = auth.user!;
//     final w = MediaQuery.of(context).size.width;
//
//     final horizontal = w < 340 ? 8.0 : (w < 420 ? 12.0 : 16.0);
//     final vertical   = w < 340 ? 6.0 : 12.0;
//     return Scaffold(
//       appBar:
//       // AppBar(
//       //   leadingWidth: 24,
//       //   titleSpacing: 0,
//       //   title: Row(
//       //     children: [
//       //       const SizedBox(width: 8),
//       //       const CircleAvatar(radius: 16, child: Text('RA')),
//       //       const SizedBox(width: 12),
//       //       Column(
//       //         crossAxisAlignment: CrossAxisAlignment.start,
//       //         children: [
//       //           Text(widget.conv!.peer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
//       //           Text(
//       //             '2hrs ago',
//       //             style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
//       //           ),
//       //         ],
//       //       ),
//       //     ],
//       //   ),
//       //   actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))],
//       // ),
//       AppBar(
//         leadingWidth: 24,
//         titleSpacing: 0,
//         title: LayoutBuilder(
//           builder: (context, c) {
//             final w = c.maxWidth;
//             final isNarrow = w < 320;
//
//             final avatarRadius = isNarrow ? 14.0 : 16.0;
//             final nameSize     = isNarrow ? 14.0 : 16.0;
//             final subtitleSize = isNarrow ? 10.0 : 12.0;
//             final leftPadding  = isNarrow ? 4.0 : 8.0;
//             final gap          = isNarrow ? 8.0 : 12.0;
//
//             return Row(
//               children: [
//                 SizedBox(width: leftPadding),
//                 CircleAvatar(
//                   radius: avatarRadius,
//                   child: Text(
//                     'RA',
//                     style: TextStyle(fontSize: isNarrow ? 12 : 14),
//                   ),
//                 ),
//                 SizedBox(width: gap),
//
//                 // Take remaining width for texts
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.conv!.peer.name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: nameSize,
//                         ),
//                       ),
//                     //  if (!isNarrow) // hide time on very small phones
//                         Text(
//                           '2hrs ago',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: Colors.grey[600],
//                             fontSize: subtitleSize,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//         actions: [
//           IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.close),
//           ),
//         ],
//       ),
//
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scroll,
//               padding: EdgeInsets.symmetric(horizontal:  horizontal, vertical: vertical),
//               itemCount: messages.length + (chat.isTyping ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index >= messages.length) {
//                   return const _TypingBubble();
//                 }
//                 final m = messages[index];
//                 final isMe = m.sender.uid == me.uid;
//
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   child: Align(
//                     alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                     child: ConstrainedBox(
//                       constraints: const BoxConstraints(maxWidth: 320),
//                       child: DecoratedBox(
//                         decoration: BoxDecoration(
//                           color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey[100],
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: _MessageContent(message: m, isMe: isMe),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const Divider(height: 1),
//
//           // Composer now sends both text and attachments via provider
//           _Composer(
//             controller: _ctrl,
//             convId: widget.conv!.id,
//             me: me,
//             onSent: () {
//               // optional: nudge scroll after a send
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 if (_scroll.hasClients) {
//                   _scroll.animateTo(
//                     _scroll.position.maxScrollExtent + 120,
//                     duration: const Duration(milliseconds: 250),
//                     curve: Curves.easeOut,
//                   );
//                 }
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // class _MessageContent extends StatelessWidget {
// //   final Message message;
// //   final bool isMe;
// //   const _MessageContent({required this.message, required this.isMe});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final textStyle = TextStyle(
// //       color: isMe ? Colors.white : Colors.black87,
// //       height: 1.35,
// //     );
// //
// //     if (message.type == MessageType.text) {
// //       return Text(message.text ?? '', style: textStyle);
// //     }
// //
// //     // Attachment block (two square cards style; adapts to list length)
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         if ((message.text ?? '').isNotEmpty)
// //           Padding(
// //             padding: const EdgeInsets.only(bottom: 10),
// //             child: Text(message.text!, style: textStyle),
// //           ),
// //         Wrap(
// //           spacing: 8,
// //           runSpacing: 8,
// //           children: message.attachments
// //               .map(
// //                 (a) => Container(
// //               width: 140,
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: isMe ? Colors.white24 : Colors.white,
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: Colors.black12),
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Icon(a.icon, size: 28),
// //                   const SizedBox(height: 8),
// //                   Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
// //                   Text(
// //                     a.subtitle,
// //                     style: TextStyle(color: isMe ? Colors.white70 : Colors.black54),
// //                     maxLines: 1,
// //                     overflow: TextOverflow.ellipsis,
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           )
// //               .toList(),
// //         ),
// //         const SizedBox(height: 6),
// //         Text(
// //           '${DateFormat('dd/MM/yyyy').format(message.createdAt)}  •  ${DateFormat('hh:mm a').format(message.createdAt)}',
// //           style: textStyle.copyWith(fontSize: 12, color: isMe ? Colors.white70 : Colors.black54),
// //         ),
// //       ],
// //     );
// //   }
// // }
//
// // class _MessageContent extends StatelessWidget {
// //   final Message message;
// //   final bool isMe;
// //   const _MessageContent({required this.message, required this.isMe});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final textScaler = MediaQuery.textScalerOf(context);
// //
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         final w = constraints.maxWidth;
// //
// //         // Base font sizes tuned for mobile
// //         final baseFont = w < 320 ? 13.0 : (w < 380 ? 14.0 : 15.0);
// //         final timeFont = w < 320 ? 11.0 : 12.0;
// //
// //         final textStyle = TextStyle(
// //           color: isMe ? Colors.white : Colors.black87,
// //           height: 1.35,
// //           fontSize: baseFont,
// //         );
// //
// //         if (message.type == MessageType.text ||
// //             (message.attachments.isEmpty && (message.text ?? '').isNotEmpty)) {
// //           return Text(
// //             message.text ?? '',
// //             style: textStyle,
// //             textScaler: textScaler,
// //           );
// //         }
// //
// //         // --- Attachment block ---
// //
// //         // Compute card width based on available width (for phones)
// //         // Example: ~2 cards per row on normal phones, 3 on wide.
// //         final cardsPerRow = w < 260
// //             ? 1
// //             : (w < 400 ? 2 : 3); // adjust if you want fewer / more columns
// //         final horizontalSpacing = 8.0;
// //         final totalSpacing = horizontalSpacing * (cardsPerRow - 1);
// //         final cardWidth =
// //             (w - totalSpacing).clamp(120.0, 200.0) / cardsPerRow; // min/max guard
// //
// //         return Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             if ((message.text ?? '').isNotEmpty)
// //               Padding(
// //                 padding: const EdgeInsets.only(bottom: 10),
// //                 child: Text(
// //                   message.text!,
// //                   style: textStyle,
// //                   textScaler: textScaler,
// //                 ),
// //               ),
// //             Wrap(
// //               spacing: horizontalSpacing,
// //               runSpacing: 8,
// //               children: message.attachments
// //                   .map(
// //                     (a) => Container(
// //                   width: cardWidth,
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     color: isMe ? Colors.white24 : Colors.white,
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(color: Colors.black12),
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Icon(a.icon, size: w < 320 ? 22 : 28),
// //                       const SizedBox(height: 8),
// //                       Text(
// //                         a.title,
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                         style: TextStyle(
// //                           fontWeight: FontWeight.w600,
// //                           fontSize: baseFont,
// //                         ),
// //                         textScaler: textScaler,
// //                       ),
// //                       const SizedBox(height: 2),
// //                       Text(
// //                         a.subtitle,
// //                         style: TextStyle(
// //                           color: isMe ? Colors.white70 : Colors.black54,
// //                           fontSize: baseFont - 1,
// //                         ),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                         textScaler: textScaler,
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               )
// //                   .toList(),
// //             ),
// //             const SizedBox(height: 6),
// //             Text(
// //               '${DateFormat('dd/MM/yyyy').format(message.createdAt)}  •  ${DateFormat('hh:mm a').format(message.createdAt)}',
// //               style: textStyle.copyWith(
// //                 fontSize: timeFont,
// //                 color: isMe ? Colors.white70 : Colors.black54,
// //               ),
// //               textScaler: textScaler,
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// // }
//
// class _MessageContent extends StatelessWidget {
//   final Message message;
//   final bool isMe;
//   const _MessageContent({required this.message, required this.isMe});
//
//   @override
//   Widget build(BuildContext context) {
//     final textScaler = MediaQuery.textScalerOf(context);
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final w = constraints.maxWidth;
//
//         // Base font sizes tuned for mobile
//         final baseFont = w < 320 ? 13.0 : (w < 380 ? 14.0 : 15.0);
//         final timeFont = w < 320 ? 11.0 : 12.0;
//
//         final textStyle = TextStyle(
//           color: isMe ? Colors.white : Colors.black87,
//           height: 1.35,
//           fontSize: baseFont,
//         );
//
//         if (message.type == MessageType.text ||
//             (message.attachments.isEmpty && (message.text ?? '').isNotEmpty)) {
//           return Text(
//             message.text ?? '',
//             style: textStyle,
//             textScaler: textScaler,
//           );
//         }
//
//         // --- Attachment block ---
//
//         // Compute card width based on available width (for phones)
//         // Example: ~2 cards per row on normal phones, 3 on wide.
//         final cardsPerRow = w < 260
//             ? 1
//             : (w < 400 ? 2 : 3); // adjust if you want fewer / more columns
//         final horizontalSpacing = 8.0;
//         final totalSpacing = horizontalSpacing * (cardsPerRow - 1);
//         final cardWidth =
//             (w - totalSpacing).clamp(120.0, 200.0) / cardsPerRow; // min/max guard
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if ((message.text ?? '').isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 child: Text(
//                   message.text!,
//                   style: textStyle,
//                   textScaler: textScaler,
//                 ),
//               ),
//             Wrap(
//               spacing: horizontalSpacing,
//               runSpacing: 8,
//               children: message.attachments
//                   .map(
//                     (a) => Container(
//                   width: cardWidth,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: isMe ? Colors.white24 : Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.black12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(a.icon, size: w < 320 ? 22 : 28),
//                       const SizedBox(height: 8),
//                       Text(
//                         a.title,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: baseFont,
//                         ),
//                         textScaler: textScaler,
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         a.subtitle,
//                         style: TextStyle(
//                           color: isMe ? Colors.white70 : Colors.black54,
//                           fontSize: baseFont - 1,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         textScaler: textScaler,
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//                   .toList(),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               '${DateFormat('dd/MM/yyyy').format(message.createdAt)}  •  ${DateFormat('hh:mm a').format(message.createdAt)}',
//               style: textStyle.copyWith(
//                 fontSize: timeFont,
//                 color: isMe ? Colors.white70 : Colors.black54,
//               ),
//               textScaler: textScaler,
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
//
//
// class _Composer extends StatefulWidget {
//   final TextEditingController controller;
//   final String convId;
//   final OdooUser me;
//   final VoidCallback? onSent;
//
//   const _Composer({
//     required this.controller,
//     required this.convId,
//     required this.me,
//     this.onSent,
//     super.key,
//   });
//
//   @override
//   State<_Composer> createState() => _ComposerState();
// }
//
// class _ComposerState extends State<_Composer> {
//   final List<PickedAttachment> _attachments = [];
//
//   Future<void> _pickFiles() async {
//     final res = await FilePicker.platform.pickFiles(
//       allowMultiple: true,
//       withData: false,
//       withReadStream: true,
//       type: FileType.any,
//     );
//     if (res == null || res.files.isEmpty) return;
//
//     final tmpDir = await getTemporaryDirectory();
//     final List<PickedAttachment> picked = [];
//
//     for (final f in res.files) {
//       String? finalPath = f.path;
//
//       // SAF / URI-only → copy stream to temp file
//       if ((finalPath == null || finalPath.isEmpty) && f.readStream != null) {
//         final safeName = f.name.isNotEmpty ? f.name : 'attachment';
//         final target = File('${tmpDir.path}/$safeName');
//         final sink = target.openWrite();
//         await for (final chunk in f.readStream!) {
//           sink.add(chunk);
//         }
//         await sink.close();
//         finalPath = target.path;
//       }
//
//       if (finalPath == null || finalPath.isEmpty) continue;
//
//       picked.add(PickedAttachment(
//         path: finalPath,
//         name: f.name,
//         type: _inferTypeFromName(f.name),
//       ));
//     }
//
//     if (picked.isNotEmpty) {
//       setState(() => _attachments.addAll(picked));
//     }
//   }
//
//   AttachmentType _inferTypeFromName(String name) {
//     final lower = name.toLowerCase();
//     const imgExt = ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.heic', '.bmp'];
//     return imgExt.any(lower.endsWith) ? AttachmentType.image : AttachmentType.file;
//   }
//
//   void _showAttachSheet() {
//     showModalBottomSheet(
//       context: context,
//       showDragHandle: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.attach_file),
//               title: const Text('Files'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickFiles();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _handleSend() async {
//     final text = widget.controller.text.trim();
//     final attachments = List<PickedAttachment>.from(_attachments);
//     if (text.isEmpty && attachments.isEmpty) return;
//
//     HapticFeedback.selectionClick();
//     context.read<ChatProvider>().setTyping(false);
//
//     try {
//       // Provider now supports attachments and will call repo.uploadAttachments → repo.sendMessage
//       await context.read<ChatProvider>().send(
//         widget.convId,
//         text,
//         widget.me,
//         attachments: attachments,
//       );
//
//       if (text.isNotEmpty) widget.controller.clear();
//       if (_attachments.isNotEmpty) setState(() => _attachments.clear());
//
//       widget.onSent?.call();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to send: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       top: false,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (_attachments.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               SizedBox(
//                 height: 72,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _attachments.length,
//                   separatorBuilder: (_, __) => const SizedBox(width: 8),
//                   itemBuilder: (_, i) {
//                     final a = _attachments[i];
//                     return Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         Container(
//                           width: 72,
//                           height: 72,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(12),
//                             image: a.type == AttachmentType.image && a.path.isNotEmpty
//                                 ? DecorationImage(
//                               image: FileImage(File(a.path)),
//                               fit: BoxFit.cover,
//                             )
//                                 : null,
//                           ),
//                           child: a.type == AttachmentType.file
//                               ? const Icon(Icons.insert_drive_file_outlined, size: 28)
//                               : null,
//                         ),
//                         Positioned(
//                           right: -8,
//                           top: -8,
//                           child: IconButton.filled(
//                             style: IconButton.styleFrom(
//                               padding: EdgeInsets.zero,
//                               minimumSize: const Size(28, 28),
//                             ),
//                             onPressed: () => setState(() => _attachments.removeAt(i)),
//                             icon: const Icon(Icons.close, size: 18),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 8),
//             ],
//
//             Row(
//               children: [
//                 IconButton(
//                   tooltip: 'Attach',
//                   onPressed: _showAttachSheet,
//                   icon: const Icon(Icons.attach_file),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: TextField(
//                     controller: widget.controller,
//                     minLines: 1,
//                     maxLines: 5,
//                     decoration: InputDecoration(
//                       hintText: 'Type a Message…',
//                       filled: true,
//                       fillColor: Colors.grey[100],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                         borderSide: BorderSide.none,
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     ),
//                     onChanged: (v) => context.read<ChatProvider>().setTyping(v.isNotEmpty),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: _handleSend,
//                   style: IconButton.styleFrom(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.all(14),
//                   ),
//                   icon: const Icon(Icons.send_rounded),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
// class _TypingBubble extends StatelessWidget {
//   const _TypingBubble();
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Typing'),
//             const SizedBox(width: 6),
//             Row(
//               children: List.generate(
//                 3,
//                     (i) => Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 1.5),
//                   child: _Dot(delay: Duration(milliseconds: 200 * i)),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _Dot extends StatefulWidget {
//   final Duration delay;
//   const _Dot({required this.delay});
//   @override
//   State<_Dot> createState() => _DotState();
// }
//
// class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
//   late final AnimationController _c;
//   late final Animation<double> _a;
//   @override
//   void initState() {
//     super.initState();
//     _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
//     _a = Tween(begin: .3, end: 1.0).animate(
//       CurvedAnimation(parent: _c, curve: const Interval(0, 1, curve: Curves.easeInOut)),
//     );
//     Future.delayed(widget.delay, () {
//       if (mounted) setState(() {});
//     });
//   }
//
//   @override
//   void dispose() {
//     _c.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _a,
//       child: const CircleAvatar(radius: 3.2),
//     );
//   }
// }

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../model/conversation.dart';
import '../../model/message.dart';
import '../../model/user_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/chat_provider.dart';

class ChatPage extends StatefulWidget {
  final Conversation? conv;
  const ChatPage({super.key, this.conv});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();

    // Make sure messages for this conversation are fetched
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final conv = widget.conv;
      if (conv != null) {
        context.read<ChatProvider>().openConversation(conv);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }
// ─────────────────────────── Shared Helpers ───────────────────────────

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _prettyTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';

    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final conv = widget.conv;

    if (conv == null) {
      return const Scaffold(
        body: Center(child: Text('No conversation selected')),
      );
    }

    final messages = chat.messagesFor(conv.id);

    if (auth.user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(conv.peer.name),
          actions: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            )
          ],
        ),
        body: const Center(child: Text('Please log in to continue…')),
      );
    }

    final me = auth.user!;
    final w = MediaQuery.of(context).size.width;

    final horizontal = w < 340 ? 8.0 : (w < 420 ? 12.0 : 16.0);
    final vertical = w < 340 ? 6.0 : 12.0;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 24,
        titleSpacing: 0,
        title: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final isNarrow = w < 320;

            final avatarRadius = isNarrow ? 14.0 : 16.0;
            final nameSize = isNarrow ? 14.0 : 16.0;
            final subtitleSize = isNarrow ? 10.0 : 12.0;
            final leftPadding = isNarrow ? 4.0 : 8.0;
            final gap = isNarrow ? 8.0 : 12.0;

            return Row(
              children: [
                SizedBox(width: leftPadding),
                CircleAvatar(
                  radius: avatarRadius,
                  child: Text(
                    _initials(conv.peer.name),
                    style: TextStyle(fontSize: isNarrow ? 12 : 14),
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conv.peer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: nameSize,
                        ),
                      ),
                      Text(
                        // last message time as subtitle
                        _prettyTime(conv.lastMessage.createdAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: Colors.grey[600],
                          fontSize: subtitleSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scroll,
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
                vertical: vertical,
              ),
              itemCount: messages.length + (chat.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= messages.length) {
                  return const _TypingBubble();
                }
                final m = messages[index];
                final isMe = m.sender.uid == me.uid;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints:
                      const BoxConstraints(maxWidth: 320),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context)
                              .colorScheme
                              .primary
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _MessageContent(
                            message: m,
                            isMe: isMe,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          _Composer(
            controller: _ctrl,
            convId: conv.id,
            me: me,
            onSent: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scroll.hasClients) {
                  _scroll.animateTo(
                    _scroll.position.maxScrollExtent + 120,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  final Message message;
  final bool isMe;
  const _MessageContent({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // Base font sizes tuned for mobile
        final baseFont = w < 320 ? 13.0 : (w < 380 ? 14.0 : 15.0);
        final timeFont = w < 320 ? 11.0 : 12.0;

        final textStyle = TextStyle(
          color: isMe ? Colors.white : Colors.black87,
          height: 1.35,
          fontSize: baseFont,
        );

        if (message.type == MessageType.text ||
            (message.attachments.isEmpty && (message.text ?? '').isNotEmpty)) {
          return Text(
            message.text ?? '',
            style: textStyle,
            textScaler: textScaler,
          );
        }

        // --- Attachment block ---

        // Compute card width based on available width (for phones)
        // Example: ~2 cards per row on normal phones, 3 on wide.
        final cardsPerRow = w < 260
            ? 1
            : (w < 400 ? 2 : 3); // adjust if you want fewer / more columns
        final horizontalSpacing = 8.0;
        final totalSpacing = horizontalSpacing * (cardsPerRow - 1);
        final cardWidth =
            (w - totalSpacing).clamp(120.0, 200.0) / cardsPerRow; // min/max guard

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((message.text ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  message.text!,
                  style: textStyle,
                  textScaler: textScaler,
                ),
              ),
            Wrap(
              spacing: horizontalSpacing,
              runSpacing: 8,
              children: message.attachments
                  .map(
                    (a) => Container(
                  width: cardWidth,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.white24 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(a.icon, size: w < 320 ? 22 : 28),
                      const SizedBox(height: 8),
                      Text(
                        a.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: baseFont,
                        ),
                        textScaler: textScaler,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.subtitle,
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.black54,
                          fontSize: baseFont - 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: textScaler,
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 6),
            Text(
              '${DateFormat('dd/MM/yyyy').format(message.createdAt)}  •  ${DateFormat('hh:mm a').format(message.createdAt)}',
              style: textStyle.copyWith(
                fontSize: timeFont,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
              textScaler: textScaler,
            ),
          ],
        );
      },
    );
  }
}



class _Composer extends StatefulWidget {
  final TextEditingController controller;
  final String convId;
  final OdooUser me;
  final VoidCallback? onSent;

  const _Composer({
    required this.controller,
    required this.convId,
    required this.me,
    this.onSent,
    super.key,
  });

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final List<PickedAttachment> _attachments = [];

  Future<void> _pickFiles() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
      withReadStream: true,
      type: FileType.any,
    );
    if (res == null || res.files.isEmpty) return;

    final tmpDir = await getTemporaryDirectory();
    final List<PickedAttachment> picked = [];

    for (final f in res.files) {
      String? finalPath = f.path;

      // SAF / URI-only → copy stream to temp file
      if ((finalPath == null || finalPath.isEmpty) && f.readStream != null) {
        final safeName = f.name.isNotEmpty ? f.name : 'attachment';
        final target = File('${tmpDir.path}/$safeName');
        final sink = target.openWrite();
        await for (final chunk in f.readStream!) {
          sink.add(chunk);
        }
        await sink.close();
        finalPath = target.path;
      }

      if (finalPath == null || finalPath.isEmpty) continue;

      picked.add(PickedAttachment(
        path: finalPath,
        name: f.name,
        type: _inferTypeFromName(f.name),
      ));
    }

    if (picked.isNotEmpty) {
      setState(() => _attachments.addAll(picked));
    }
  }

  AttachmentType _inferTypeFromName(String name) {
    final lower = name.toLowerCase();
    const imgExt = ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.heic', '.bmp'];
    return imgExt.any(lower.endsWith) ? AttachmentType.image : AttachmentType.file;
  }

  void _showAttachSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Files'),
              onTap: () {
                Navigator.pop(context);
                _pickFiles();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSend() async {
    final text = widget.controller.text.trim();
    final attachments = List<PickedAttachment>.from(_attachments);
    if (text.isEmpty && attachments.isEmpty) return;

    HapticFeedback.selectionClick();
    context.read<ChatProvider>().setTyping(false);

    try {
      // Provider now supports attachments and will call repo.uploadAttachments → repo.sendMessage
      await context.read<ChatProvider>().send(
        widget.convId,
        text,
        widget.me,
        attachments: attachments,
      );

      if (text.isNotEmpty) widget.controller.clear();
      if (_attachments.isNotEmpty) setState(() => _attachments.clear());

      widget.onSent?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attachments.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final a = _attachments[i];
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            image: a.type == AttachmentType.image && a.path.isNotEmpty
                                ? DecorationImage(
                              image: FileImage(File(a.path)),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: a.type == AttachmentType.file
                              ? const Icon(Icons.insert_drive_file_outlined, size: 28)
                              : null,
                        ),
                        Positioned(
                          right: -8,
                          top: -8,
                          child: IconButton.filled(
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(28, 28),
                            ),
                            onPressed: () => setState(() => _attachments.removeAt(i)),
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],

            Row(
              children: [
                IconButton(
                  tooltip: 'Attach',
                  onPressed: _showAttachSheet,
                  icon: const Icon(Icons.attach_file),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Type a Message…',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (v) => context.read<ChatProvider>().setTyping(v.isNotEmpty),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _handleSend,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class _TypingBubble extends StatelessWidget {
  const _TypingBubble();
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Typing'),
            const SizedBox(width: 6),
            Row(
              children: List.generate(
                3,
                    (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: _Dot(delay: Duration(milliseconds: 200 * i)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final Duration delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _a = Tween(begin: .3, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0, 1, curve: Curves.easeInOut)),
    );
    Future.delayed(widget.delay, () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: const CircleAvatar(radius: 3.2),
    );
  }
}