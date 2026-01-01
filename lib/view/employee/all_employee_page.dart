// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../model/all_employee_model.dart';
// import '../../provider/all_employee_provider.dart';
// import '../../provider/auth_provider.dart';
// import 'employee_details_view.dart';
//
//
// class AllEmployeesPage extends StatefulWidget {
//   const AllEmployeesPage({super.key});
//
//   @override
//   State<AllEmployeesPage> createState() => _AllEmployeesPageState();
// }
//
// class _AllEmployeesPageState extends State<AllEmployeesPage> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() =>
//         Provider.of<AllEmployeeProvider>(context, listen: false)
//             .loadEmployees());
//   }
//
//   // @override
//   // Widget build(BuildContext context) {
//   //   final provider = context.watch<AllEmployeeProvider>();
//   //
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       title: const Text('All Employees'),
//   //       centerTitle: true,
//   //     ),
//   //     body: provider.isLoading
//   //         ? const Center(child: CircularProgressIndicator())
//   //         : provider.error != null
//   //         ? Center(
//   //       child: Text(provider.error!,
//   //           style: const TextStyle(color: Colors.redAccent)),
//   //     )
//   //         : ListView.separated(
//   //       padding: const EdgeInsets.all(12),
//   //       separatorBuilder: (_, __) => const Divider(),
//   //       itemCount: provider.employees.length,
//   //       itemBuilder: (_, index) {
//   //         final emp = provider.employees[index];
//   //         return _buildEmployeeTile(emp);
//   //       },
//   //     ),
//   //   );
//   // }
//
//   // Widget _buildEmployeeTile(Employee emp) {
//   //   return ListTile(
//   //     leading: CircleAvatar(
//   //       radius: 25,
//   //       backgroundColor: Colors.grey.shade200,
//   //       child: ClipOval(
//   //         child: Image.network(
//   //           'https://erp.kendroo.io${emp.imageUrl}',
//   //           headers: {
//   //             'Cookie': Provider.of<AuthProvider>(context, listen: false).sessionCookie ?? '',
//   //           },
//   //           fit: BoxFit.cover,
//   //           width: 50,
//   //           height: 50,
//   //           errorBuilder: (context, error, stackTrace) =>
//   //           const Icon(Icons.person, size: 30, color: Colors.grey),
//   //         ),
//   //       ),
//   //     ),
//   //
//   //     title: Text(emp.name,
//   //         style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
//   //     subtitle: Text('${emp.jobTitle}\n${emp.department}'),
//   //     isThreeLine: true,
//   //     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//   //     onTap: () {
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (_) => EmployeeDetailsView(employee: emp),
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<AllEmployeeProvider>();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('All Employees'),
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
//           : LayoutBuilder(
//         builder: (context, c)
//     {
//       final w = c.maxWidth;
//
//       // Simple breakpoints
//       final isPhone = w < 600;
//       final isTablet = w >= 600 && w < 1024;
//       final crossAxisCount = isPhone ? 1 : (isTablet ? 2 : 3);
//
//
//       // Scale spacing by width
//       final hPad = w < 360 ? 8.0 : 12.0;
//       final vGap = w < 360 ? 6.0 : 10.0;
//
//
//       // PHONE: List
//       return ListView.separated(
//         padding: EdgeInsets.all(hPad),
//         separatorBuilder: (_, __) => SizedBox(height: vGap),
//         itemCount: provider.employees.length,
//         itemBuilder: (_, i) =>
//             _buildEmployeeTile(
//               context,
//               provider.employees[i],
//               // pass width so tile can adapt sizes
//               w,
//             ),
//       );
//
//
//         },
//       ),
//     );
//   }
//
//
//   // Widget _buildEmployeeTile(BuildContext context, Employee emp, double parentW) {
//   //   final session = Provider.of<AuthProvider>(context, listen: false).sessionCookie ?? '';
//   //
//   //   // Responsive sizes
//   //   final avatar = parentW < 340 ? 20.0 : (parentW < 420 ? 24.0 : 25.0);
//   //   final titleSize = parentW < 340 ? 14.0 : (parentW < 420 ? 15.0 : 16.0);
//   //   final subSize   = parentW < 340 ? 12.0 : 13.0;
//   //   final dense     = parentW < 360;
//   //
//   //   return ListTile(
//   //     dense: dense,
//   //     visualDensity: dense ? const VisualDensity(horizontal: -1, vertical: -2) : VisualDensity.compact,
//   //     leading: CircleAvatar(
//   //       radius: avatar,
//   //       backgroundColor: Colors.grey.shade200,
//   //       child: ClipOval(
//   //         child: Image.network(
//   //           'https://erp.kendroo.io${emp.imageUrl}',
//   //           headers: {'Cookie': session},
//   //           fit: BoxFit.cover,
//   //           width: avatar * 2,
//   //           height: avatar * 2,
//   //           errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 22, color: Colors.grey),
//   //         ),
//   //       ),
//   //     ),
//   //     title: Text(
//   //       emp.name,
//   //       maxLines: 1,
//   //       overflow: TextOverflow.ellipsis,
//   //       style: TextStyle(fontWeight: FontWeight.w600, fontSize: titleSize),
//   //       textScaler: MediaQuery.textScalerOf(context),
//   //     ),
//   //     subtitle: Text(
//   //       '${emp.jobTitle}\n${emp.department}',
//   //       maxLines: parentW < 360 ? 2 : 3,
//   //       overflow: TextOverflow.ellipsis,
//   //       style: TextStyle(fontSize: subSize, color: Colors.black87),
//   //       textScaler: MediaQuery.textScalerOf(context),
//   //     ),
//   //     isThreeLine: parentW >= 360,
//   //     trailing: parentW < 340 ? null : const Icon(Icons.arrow_forward_ios, size: 16),
//   //     onTap: () {
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(builder: (_) => EmployeeDetailsView(employee: emp)),
//   //       );
//   //     },
//   //   );
//   // }
//
//
//   Widget _buildEmployeeTile(BuildContext context, Employee emp, double parentW) {
//     final session = Provider.of<AuthProvider>(context, listen: false).sessionCookie ?? '';
//
//     // Responsive sizes
//     final avatarRadius = parentW < 340 ? 20.0 : (parentW < 420 ? 24.0 : 25.0);
//     final titleSize    = parentW < 340 ? 14.0 : (parentW < 420 ? 15.0 : 16.0);
//     final subSize      = parentW < 340 ? 12.0 : 13.0;
//     final dense        = parentW < 360;
//
//     // 🔹 Build avatar ImageProvider from base64 (like you did for customers)
//     ImageProvider? avatarImage;
//     if (emp.imageUrl.isNotEmpty) {
//       try {
//         final bytes = base64Decode(emp.imageUrl);
//         avatarImage = MemoryImage(bytes);
//       } catch (e) {
//         debugPrint('Failed to decode employee image: $e');
//       }
//     }
//
//     // If you ALSO still have URL-based images and want to fallback to that
//     // when there is no base64, you could do:
//     //
//     // if (avatarImage == null && emp.imageUrl.isNotEmpty) {
//     //   avatarImage = NetworkImage(
//     //     'https://erp.kendroo.io${emp.imageUrl}',
//     //     headers: {'Cookie': session},
//     //   );
//     // }
//
//     return ListTile(
//       dense: dense,
//       visualDensity: dense
//           ? const VisualDensity(horizontal: -1, vertical: -2)
//           : VisualDensity.compact,
//       leading: CircleAvatar(
//         radius: avatarRadius,
//         backgroundColor: avatarImage == null
//             ? Colors.blue.shade100 // or any color you prefer for employees
//             : Colors.transparent,
//         backgroundImage: avatarImage,
//         child: avatarImage == null
//             ? const Icon(
//           Icons.person,
//           size: 22,
//           color: Colors.blue,
//         )
//             : null,
//       ),
//       title: Text(
//         emp.name,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         style: TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: titleSize,
//         ),
//         textScaler: MediaQuery.textScalerOf(context),
//       ),
//       subtitle: Text(
//         '${emp.jobTitle}\n${emp.department}',
//         maxLines: parentW < 360 ? 2 : 3,
//         overflow: TextOverflow.ellipsis,
//         style: TextStyle(
//           fontSize: subSize,
//           color: Colors.black87,
//         ),
//         textScaler: MediaQuery.textScalerOf(context),
//       ),
//       isThreeLine: parentW >= 360,
//       trailing:
//       parentW < 340 ? null : const Icon(Icons.arrow_forward_ios, size: 16),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => EmployeeDetailsView(employee: emp),
//           ),
//         );
//       },
//     );
//   }
//
//
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/all_employee_model.dart';
import '../../provider/all_employee_provider.dart';
import '../../provider/auth_provider.dart';
import 'employee_details_view.dart';

class AllEmployeesPage extends StatefulWidget {
  const AllEmployeesPage({super.key});

  @override
  State<AllEmployeesPage> createState() => _AllEmployeesPageState();
}

class _AllEmployeesPageState extends State<AllEmployeesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => Provider.of<AllEmployeeProvider>(context, listen: false)
          .loadEmployees(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AllEmployeeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Employees'),
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
          : LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;

          // Simple breakpoints (you can extend later)
          final isPhone = w < 600;
          final isTablet = w >= 600 && w < 1024;
          final crossAxisCount =
          isPhone ? 1 : (isTablet ? 2 : 3); // reserved if you add grid later

          // Scale spacing by width
          final hPad = w < 360 ? 8.0 : 12.0;
          final vGap = w < 360 ? 6.0 : 10.0;

          // For now: phone-style list
          return ListView.separated(
            padding: EdgeInsets.all(hPad),
            separatorBuilder: (_, __) => SizedBox(height: vGap),
            itemCount: provider.employees.length,
            itemBuilder: (_, i) => _buildEmployeeTile(
              context,
              provider.employees[i],
              w,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmployeeTile(
      BuildContext context, Employee emp, double parentW) {
    final session =
        Provider.of<AuthProvider>(context, listen: false).sessionCookie ?? '';

    // Responsive sizes
    final avatarRadius =
    parentW < 340 ? 20.0 : (parentW < 420 ? 24.0 : 25.0);
    final titleSize =
    parentW < 340 ? 14.0 : (parentW < 420 ? 15.0 : 16.0);
    final subSize = parentW < 340 ? 12.0 : 13.0;
    final dense = parentW < 360;

    // 🔹 Build avatar ImageProvider
    ImageProvider? avatarImage;

    // 1) Try base64 if present (for future / custom API)
    if (emp.imageUrl.isNotEmpty) {
      try {
        final bytes = base64Decode(emp.imageUrl);
        avatarImage = MemoryImage(bytes);
      } catch (e) {
        debugPrint('Failed to decode employee base64 image: $e');
      }
    }

    // 2) Fallback to URL image from Odoo if base64 is empty or failed
    if (avatarImage == null && emp.imageUrl.isNotEmpty) {
      try {
        avatarImage = NetworkImage(
          'https://demo.kendroo.com${emp.imageUrl}',
          headers: {'Cookie': session},
        );
      } catch (e) {
        debugPrint('Failed to create NetworkImage for employee: $e');
      }
    }

    return ListTile(
      dense: dense,
      visualDensity: dense
          ? const VisualDensity(horizontal: -1, vertical: -2)
          : VisualDensity.compact,
      leading: CircleAvatar(
        radius: avatarRadius,
        backgroundColor:
        avatarImage == null ? Colors.blue.shade100 : Colors.transparent,
        backgroundImage: avatarImage,
        child: avatarImage == null
            ? const Icon(
          Icons.person,
          size: 22,
          color: Colors.blue,
        )
            : null,
      ),
      title: Text(
        emp.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: titleSize,
        ),
        textScaler: MediaQuery.textScalerOf(context),
      ),
      subtitle: Text(
        '${emp.jobTitle}\n${emp.department}',
        maxLines: parentW < 360 ? 2 : 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: subSize,
          color: Colors.black87,
        ),
        textScaler: MediaQuery.textScalerOf(context),
      ),
      isThreeLine: parentW >= 360,
      trailing:
      parentW < 340 ? null : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmployeeDetailsView(employee: emp),
          ),
        );
      },
    );
  }
}

