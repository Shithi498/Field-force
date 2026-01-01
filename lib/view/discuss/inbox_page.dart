// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../model/conversation.dart';
// import '../../provider/chat_provider.dart';
// import 'chat_page.dart';
//
// class InboxPage extends StatefulWidget {
//   const InboxPage({super.key});
//
//   @override
//   State<InboxPage> createState() => _InboxPageState();
// }
//
// class _InboxPageState extends State<InboxPage>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tab;
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     _tab = TabController(length: 1, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ChatProvider>().loadInbox();
//     });
//   }
//
//   @override
//   void dispose() {
//     _tab.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<ChatProvider>();
//     final w = MediaQuery.of(context).size.width;
//
// // Responsive spacing
//     final gapSmall  = w < 340 ? 4.0 : 6.0;
//     final gapMedium = w < 400 ? 8.0 : 12.0;
//
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text('Inbox'),
//         actions: [
//           IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
//           IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
//           SizedBox(width: gapSmall),
//           const _Avatar(initials: 'J'),
//           SizedBox(width: gapMedium),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(48),
//           child: Align(
//             alignment: Alignment.centerLeft,
//             child: TabBar(
//               controller: _tab,
//               isScrollable: true,
//               labelPadding: const EdgeInsets.symmetric(horizontal: 16),
//               tabs: const [
//                 Tab(text: 'Activity'),
//                 // Tab(text: 'Archive'),
//                 // Tab(text: 'Draft'),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tab,
//         children: [
//           _MessagesList(conversations: provider.inbox),
//           const Center(child: Text('No archived messages')),
//           const Center(child: Text('No drafts')),
//         ],
//       ),
//     );
//   }
// }
//
// class _MessagesList extends StatelessWidget {
//   final List<Conversation> conversations;
//   const _MessagesList({required this.conversations});
//
//   @override
//   Widget build(BuildContext context) {
//     if (conversations.isEmpty) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return ListView.separated(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       itemBuilder: (context, index) {
//         final c = conversations[index];
//         final w = MediaQuery.of(context).size.width;
//         final fontSize = w < 340 ? 10.0 : (w < 420 ? 12.0 : 14.0);
//
//         return ListTile(
//           leading: _Avatar(initials: _initials(c.peer.name)),
//           title: Text(c.peer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
//           subtitle: Text(c.lastMessage.text ?? 'Attachment'),
//           trailing: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(_prettyTime(c.lastMessage.createdAt),
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodySmall
//                       ?.copyWith(color: Colors.grey[600])),
//
//         if (c.unreadCount > 0)
//                 Container(
//                   margin: const EdgeInsets.only(top: 6),
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.primary,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text('${c.unreadCount}',
//                       style: TextStyle(color: Colors.white, fontSize: fontSize)),
//                 ),
//             ],
//           ),
//           onTap: () async {
//             final provider = context.read<ChatProvider>();
//             await provider.openConversation(c);
//             if (context.mounted) {
//               Navigator.of(context).push(
//                 MaterialPageRoute(builder: (_) => ChatPage(conv: c)),
//               );
//             }
//           },
//         );
//       },
//       separatorBuilder: (_, __) => const Divider(height: 1),
//       itemCount: conversations.length,
//     );
//   }
// }
//
// String _initials(String name) {
//   final parts = name.trim().split(' ');
//   if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
//   return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
// }
//
// String _prettyTime(DateTime dt) {
//   final now = DateTime.now();
//   final diff = now.difference(dt);
//   if (diff.inMinutes < 1) return 'Just now';
//   if (diff.inHours < 1) return '${diff.inMinutes}m ago';
//   if (diff.inHours < 24) return '${diff.inHours}h ago';
//   return DateFormat('d MMM').format(dt);
// }
//
// class _Avatar extends StatelessWidget {
//   final String initials;
//   const _Avatar({required this.initials});
//
//   @override
//   Widget build(BuildContext context) {
//     return CircleAvatar(
//       radius: 18,
//       child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../model/conversation.dart';
import '../../model/user_model.dart';
import '../../provider/chat_provider.dart';
import '../../repo/chat_repository.dart';
import 'chat_page.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    // Only one tab (Activity)
    _tab = TabController(length: 1, vsync: this);

    // Load inbox once the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadInbox();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final w = MediaQuery.of(context).size.width;

    // Responsive spacing
    final gapSmall = w < 340 ? 4.0 : 6.0;
    final gapMedium = w < 400 ? 8.0 : 12.0;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Inbox'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
          // ➕ NEW CHAT BUTTON
          IconButton(
            tooltip: 'New message',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const _SelectPartnerPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
          SizedBox(width: gapSmall),
          const _Avatar(initials: 'J'),
          SizedBox(width: gapMedium),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tab,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: const [
                Tab(text: 'Activity'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // Activity tab → inbox list
          _MessagesList(conversations: provider.inbox),
        ],
      ),
    );
  }
}

// ─────────────────────────── Inbox list ───────────────────────────

class _MessagesList extends StatelessWidget {
  final List<Conversation> conversations;
  const _MessagesList({required this.conversations});

  @override
  Widget build(BuildContext context) {
    // While provider is still loading, inbox will be empty
    if (conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final c = conversations[index];
        final w = MediaQuery.of(context).size.width;
        final fontSize = w < 340 ? 10.0 : (w < 420 ? 12.0 : 14.0);

        return ListTile(
          leading: _Avatar(initials: _initials(c.peer.name)),
          title: Text(
            c.peer.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(c.lastMessage.text ?? 'Attachment'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _prettyTime(c.lastMessage.createdAt),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
              if (c.unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${c.unreadCount}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                    ),
                  ),
                ),
            ],
          ),
          // Existing conversation → just open it, don't recreate channel
          onTap: () async {
            final chat = context.read<ChatProvider>();

            await chat.openConversation(c);

            if (!context.mounted) return;

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatPage(conv: c),
              ),
            );
          },
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: conversations.length,
    );
  }
}

// ─────────────────────────── New chat: select user ───────────────────────────

class _SelectPartnerPage extends StatefulWidget {
  const _SelectPartnerPage({super.key});

  @override
  State<_SelectPartnerPage> createState() => _SelectPartnerPageState();
}

class _SelectPartnerPageState extends State<_SelectPartnerPage> {
  bool _loading = true;
  List<OdooUser> _partners = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    try {
      final chat = context.read<ChatProvider>();
      final IChatRepository repo = chat.repo;

      // You must implement this in your repository:
      // Future<List<OdooUser>> fetchChatPartners()
      final partners = await repo.fetchChatPartners();

      setState(() {
        _partners = partners;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load users: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New message'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : ListView.separated(
        itemCount: _partners.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p = _partners[index];

          return ListTile(
            leading: _Avatar(initials: _initials(p.name)),
            title: Text(p.name),
            subtitle: Text(
              p.username.isNotEmpty ? p.username : 'User ID: ${p.uid}',
            ),
            onTap: () async {
              final chat = context.read<ChatProvider>();

              // Create or get DM channel with this partner
              final conv = await chat.startConversationWith(
                partnerId: p.uid,
                partnerName: p.name,
              );

              if (!context.mounted) return;

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatPage(conv: conv),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────── Shared helpers ───────────────────────────

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

class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      child: Text(
        initials,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

