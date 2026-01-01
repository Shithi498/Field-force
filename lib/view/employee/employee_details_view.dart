import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/all_employee_model.dart';
import '../../provider/all_employee_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/employee_provider.dart';


class EmployeeDetailsView extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailsView({
    super.key,
    required this.employee,
  });
  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      print('Could not launch $phoneNumber');
    }
  }


  Future<void> _launchEmail(String to, {String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (body != null && body.isNotEmpty) 'body': body,
      },
    );

    // Check first so we can show a friendly message instead of throwing.
    if (await canLaunchUrl(uri)) {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('Could not launch email client');
    } else {
      // Optional: last-resort web compose (Gmail) if there’s a browser
      final web = Uri.https('mail.google.com', '/mail/', {
        'view': 'cm',
        'to': to,
        if (subject != null && subject.isNotEmpty) 'su': subject,
        if (body != null && body.isNotEmpty) 'body': body,
      });
      if (!await launchUrl(web, mode: LaunchMode.externalApplication)) {
        throw Exception('No email app found');
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        centerTitle: true,
      ),
      body: _buildDetails(context, employee),
    );
  }

  Widget _buildDetails(BuildContext context, Employee emp) {

    final sessionCookie = Provider.of<AuthProvider>(context, listen: false).sessionCookie ?? '';


    ImageProvider? avatarImage;
    // if (emp.imageUrl= null && emp.imageBase64!.isNotEmpty) {
    //   try {
    //     avatarImage = MemoryImage(base64Decode(emp.imageBase64!));
    //   } catch (e) {
    //     debugPrint("❌ Failed to decode base64 image: $e");
    //   }
    // }


    if (avatarImage == null && emp.imageUrl.isNotEmpty) {
      avatarImage = NetworkImage(
        "https://demo.kendroo.com${emp.imageUrl}",
        headers: {"Cookie": sessionCookie},
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ───────── HEADER SECTION ─────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                CircleAvatar(
                  radius: 36,
                  backgroundImage: avatarImage,
                  backgroundColor: avatarImage == null ? Colors.blue.shade100 : Colors.transparent,
                  child: avatarImage == null
                      ? const Icon(Icons.person, size: 40, color: Colors.blue)
                      : null,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(emp.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(emp.jobTitle,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),

          // ───────── DETAILS SECTION ─────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text("Organizational Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),

                _infoRow(Icons.business_center, 'Job Title', emp.jobTitle),
                _infoRow(Icons.business, 'Department', emp.department),
                _infoRow(Icons.person_pin_circle, 'Manager', emp.manager),
                _infoRow(Icons.apartment, 'Company', emp.company),
              ],
            ),
          ),
        ],
      ),
    );
  }


  //Helper widget for information rows, now simplified to not require context
  // Widget _infoRow(IconData icon, String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Icon(icon, size: 20, color: Colors.grey.shade600),
  //         const SizedBox(width: 12),
  //         SizedBox(
  //           width:100,
  //           child: Text(
  //             label,
  //             style: const TextStyle(color: Colors.black54, fontSize: 15),
  //           ),
  //         ),
  //         const SizedBox(width: 8),
  //         Expanded(
  //           child: Text(
  //             value.isNotEmpty ? value : 'N/A',
  //             style: const TextStyle(
  //                 color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),

          // Label takes a smaller, flexible share
          Flexible(
            flex: 4, // tweak as needed
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ),

          const SizedBox(width: 20),

          // Value takes the remaining space
          Flexible(
            flex: 7, // tweak as needed
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              maxLines: 2, // allow 2 lines for longer values
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }




}

class _ActionsBlock extends StatelessWidget {
  final Employee emp;
  final void Function(String) onCall;
  final Future<void> Function(String) onEmail;

  const _ActionsBlock({required this.emp, required this.onCall, required this.onEmail});

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.blue, size: 24),
              onPressed: () {
                if (emp.workPhone.isNotEmpty) onCall(emp.workPhone);
              },
              tooltip: emp.workPhone.isNotEmpty ? 'Call ${emp.workPhone}' : 'No phone',
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 60, maxWidth: 180),
              child: Text(
                emp.workPhone.isNotEmpty ? emp.workPhone : 'No phone',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:  TextStyle(
                  fontSize: scaler.scale(14),   // 👈 scale only the number
                ),
              ),
            ),
          ],
        ),
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     IconButton(
        //       icon: const Icon(Icons.phone, color: Colors.blue, size: 24),
        //       onPressed: () {
        //         if (emp.workPhone.isNotEmpty) onCall(emp.workPhone);
        //       },
        //       tooltip: emp.workPhone.isNotEmpty ? 'Call ${emp.workPhone}' : 'No phone',
        //     ),
        //     const SizedBox(width: 8),
        //     Flexible(
        //       child: Text(
        //         emp.workPhone.isNotEmpty ? emp.workPhone : 'No phone',
        //         maxLines: 1,
        //         overflow: TextOverflow.ellipsis,
        //         style: const TextStyle(fontSize: 14),
        //       ),
        //     ),
        //   ],
        // ),
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     IconButton(
        //       icon: const Icon(Icons.email, color: Colors.blue, size: 24),
        //       onPressed: () {
        //         if (emp.workEmail.isNotEmpty) onEmail(emp.workEmail);
        //       },
        //       tooltip: emp.workEmail.isNotEmpty ? 'Email ${emp.workEmail}' : 'No email',
        //     ),
        //     const SizedBox(width: 8),
        //     Flexible(
        //       child: Text(
        //         emp.workEmail.isNotEmpty ? emp.workEmail : 'No email',
        //         maxLines: 1,
        //         overflow: TextOverflow.ellipsis,
        //         style: const TextStyle(fontSize: 14),
        //       ),
        //     ),
        //   ],
        // ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.email, color: Colors.blue, size: 24),
              onPressed: () {
                if (emp.workEmail.isNotEmpty) onEmail(emp.workEmail);
              },
              tooltip: emp.workEmail.isNotEmpty ? 'Email ${emp.workEmail}' : 'No email',
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 60, maxWidth: 180),
              child: Text(
                emp.workEmail.isNotEmpty ? emp.workEmail : 'No email',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: scaler.scale(14),   // 👈 scale only the number
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

