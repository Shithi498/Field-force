
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/employee_model.dart';
import '../provider/auth_provider.dart';
import '../provider/employee_provider.dart';

class EmployeeProfilePage extends StatefulWidget {
  const EmployeeProfilePage({super.key});

  @override
  State<EmployeeProfilePage> createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  // Removed TabController initialization and disposal

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<EmployeeProvider>(context, listen: false).loadProfile());
  }

  @override
  void dispose() {
    // No TabController to dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
          child: Text(provider.error!,
              style: const TextStyle(color: Colors.redAccent)))
          : provider.profile == null
          ? const Center(child: Text('No data'))
          : _buildProfile(context, provider),
    );
  }

  // Widget _buildProfile(BuildContext context, EmployeeProvider provider) {
  //   // We can safely access provider.profile! here because of the checks in build()
  //   final emp = provider.profile!.employee;
  //   // Assuming AuthProvider is available
  //   final sessionCookie = Provider.of<AuthProvider>(context, listen: false).sessionCookie ?? '';
  //   final w = MediaQuery.of(context).size.width;
  //
  //
  //   return SingleChildScrollView(
  //     child: Column(
  //       children: [
  //         // --- Profile Header Section ---
  //         Stack(
  //           alignment: Alignment.topCenter,
  //           children: [
  //             // 2. Profile Content (Name, Title, Location, Profile Pic, Contact Info)
  //             Padding(
  //               padding: const EdgeInsets.only(top: 20), // Adjust to overlap with the header
  //               child: Column(
  //                 children: [
  //                   // Profile Picture
  //                   Stack(
  //                     alignment: Alignment.center,
  //                     children: [
  //                       Container(
  //                         width: 110,
  //                         height: 110,
  //                         decoration: BoxDecoration(
  //                           shape: BoxShape.circle,
  //                           border: Border.all(color: Colors.white, width: 3),
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: Colors.black.withOpacity(0.1),
  //                               blurRadius: 10,
  //                             ),
  //                           ],
  //                         ),
  //                         child: ClipOval(
  //                           child: Image.network(
  //                             'https://demo.kendroo.com${emp.imageUrl}',
  //                             headers: {'Cookie': sessionCookie},
  //                             fit: BoxFit.cover,
  //                             width: 110,
  //                             height: 110,
  //                             errorBuilder: (context, error, stackTrace) =>
  //                             const Icon(Icons.person, size: 60, color: Colors.grey),
  //                           ),
  //                         ),
  //                       ),
  //                       // Edit Icon on the profile picture
  //                       Positioned(
  //                         right: 0,
  //                         bottom: 0,
  //                         child: Container(
  //                           padding: const EdgeInsets.all(4),
  //                           decoration: const BoxDecoration(
  //                             color: Colors.white,
  //                             shape: BoxShape.circle,
  //                           ),
  //                           child: const Icon(Icons.camera_alt_outlined, size: 18, color: Colors.grey),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 16),
  //                   // Row(
  //                   //   mainAxisAlignment: MainAxisAlignment.center,
  //                   //   children: [
  //                   //     Text(emp.name,
  //                   //         style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
  //                   //     const SizedBox(width: 8),
  //                   //     // Edit icon next to the name
  //                   //     const Icon(Icons.edit, size: 18, color: Colors.grey),
  //                   //   ],
  //                   // ),
  //
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Flexible(
  //                         child: Text(
  //                           emp.name,
  //                           maxLines: 1,
  //                           overflow: TextOverflow.ellipsis,
  //                           style: TextStyle(
  //                             fontSize: (MediaQuery.of(context).size.width * 0.055)
  //                                 .clamp(16.0, 24.0),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //
  //                       SizedBox(
  //                         width: (MediaQuery.of(context).size.width * 0.02)
  //                             .clamp(4.0, 10.0),
  //                       ),
  //
  //                       Icon(
  //                         Icons.edit,
  //                         size: (MediaQuery.of(context).size.width * 0.045)
  //                             .clamp(14.0, 20.0),
  //                         color: Colors.grey,
  //                       ),
  //                     ],
  //                   ),
  //
  //                   // Text(emp.jobTitle,
  //                   //     style: const TextStyle(color: Colors.black54, fontSize: 16)),
  //
  //                   Text(
  //                     emp.jobTitle,
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: TextStyle(
  //                       color: Colors.black54,
  //                       fontSize: (MediaQuery.of(context).size.width * 0.04)
  //                           .clamp(13.0, 18.0), // responsive font size
  //                     ),
  //                   ),
  //
  //
  //                   const SizedBox(height: 16),
  //                   // Contact Info Section with Profile Completion
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                       children: [
  //                         _contactInfoTile(Icons.phone, emp.workPhone.replaceAll(' ', ''),),
  //                         _contactInfoTile(Icons.email, emp.workEmail, ),
  //
  //                       ],
  //                     ),
  //                   ),
  //                   const SizedBox(height: 16),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //
  //         // --- Personal Information Section (Main Content) ---
  //         const Divider(height: 1, thickness: 1),
  //         _buildPersonalTab(emp,),
  //       ],
  //     ),
  //   );
  // }

  // inside your profile screen widget

  Widget _buildProfile(BuildContext context, EmployeeProvider provider) {
    final emp = provider.profile!.employee;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final sessionCookie = auth.sessionCookie ?? '';

    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          // --- Profile Header Section ---
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    // Profile Picture
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: emp.imageUrl.isNotEmpty
                                ? Image.network(
                              'https://demo.kendroo.com${emp.imageUrl}',
                              headers: sessionCookie.isNotEmpty
                                  ? {'Cookie': sessionCookie}
                                  : null,
                              fit: BoxFit.cover,
                              width: 110,
                              height: 110,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                debugPrint(
                                    '🟥 Profile image error: $error');
                                return const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                );
                              },
                            )
                                : const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        // Edit Icon on the profile picture
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name + edit icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            emp.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize:
                              (width * 0.055).clamp(16.0, 24.0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: (width * 0.02).clamp(4.0, 10.0),
                        ),
                        Icon(
                          Icons.edit,
                          size: (width * 0.045).clamp(14.0, 20.0),
                          color: Colors.grey,
                        ),
                      ],
                    ),

                    // Job title
                    Text(
                      emp.jobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize:
                        (width * 0.04).clamp(13.0, 18.0),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Contact info row
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                        children: [
                          _contactInfoTile(
                            Icons.phone,
                            emp.workPhone.replaceAll(' ', ''),
                          ),
                          _contactInfoTile(
                            Icons.email,
                            emp.workEmail,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 1, thickness: 1),

          // Your own function for the details section
          _buildPersonalTab(emp),
        ],
      ),
    );
  }






  Widget _contactInfoTile(IconData icon, String text) {
    // Find the non-email part of the contact for display (e.g., Kumaran@exsoftwares -> Kumaran)
    String displayString = text.contains('@')
        ? text.substring(0, text.indexOf('@')) // Display part before @ for email
        : text;

    // Shorten if still too long (e.g., if phone is long)
    if (displayString.length > 15) {
      displayString = '${displayString.substring(0, 12)}...';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 14),
            const SizedBox(width: 2),
            Text(displayString, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
        Text(
          text.contains('@') ? text.substring(text.indexOf('@')) : '', // Display '@exsoftwares' only for email
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }





  // Widget _buildPersonalTab(Employee emp,) {
  //
  //   return Padding(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text('Personal Information',
  //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //
  //           ],
  //         ),
  //         const Divider(),
  //         _personalInfoRow('Name', emp.name),
  //
  //         _personalInfoRow('Manager', emp.manager),
  //         _personalInfoRow('Department', emp.department),
  //         _personalInfoRow('Company', emp.company),
  //
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPersonalTab(Employee emp) {
    final w = MediaQuery.of(context).size.width;

    // Responsive text sizes
    final titleSize = (w * 0.048).clamp(16.0, 20.0);

    // Responsive padding
    final horizontalPad = (w * 0.04).clamp(12.0, 22.0);

    return Padding(
      padding: EdgeInsets.all(horizontalPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),

          _personalInfoRow('Name', emp.name),
          _personalInfoRow('Manager', emp.manager),
          _personalInfoRow('Department', emp.department),
          _personalInfoRow('Company', emp.company),
        ],
      ),
    );
  }


  // Helper widget for Personal Information rows
  // Widget _personalInfoRow(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6.0),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(
  //           width: 130, // Aligning the labels, increased width for safety
  //           child: Text(
  //             label,
  //             style: const TextStyle(color: Colors.black54, fontSize: 15),
  //           ),
  //         ),
  //         const Text('', style: TextStyle(color: Colors.grey, fontSize: 15)), // Removed colon for cleaner alignment
  //         Expanded(
  //           child: Text(
  //             value,
  //             style: const TextStyle(
  //                 color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _personalInfoRow(String label, String value) {
    final w = MediaQuery.of(context).size.width;

    // Label width becomes flexible based on screen size
    final labelWidth = (w * 0.32).clamp(90.0, 150.0);

    // Font sizes
    final labelFont = (w * 0.036).clamp(12.0, 15.0);
    final valueFont = (w * 0.038).clamp(13.0, 16.0);

    // Vertical spacing
    final rowSpacing = (w * 0.018).clamp(4.0, 10.0);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: rowSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive label column
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black54,
                fontSize: labelFont,
              ),
            ),
          ),

          // Value
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: valueFont,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


}

