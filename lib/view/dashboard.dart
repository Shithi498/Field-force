// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../model/conversation.dart';
// import '../provider/auth_provider.dart';
// import '../provider/chat_provider.dart';
// import 'customer/all_customers_page.dart';
// import 'employee/all_employee_page.dart';
// import 'products/all_products_page.dart';
// import 'attendance_view.dart';
// import 'discuss/chat_page.dart';
// import 'discuss/inbox_page.dart';
// import 'employee_profile_page.dart';
// import 'leave/leave_page.dart';
//
//
// class DashboardScreen extends StatelessWidget {
//
//   const DashboardScreen({super.key, });
//
//   final List<_AppTile> apps = const [
//     _AppTile(title:'Discuss',icon: Icons.chat_bubble_outline,color: Colors.orange),
//      _AppTile(
//       title: 'Employees',
//       //color: Colors.teal,
//       image: Image(image: AssetImage('assets/icon/employees.png')),
//     ),
//     const _AppTile(
//       title: 'Products',
//    //   color: Colors.purple,
//       image: Image(image: AssetImage('assets/icon/product.png')),
//     ),
//     const _AppTile(
//       title: 'Dashboards',
//       color: Colors.indigo,
//       icon: Icons.dashboard_customize_outlined,
//     ),
//     const _AppTile(
//       title: 'Profile',
//       color: Colors.green,
//       icon: Icons.person,
//     ),
//
//     const _AppTile(
//       title: 'Attendance',
//      // color: Colors.brown,
//       image: Image(image: AssetImage('assets/icon/attendances.png')),
//     ),
//     const _AppTile(
//       title: 'Customers',
//   //    color: Colors.redAccent,
//       image: Image(image: AssetImage('assets/icon/customer.png')),
//     ),
//     const _AppTile(
//       title: 'Leave',
//     //  color: Colors.grey,
//       image: Image(image: AssetImage('assets/icon/leave.png')),
//     ),
//
//   ];
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           const LinearGradientBackground(),
//           SafeArea(
//             child: Column(
//               children: [
//                 const _TopHeaderBar(),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: GridView.builder(
//                       itemCount: apps.length,
//                       gridDelegate:
//                       const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 18,
//                         mainAxisSpacing: 18,
//                         childAspectRatio: 0.9,
//                       ),
//                       itemBuilder: (context, index) {
//                         final app = apps[index];
//                         return _DashboardIconTile(app: app,);
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
// class _TopHeaderBar extends StatelessWidget {
//   const _TopHeaderBar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding:
//       const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 10, bottom: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           const Icon(Icons.circle, color: Colors.red, size: 12),
//           const SizedBox(width: 14),
//           const _IconBadge(icon: Icons.chat_bubble_outline, count: 6, color: Colors.black87),
//           const SizedBox(width: 14),
//           const _IconBadge(icon: Icons.access_time_outlined, count: 14, color: Colors.black87),
//           const SizedBox(width: 16),
//           const Text(
//             "YourCompany",
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(width: 10),
//           const CircleAvatar(
//             radius: 15,
//           //  backgroundImage: AssetImage('assets/avatar.png'),
//             backgroundColor: Colors.transparent,
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await Provider.of<AuthProvider>(context, listen: false).logout(context);
//             },
//             child: Image(image: AssetImage('assets/icon/logout.png')),
//           )
//
//         ],
//       ),
//     );
//   }
// }
//
// class _IconBadge extends StatelessWidget {
//   final IconData icon;
//   final int count;
//   final Color color;
//   const _IconBadge({
//     required this.icon,
//     required this.count,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         Icon(icon, color: color, size: 24),
//         if (count > 0)
//           Positioned(
//             right: -6,
//             top: -6,
//             child: Container(
//               padding: const EdgeInsets.all(2),
//               decoration: const BoxDecoration(
//                 color: Colors.red,
//                 shape: BoxShape.circle,
//               ),
//               constraints: const BoxConstraints(
//                 minWidth: 16,
//                 minHeight: 16,
//               ),
//               child: Text(
//                 '$count',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
//
//
// class _DashboardIconTile extends StatelessWidget {
//   final _AppTile app;
//
//
//   const _DashboardIconTile({required this.app,super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         if (app.title == 'Profile') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               //   builder: (context) => InvoiceListPage(rpc: rpc),
//               builder: (context) => EmployeeProfilePage(),
//             ),
//           );
//         }
//      else if (app.title == 'Employees') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               //   builder: (context) => InvoiceListPage(rpc: rpc),
//               builder: (context) => AllEmployeesPage(),
//             ),
//           );
//         }
//         else if (app.title == 'Attendance') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               //   builder: (context) => InvoiceListPage(rpc: rpc),
//               builder: (context) => AttendancePage(),
//             ),
//           );
//         }
//         else if (app.title == 'Products') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               //   builder: (context) => InvoiceListPage(rpc: rpc),
//               builder: (context) => AllProductsPage(),
//             ),
//           );
//         }
//         else if (app.title == 'Customers') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               //   builder: (context) => InvoiceListPage(rpc: rpc),
//               builder: (context) => AllCustomersPage(),
//             ),
//           );
//         }
//         else if (app.title == 'Leave') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               //   builder: (context) => InvoiceListPage(rpc: rpc),
//               builder: (context) => LeavePage(),
//             ),
//           );
//         }
//         else if (app.title == 'Discuss') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               //   builder: (context) => InvoiceListPage(rpc: rpc),
//               builder: (context) => InboxPage(),
//             ),
//           );
//         }
//
//         // else if (app.title == 'Discuss') {
//         //   final chat = context.read<ChatProvider>();
//         //   final auth = context.read<AuthProvider>();
//         //
//         //   // must be logged in if your repo needs cookie
//         //   if (auth.user == null) {
//         //     ScaffoldMessenger.of(context).showSnackBar(
//         //       const SnackBar(content: Text('Please log in first')),
//         //     );
//         //     return;
//         //   }
//         //
//         //   await chat.loadInbox();
//         //   if (chat.inbox.isEmpty) {
//         //     ScaffoldMessenger.of(context).showSnackBar(
//         //       const SnackBar(content: Text('No conversations yet')),
//         //     );
//         //     return;
//         //   }
//         //
//         //   final conv = chat.inbox.first; // or let user choose from a list
//         //   if (!context.mounted) return;
//         //   Navigator.push(
//         //     context,
//         //     MaterialPageRoute(builder: (_) => ChatPage(conv: conv)),
//         //   );
//         // }
//
//         else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('${app.title} clicked')),
//           );
//         }
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 6,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: app.color?.withOpacity(0.15) ?? Colors.grey.withOpacity(0.15),
//               child: app.image != null
//                   ? ClipOval(
//                 child: Padding(
//                   padding: const EdgeInsets.all(6.0),
//                   child: app.image, // show asset image
//                 ),
//               )
//                   : Icon(app.icon, color: app.color, size: 30),
//             ),
//
//             const SizedBox(height: 10),
//             Text(
//               app.title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class _AppTile {
//   final String title;
//   final IconData? icon;   // optional
//   final Image? image;     // optional
//   final Color? color;
//
//   const _AppTile({
//     required this.title,
//      this.color,
//     this.icon,
//     this.image,
//   });
// }
//
//
// class LinearGradientBackground extends StatelessWidget {
//   const LinearGradientBackground({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFFF3F0FF), Color(0xFFEAE6FF)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//     );
//   }
// }
//
//
// class _CheckInOutTile extends StatelessWidget {
//   final bool isCheckedIn;
//   final VoidCallback onTap;
//
//   const _CheckInOutTile({
//     super.key,
//     required this.isCheckedIn,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final text = isCheckedIn ? 'Check Out' : 'Check In';
//     final color = isCheckedIn ? Colors.red : Colors.green;
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 6,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: color.withOpacity(0.12),
//               child: Icon(
//                 Icons.access_time_filled,
//                 color: color,
//                 size: 32,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               text,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:field_force_2/view/products/all_products_page.dart';
import 'package:field_force_2/view/projects_tasks_page.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;
import '../provider/auth_provider.dart';
import 'attendance_view.dart';
import 'customer/all_customers_page.dart';
import 'discuss/inbox_page.dart';
import 'employee/all_employee_page.dart';
import 'employee_profile_page.dart';
import 'journey_screen.dart';
import 'leave/leave_page.dart';
import 'package:flutter_map/flutter_map.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isCheckedIn = false;

  // Location plugin instance
  final loc.Location _location = loc.Location();
  final List<LatLng> _checkInLocations = [];

  final List<_AppTile> apps = const [
    // _AppTile(
    //   title: 'CheckInOut',
    //   color: Colors.blue,
    //   icon: Icons.access_time,
    // ),
    // _AppTile(
    //   title: 'CheckIn Map',
    //   color: Colors.blue,
    //   icon: Icons.map_outlined,
    // ),
    // _AppTile(
    //   title: 'Discuss',
    //   icon: Icons.chat_bubble_outline,
    //   color: Colors.orange,
    // ),
    _AppTile(
      title: 'Employees',
      image: Image(image: AssetImage('assets/icon/employees.png')),
    ),
    _AppTile(
      title: 'Products',
      image: Image(image: AssetImage('assets/icon/products.png')),
    ),
    _AppTile(
      title: 'Field Force',
      image: Image(image: AssetImage('assets/icon/location.png')),
    ),
    _AppTile(
      title: 'Profile',
     // color: Colors.green,
   //   icon: Icons.person,
      image: Image(image: AssetImage('assets/icon/profile.png')),
    ),
    _AppTile(
      title: 'Attendance',
      image: Image(image: AssetImage('assets/icon/calendar.png')),
    ),
    _AppTile(
      title: 'Customers',
      image: Image(image: AssetImage('assets/icon/customer.png')),
    ),
    _AppTile(
      title: 'Leave',
      image: Image(image: AssetImage('assets/icon/leave.png')),
    ),

    _AppTile(
      title: 'Projects',
     // color: Colors.green,
     // icon: Icons.task,
      image: Image(image: AssetImage('assets/icon/projects.png')),
    ),
  ];


  Future<bool> _ensureLocationReady() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location service is disabled. Please turn it on.'),
            ),
          );
        }
        return false;
      }
    }


    loc.PermissionStatus permission = await _location.hasPermission();
    if (permission == loc.PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != loc.PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied. Cannot check in.'),
            ),
          );
        }
        return false;
      }
    }

    return true;
  }

  Future<void> _toggleCheckInOut() async {
    if (!_isCheckedIn) {
      final ok = await _ensureLocationReady();
      if (!ok) return;

      final loc.LocationData pos = await _location.getLocation();
      final lat = pos.latitude;
      final lng = pos.longitude;

      if (lat == null || lng == null) {
        debugPrint('Could not get valid location');
        return;
      }

      debugPrint('Checked in at: lat=$lat, lng=$lng');

      if (!mounted) return;
      setState(() {
        _isCheckedIn = true;

        _checkInLocations.add(LatLng(lat, lng));
      });
      print("All check-ins so far:");
      for (var loc in _checkInLocations) {
        print("• ${loc.latitude}, ${loc.longitude}");
      }

    } else {

      debugPrint('User checking out');

      if (!mounted) return;
      setState(() {
        _isCheckedIn = false;

      });
    }

    if (!mounted) return;

    final msg = _isCheckedIn
        ? 'You are now Checked In'
        : 'You are now Checked Out';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );


// Print history


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const LinearGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                const _TopHeaderBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GridView.builder(
                      itemCount: apps.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final app = apps[index];

                        // if (app.title == 'CheckInOut') {
                        //   return _CheckInOutTile(
                        //     isCheckedIn: _isCheckedIn,
                        //     onTap: () => _toggleCheckInOut(),
                        //   );
                        // }
                        //
                        // if (app.title == 'CheckIn Map') {
                        //   return _DashboardIconTile(
                        //     app: app,
                        //     onTap: () {
                        //       Navigator.of(context).push(
                        //         MaterialPageRoute(
                        //           builder: (_) => CheckInMapScreen(
                        //             checkInLocations: List<LatLng>.from(_checkInLocations),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   );
                        // }

                        if (app.title == 'Customers') {
                          return _DashboardIconTile(
                            app: app,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AllCustomersPage(),
                                ),
                              );
                            },
                          );
                        }

                        if (app.title == 'Employees') {
                          return _DashboardIconTile(
                            app: app,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AllEmployeesPage(),
                                ),
                              );
                            },
                          );
                        }

                        if (app.title == 'Discuss') {
                          return _DashboardIconTile(
                            app: app,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const InboxPage(),
                                ),
                              );
                            },
                          );
                        }

                        if (app.title == 'Products') {
                          return _DashboardIconTile(
                            app: app,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AllProductsPage(),
                                ),
                              );
                            },
                          );
                        }

                        if (app.title == 'Profile') {
                          return _DashboardIconTile(
                            app: app,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const EmployeeProfilePage(),
                                ),
                              );
                            },
                          );
                        }

                        if (app.title == 'Attendance') {
                          return _DashboardIconTile(
                            app: app,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AttendancePage(),
                                ),
                              );
                            },
                          );
                        }

                        if (app.title == 'Projects & Tasks') {
                          return _DashboardIconTile(
                            app: app,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ProjectsTasksPage(),
                                ),
                              );
                            },
                          );
                        }
                        if (app.title == 'Leave') {
                          return _DashboardIconTile(
                            app: app,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LeavePage(),
                                ),
                              );
                            },
                          );
                        }

                        if (app.title == 'Field Force') {
                          return _DashboardIconTile(
                            app: app,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const JourneyScreen(),
                                ),
                              );
                            },
                          );
                        }

                        return _DashboardIconTile(app: app);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopHeaderBar extends StatelessWidget {
  const _TopHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final company = auth.user?.companyName ?? "Company";
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
       //   const Icon(Icons.circle, color: Colors.red, size: 12),
          const SizedBox(width: 14),
          // const _IconBadge(
          //   icon: Icons.chat_bubble_outline,
          //   count: 6,
          //   color: Colors.black87,
          // ),
          const SizedBox(width: 14),
          // const _IconBadge(
          //   icon: Icons.access_time_outlined,
          //   count: 14,
          //   color: Colors.black87,
          // ),
          const SizedBox(width: 16),
           Text(
            company,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 15,
            backgroundColor: Colors.transparent,
          ),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false)
                  .logout(context);
            },
            child: const Image(
              image: AssetImage('assets/icon/logout.png'),
            ),
          ),
        ],
      ),
    );
  }
}



class _DashboardIconTile extends StatelessWidget {
  final _AppTile app;
  final VoidCallback? onTap;

  const _DashboardIconTile({
    Key? key,
    required this.app,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseColor = app.color ?? Colors.grey.shade800;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
       //   color: baseColor.withOpacity(0.9),
          color: Color(0xFF28A745),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (app.image != null)
              SizedBox(height: 40, child: app.image)
            else if (app.icon != null)
              Icon(app.icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              app.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _AppTile {
  final String title;
  final IconData? icon;
  final Image? image;
  final Color? color;

  const _AppTile({
    required this.title,
    this.color,
    this.icon,
    this.image,
  });
}

class LinearGradientBackground extends StatelessWidget {
  const LinearGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
         colors: [Color(0xFFF3F0FF), Color(0xFFEAE6FF)],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}




