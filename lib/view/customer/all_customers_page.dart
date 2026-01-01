import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/customer_model.dart';
import '../../provider/customer_provider.dart';
import 'create_customer_dialog.dart';
import 'customer_details_page.dart';


class AllCustomersPage extends StatefulWidget {
  const AllCustomersPage({super.key});

  @override
  State<AllCustomersPage> createState() => _AllCustomersPageState();
}

class _AllCustomersPageState extends State<AllCustomersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).loadCustomers());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Customers'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Create Customer",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateCustomerPage()),
              );

            },
          ),
        ],

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
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: provider.customers.length,
        itemBuilder: (_, index) {
          final cust = provider.customers[index];
          return _buildCustomerTile(cust);
        },
      ),
    );
  }

  // Widget _buildCustomerTile(Customer cust) {
  //   final isCompany = cust.isCompany;
  //   return ListTile(
  //     leading: CircleAvatar(
  //       backgroundColor: isCompany ? Colors.blue.shade100 : Colors.green.shade100,
  //       child: Icon(
  //         isCompany ? Icons.business : Icons.person,
  //         color: isCompany ? Colors.blue : Colors.green,
  //       ),
  //     ),
  //     title: Text(
  //       cust.name,
  //       style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
  //     ),
  //     subtitle: Text(
  //       '${cust.email.isNotEmpty ? cust.email : "No email"}\n'
  //           '${cust.city.isNotEmpty ? cust.city : "No city"}, ${cust.country.isNotEmpty ? cust.country : "N/A"}',
  //     ),
  //     isThreeLine: true,
  //     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  //     onTap: () {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (_) => CustomerDetailsView(customer: cust),
  //         ),
  //       );
  //     },
  //
  //   );
  // }

  Widget _buildCustomerTile(Customer cust) {
    final isCompany = cust.isCompany;
    final w = MediaQuery.of(context).size.width;

    // Responsive tweaks based on width
    final isTiny    = w < 340;
    final isCompact = w < 360;

    final avatarRadius = isTiny ? 18.0 : 22.0;
    final iconSize     = isTiny ? 18.0 : 22.0;
    final titleSize    = isTiny ? 14.0 : (w < 420 ? 15.0 : 16.0);
    final subSize      = isTiny ? 12.0 : 13.0;

    final emailText  = cust.email.isNotEmpty ? cust.email : 'No email';
    final cityText   = cust.city.isNotEmpty ? cust.city : 'No city';
    final countryTxt = cust.country.isNotEmpty ? cust.country : 'N/A';

    final subtitleText = '$emailText\n$cityText, $countryTxt';
    ImageProvider? avatarImage;
    if (cust.image_base64.isNotEmpty) {
      try {
        final bytes = base64Decode(cust.image_base64);
        avatarImage = MemoryImage(bytes);
      } catch (e) {
        // if decode fails, keep avatarImage = null, we’ll fall back to icon
        debugPrint('Failed to decode customer image: $e');
      }
    }
    return ListTile(
      dense: isCompact,
      visualDensity: isCompact
          ? const VisualDensity(horizontal: -1, vertical: -2)
          : VisualDensity.compact,
      leading: CircleAvatar(
        radius: avatarRadius,
        backgroundColor: avatarImage == null
            ? (isCompany ? Colors.blue.shade100 : Colors.green.shade100)
            : Colors.transparent,
        backgroundImage: avatarImage,
        child: avatarImage == null
            ? Icon(
          isCompany ? Icons.business : Icons.person,
          color: isCompany ? Colors.blue : Colors.green,
          size: iconSize,
        )
            : null,
      ),
      title: Text(
        cust.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: titleSize,
        ),
      ),
      subtitle: Text(
        subtitleText,
        maxLines: isTiny ? 2 : 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: subSize,
          color: Colors.black87,
        ),
      ),
      isThreeLine: !isTiny,
      trailing: isTiny
          ? null
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CustomerDetailsView(customer: cust),
          ),
        );
      },
    );
  }
}
