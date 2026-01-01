// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../model/attendance_model.dart';
// import '../provider/attendance_provider.dart';
//
// class AttendancePage extends StatefulWidget {
//   const AttendancePage({super.key});
//
//   @override
//   State<AttendancePage> createState() => _AttendancePageState();
// }
//
// class _AttendancePageState extends State<AttendancePage> {
//   DateTime _selectedDate = DateTime.now();
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() =>
//         context.read<AttendanceProvider>().loadTodayAttendance());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<AttendanceProvider>();
//
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text('Attendance'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             tooltip: 'Pick date',
//             icon: const Icon(Icons.calendar_month_rounded),
//             onPressed: () => _openDatePicker(context),
//           ),
//           // IconButton(
//           //   tooltip: 'Today',
//           //   icon: const Icon(Icons.today_rounded),
//           //   onPressed: () {
//           //     final t = DateTime.now();
//           //     final today = DateTime(t.year, t.month, t.day);
//           //     if (!DateUtils.isSameDay(_selectedDate, today)) {
//           //       setState(() => _selectedDate = today);
//           //     }
//           //     context.read<AttendanceProvider>().loadForDate(today);
//           //   },
//           // ),
//           const SizedBox(width: 4),
//         ],
//       ),
//       body: Column(
//         children: [
//           _DateHeader(
//             date: _selectedDate,
//             onPrev: () {
//               final d = _selectedDate.subtract(const Duration(days: 1));
//               setState(() => _selectedDate = d);
//               context.read<AttendanceProvider>().loadForDate(d);
//             },
//             onNext: () {
//               final d = _selectedDate.add(const Duration(days: 1));
//               setState(() => _selectedDate = d);
//               context.read<AttendanceProvider>().loadForDate(d);
//             },
//           ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: () =>
//                   context.read<AttendanceProvider>().loadForDate(_selectedDate),
//               child: AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 200),
//                 child: provider.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : provider.error != null
//                     ? _ErrorView(msg: provider.error!)
//                     : provider.attendance == null
//                     ? const _EmptyView(text: 'No data available')
//                     : _SingleAttendanceCard(attendance: provider.attendance!),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _openDatePicker(BuildContext context) async {
//     final now = DateTime.now();
//     final initial = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
//
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,             // defaults to today on first open
//       firstDate: DateTime(now.year - 1, 1, 1),
//       lastDate: DateTime(now.year + 1, 12, 31),
//       helpText: 'Select attendance date',
//       initialEntryMode: DatePickerEntryMode.calendar,
//     );
//
//     if (picked != null && !DateUtils.isSameDay(picked, _selectedDate)) {
//       final d = DateTime(picked.year, picked.month, picked.day);
//       setState(() => _selectedDate = d);
//       await context.read<AttendanceProvider>().loadForDate(d);
//     }
//   }
// }
//
// /* ---------- DATE HEADER (chevrons ±1 day, full date text) ---------- */
//
// class _DateHeader extends StatelessWidget {
//   const _DateHeader({
//     required this.date,
//     required this.onPrev,
//     required this.onNext,
//   });
//
//   final DateTime date;
//   final VoidCallback onPrev;
//   final VoidCallback onNext;
//
//   @override
//   Widget build(BuildContext context) {
//     // Example: Tue, Nov 4, 2025
//     final label = DateFormat('EEE, MMM d, yyyy').format(date);
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
//       child: Row(
//         children: [
//           IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left_rounded)),
//           Expanded(
//             child: Center(
//               child: Text(
//                 label,
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//           IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right_rounded)),
//         ],
//       ),
//     );
//   }
// }
//
// /* ---------- SINGLE CARD (your current model) ---------- */
//
// class _SingleAttendanceCard extends StatelessWidget {
//   const _SingleAttendanceCard({required this.attendance});
//   final Attendance attendance;
//
//   @override
//   Widget build(BuildContext context) {
//     final dtLabel = attendance.date.isNotEmpty
//         ? _friendlyDate(attendance.date)
//         : '—';
//
//     return ListView(
//       padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
//       children: [
//         Card(
//           elevation: 0,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           child: Padding(
//             padding: const EdgeInsets.all(14),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 24,
//                   child: Text(
//                     _initials(attendance.employeeName),
//                     style: const TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(attendance.employeeName,
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                       const SizedBox(height: 4),
//                       Text('Date: $dtLabel',
//                           style: TextStyle(color: Colors.grey[700], fontSize: 13)),
//                       const SizedBox(height: 2),
//                       Text('Employee ID: ${attendance.employeeId}',
//                           style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//                       const SizedBox(height: 8),
//                       Text('Time: —',
//                           style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 _StatusPill(text: 'Present'), // placeholder
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _initials(String name) {
//     final parts = name.trim().split(RegExp(r'\s+'));
//     if (parts.isEmpty) return '?';
//     if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
//     return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
//   }
//
//   String _friendlyDate(String raw) {
//     try {
//       final dt = raw.contains('T')
//           ? DateTime.parse(raw).toLocal()
//           : DateFormat('yyyy-MM-dd').parse(raw, true).toLocal();
//       return DateFormat('EEE, MMM d, yyyy').format(dt);
//     } catch (_) {
//       return raw;
//     }
//   }
// }
//
// class _StatusPill extends StatelessWidget {
//   const _StatusPill({required this.text});
//   final String text;
//
//   @override
//   Widget build(BuildContext context) {
//     final t = text.toLowerCase();
//     final isOk = t.contains('present') || t.contains('on time') || t.contains('ok');
//     final isWarn = t.contains('late');
//     final bg = isOk
//         ? Colors.green.withOpacity(.12)
//         : isWarn
//         ? Colors.orange.withOpacity(.12)
//         : Theme.of(context).colorScheme.primary.withOpacity(.10);
//     final fg = isOk
//         ? Colors.green[800]
//         : isWarn
//         ? Colors.orange[800]
//         : Theme.of(context).colorScheme.primary;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
//       child: Text(
//         text,
//         style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
//       ),
//     );
//   }
// }
//
// class _ErrorView extends StatelessWidget {
//   const _ErrorView({required this.msg});
//   final String msg;
//   @override
//   Widget build(BuildContext context) =>
//       Center(child: Text(msg, style: const TextStyle(color: Colors.redAccent)));
// }
//
// class _EmptyView extends StatelessWidget {
//   const _EmptyView({required this.text});
//   final String text;
//   @override
//   Widget build(BuildContext context) =>
//       Center(child: Text(text, style: TextStyle(color: Colors.grey[700])));
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/attendance_model.dart';
import '../provider/attendance_provider.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<AttendanceProvider>().loadTodayAttendance());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Attendance'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Pick date',
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => _openDatePicker(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _DateHeader(
            date: _selectedDate,
            onPrev: () {
              final d = _selectedDate.subtract(const Duration(days: 1));
              setState(() => _selectedDate = d);
              context.read<AttendanceProvider>().loadForDate(d);
            },
            onNext: () {
              final d = _selectedDate.add(const Duration(days: 1));
              setState(() => _selectedDate = d);
              context.read<AttendanceProvider>().loadForDate(d);
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  context.read<AttendanceProvider>().loadForDate(_selectedDate),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                    ? _ErrorView(msg: provider.error!)
                    : provider.attendance == null
                    ? const _EmptyView(text: 'No data available')
                    : _AttendanceList(attendance: provider.attendance!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final initial = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: 'Select attendance date',
      initialEntryMode: DatePickerEntryMode.calendar,
    );

    if (picked != null && !DateUtils.isSameDay(picked, _selectedDate)) {
      final d = DateTime(picked.year, picked.month, picked.day);
      setState(() => _selectedDate = d);
      await context.read<AttendanceProvider>().loadForDate(d);
    }
  }
}

/* ---------- DATE HEADER (chevrons ±1 day, full date text) ---------- */

class _DateHeader extends StatelessWidget {
  const _DateHeader({
    required this.date,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('EEE, MMM d, yyyy').format(date);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left_rounded)),
          Expanded(
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right_rounded)),
        ],
      ),
    );
  }
}

/* ---------- ATTENDANCE LIST ---------- */

class _AttendanceList extends StatelessWidget {
  const _AttendanceList({required this.attendance});
  final Attendance attendance;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      itemCount: attendance.attendances.length, // only attendance entries
      itemBuilder: (context, index) {
        final entry = attendance.attendances[index];

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Employee info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      child: Text(
                        _initials(attendance.employeeName),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attendance.employeeName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Employee ID: ${attendance.employeeId}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Date: ${_friendlyDate(attendance.date)}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Attendance info
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 28, color: Colors.blueAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check-in: ${entry.checkIn.isNotEmpty ? entry.checkIn : '—'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Check-out: ${entry.checkOut.isNotEmpty ? entry.checkOut : '—'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Worked hours: ${entry.workedHours.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(text: entry.checkIn.isNotEmpty ? 'Present' : 'Absent'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  String _friendlyDate(String raw) {
    try {
      final dt = raw.contains('T')
          ? DateTime.parse(raw).toLocal()
          : DateFormat('yyyy-MM-dd').parse(raw, true).toLocal();
      return DateFormat('EEE, MMM d, yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

/* ---------- STATUS PILL ---------- */
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = text.toLowerCase();
    final isOk = t.contains('present') || t.contains('on time') || t.contains('ok');
    final isWarn = t.contains('late');
    final bg = isOk
        ? Colors.green.withOpacity(.12)
        : isWarn
        ? Colors.orange.withOpacity(.12)
        : Theme.of(context).colorScheme.primary.withOpacity(.10);
    final fg = isOk
        ? Colors.green[800]
        : isWarn
        ? Colors.orange[800]
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

/* ---------- ERROR & EMPTY VIEWS ---------- */
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.msg});
  final String msg;
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(msg, style: const TextStyle(color: Colors.redAccent)));
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(text, style: TextStyle(color: Colors.grey[700])));
}
