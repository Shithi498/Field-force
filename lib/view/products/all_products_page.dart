import 'package:field_force_2/view/products/product_details_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/product_model.dart';
import '../../provider/product_provider.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).loadProducts());
  }

  // @override
  // Widget build(BuildContext context) {
  //   final provider = context.watch<ProductProvider>();
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('All Products'),
  //       centerTitle: true,
  //     ),
  //     body: provider.isLoading
  //         ? const Center(child: CircularProgressIndicator())
  //         : provider.error != null
  //         ? Center(
  //       child: Text(provider.error!,
  //           style: const TextStyle(color: Colors.redAccent)),
  //     )
  //         : ListView.separated(
  //       padding: const EdgeInsets.all(12),
  //       separatorBuilder: (_, __) => const Divider(),
  //       itemCount: provider.products.length,
  //       itemBuilder: (_, index) {
  //         final product = provider.products[index];
  //         return _buildProductTile(product);
  //       },
  //     ),
  //   );
  // }

  // Widget _buildProductTile(Product product) {
  //   return ListTile(
  //     leading: const Icon(Icons.shopping_bag_outlined, color: Colors.blue),
  //     title: Text(
  //       product.name,
  //       style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
  //     ),
  //     subtitle: Text(
  //         'Price: ${product.listPrice} | UoM: ${product.uomName}\nType: ${product.type}'),
  //     isThreeLine: true,
  //     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  //     onTap: () {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (_) => ProductDetailsPage(product: product),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
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
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          return ListView.separated(
            padding: EdgeInsets.all((w * 0.03).clamp(8.0, 24.0)),
            separatorBuilder: (_, __) => Divider(
              thickness: (w * 0.002).clamp(0.5, 1.0),
            ),
            itemCount: provider.products.length,
            itemBuilder: (_, index) {
              final product = provider.products[index];
              return _buildProductTile(product,);
            },
          );
        },
      ),
    );
  }


  Widget _buildProductTile(Product product) {
    final w = MediaQuery.of(context).size.width;

    // ===== Responsive Sizes =====
    final iconSize   = (w * 0.055).clamp(18.0, 26.0);  // leading icon
    final arrowSize  = (w * 0.04).clamp(14.0, 18.0);   // trailing arrow
    final titleSize  = (w * 0.045).clamp(14.0, 18.0);  // product name
    final subSize    = (w * 0.035).clamp(12.0, 14.0);  // subtitle
    final verticalPad = (w * 0.015).clamp(6.0, 12.0);  // tile spacing

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPad * 0.3),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: (w * 0.04).clamp(10.0, 20.0),
          vertical: verticalPad,
        ),

        // Leading icon (responsive)
        leading: Icon(
          Icons.shopping_bag_outlined,
          color: Colors.blue,
          size: iconSize,
        ),

        // Title responsive
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: titleSize,
          ),
        ),

        // Subtitle responsive
        subtitle: Text(
          'Price: ${product.listPrice} | UoM: ${product.uomName}\nType: ${product.type}',
          style: TextStyle(
            fontSize: subSize,
            height: 1.25,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        isThreeLine: true,

        // Trailing arrow (responsive)
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: arrowSize,
          color: Colors.grey.shade600,
        ),

        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: product),
            ),
          );
        },
      ),
    );
  }

}
