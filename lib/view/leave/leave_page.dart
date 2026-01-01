// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
//
// import '../provider/leave_provider.dart';
// import '../model/leave_model.dart';
// import 'leave_detail_page.dart';
//
//
// class LeavePage extends StatefulWidget {
//   const LeavePage({super.key});
//
//   @override
//   State<LeavePage> createState() => _LeavePageState();
// }
//
// class _LeavePageState extends State<LeavePage> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => context.read<LeaveProvider>().loadMyLeaves());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<LeaveProvider>();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Leaves'),
//         centerTitle: true,
//       ),
//       body: provider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : provider.error != null
//           ? Center(
//         child: Text(
//           provider.error!,
//           style: const TextStyle(color: Colors.redAccent),
//         ),
//       )
//           : provider.leaves.isEmpty
//           ? const Center(child: Text('No leave records found'))
//           : ListView.builder(
//         padding: const EdgeInsets.all(12),
//         itemCount: provider.leaves.length,
//         itemBuilder: (context, i) {
//           final l = provider.leaves[i];
//           final chipColor = _stateColor(l.state);
//           final dateRange =
//               '${_fmtDate(l.requestDateFrom)} → ${_fmtDate(l.requestDateTo)}';
//
//           return Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             child: ListTile(
//               contentPadding: const EdgeInsets.all(12),
//               leading: CircleAvatar(
//                 backgroundColor: Colors.blue.shade100,
//                 child: const Icon(Icons.beach_access_rounded,
//                     color: Colors.blue),
//               ),
//               title: Text(
//                 l.employeeName,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 16,
//                 ),
//               ),
//               trailing: Chip(
//                 label: Text(
//                   _title(l.state.isNotEmpty ? l.state : l.holidayStatus),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//                 backgroundColor: chipColor,
//                 padding: EdgeInsets.zero,
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     dateRange,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Text('Days: ${l.numberOfDays}'),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Type: ${l.holidayStatus}',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//               isThreeLine: true,
//               onTap: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => LeaveDetailsPage(leave: l),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   static String _fmtDate(String raw) {
//     try {
//       final d = DateTime.parse(raw);
//       return DateFormat('MMM d, yyyy').format(d);
//     } catch (_) {
//       return raw;
//     }
//   }
//
//   static Color _stateColor(String state) {
//     switch (state.toLowerCase()) {
//       case 'to_approve':
//       case 'draft':
//         return Colors.amber;
//       case 'confirm':
//       case 'approved':
//         return Colors.green;
//       case 'refuse':
//       case 'rejected':
//         return Colors.redAccent;
//       case 'cancel':
//       case 'canceled':
//         return Colors.grey;
//       default:
//         return Colors.blueGrey;
//     }
//   }
//
//   static String _title(String s) =>
//       s.replaceAll('_', ' ').replaceAll('-', ' ').split(' ').map((w) {
//         if (w.isEmpty) return w;
//         return w[0].toUpperCase() + w.substring(1);
//       }).join(' ');
// }


import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../provider/leave_provider.dart';
import 'leave_detail_page.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<LeaveProvider>().loadMyLeaves());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaveProvider>();

    // Screen width for all responsive values
    final w = MediaQuery.of(context).size.width;

    // Global responsive values
    final tilePad = (w * 0.03).clamp(10.0, 18.0);
    final titleFont = (w * 0.042).clamp(14.0, 18.0);
    final subtitleFont = (w * 0.038).clamp(13.0, 16.0);
    final smallFont = (w * 0.034).clamp(11.0, 14.0);

    final avatarRadius = (w * 0.075).clamp(20.0, 30.0);
    final iconSize = (w * 0.06).clamp(20.0, 26.0);

    final chipFont = (w * 0.032).clamp(10.0, 13.0);
    final chipPadH = (w * 0.015).clamp(4.0, 10.0);
    final chipPadV = (w * 0.01).clamp(2.0, 6.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Leaves'),
        centerTitle: true,
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
        child: Text(
          provider.error!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      )
          : provider.leaves.isEmpty
          ? const Center(child: Text('No leave records found'))
          : ListView.builder(
        padding: EdgeInsets.all(tilePad),
        itemCount: provider.leaves.length,
        itemBuilder: (context, i) {
          final l = provider.leaves[i];
          final chipColor = _stateColor(l.state);
          final dateRange =
              '${_fmtDate(l.requestDateFrom)} → ${_fmtDate(l.requestDateTo)}';

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.symmetric(
              vertical: (w * 0.02).clamp(6.0, 12.0),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(tilePad),

              // Avatar
              leading: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.blue.shade100,
                child: Icon(
                  Icons.beach_access_rounded,
                  color: Colors.blue,
                  size: iconSize,
                ),
              ),

              // Title (Employee name)
              title: Text(
                l.employeeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: titleFont,
                ),
              ),

              // Status chip
              trailing: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: chipPadH,
                  vertical: chipPadV,
                ),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _title(
                    l.state.isNotEmpty
                        ? l.state
                        : l.holidayStatus,
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: chipFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Subtitle section (date, days, type)
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: (w * 0.015).clamp(4.0, 8.0)),
                  Text(
                    dateRange,
                    style: TextStyle(
                      fontSize: subtitleFont,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: (w * 0.01).clamp(2.0, 6.0)),
                  Text(
                    'Days: ${l.numberOfDays}',
                    style: TextStyle(
                      fontSize: smallFont,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: (w * 0.01).clamp(2.0, 4.0)),
                  Text(
                    'Type: ${l.holidayStatus}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: smallFont,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),

              isThreeLine: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        LeaveDetailsPage(leave: l),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ---- HELPERS ----
  static String _fmtDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      return DateFormat('MMM d, yyyy').format(d);
    } catch (_) {
      return raw;
    }
  }

  static Color _stateColor(String state) {
    switch (state.toLowerCase()) {
      case 'to_approve':
      case 'draft':
        return Colors.amber;
      case 'confirm':
      case 'approved':
        return Colors.green;
      case 'refuse':
      case 'rejected':
        return Colors.redAccent;
      case 'cancel':
      case 'canceled':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  static String _title(String s) {
    return s
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
