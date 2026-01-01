import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/product_model.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String get _typeLabel {
    switch (widget.product.type.toLowerCase()) {
      case 'consu':
      case 'consumable':
        return 'Consumable';
      case 'product':
      case 'storable':
        return 'Storable Product';
      case 'service':
        return 'Service';
      default:
        return widget.product.type.isEmpty ? '—' : widget.product.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          // ===== Global responsive metrics =====
          final nameSize       = (w * 0.055).clamp(16.0, 24.0); // product name
          final nameMaxLines   = w < 360 ? 2 : 3;
          final titleTopGap    = (w * 0.03).clamp(8.0, 18.0);
          final titleImageGap  = (w * 0.06).clamp(12.0, 24.0);
          final sectionTopGap  = (w * 0.05).clamp(12.0, 22.0);

          // Image width/height relative to width
          final imageWidth  = (w * 0.75).clamp(200.0, 340.0);
          final imageHeight = (imageWidth * 0.6).clamp(120.0, 240.0);

          // Page padding
          final horizontalPadding = (w * 0.05).clamp(12.0, 24.0);
          final topPadding        = (w * 0.03).clamp(8.0, 16.0);
          final bottomPadding     = (w * 0.06).clamp(16.0, 32.0);

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              topPadding,
              horizontalPadding,
              bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Name + Thumbnail (responsive) =====
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: titleTopGap),
                    Center(
                      child: Text(
                        p.name,
                        maxLines: nameMaxLines,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: nameSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: titleImageGap),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          (w * 0.02).clamp(4.0, 10.0),
                        ),
                        child: Container(
                          width: imageWidth,
                          height: imageHeight,
                          color: Colors.grey.shade200,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1549187774-b4e9b0445b41?q=80&w=400&auto=format&fit:cover',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sectionTopGap),

                // ===== General Information (card-like details) =====
                _SectionCard(
                  title: 'General Information',
                  typeLabel: _typeLabel,
                  children: [
                    _InfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Product Type',
                      value: _typeLabel,
                    ),
                    _InfoRow(
                      icon: Icons.straighten,
                      label: 'Unit of Measure',
                      value: p.uomName.isEmpty ? '—' : p.uomName,
                    ),
                    _InfoRow(
                      icon: Icons.attach_money,
                      label: 'Sales Price',
                      value: '\$${p.listPrice.toStringAsFixed(2)}',
                    ),
                    _InfoRow(
                      icon: Icons.tag_outlined,
                      label: 'Internal Reference',
                      value: '—',
                    ),
                    _InfoRow(
                      icon: Icons.description_outlined,
                      label: 'Description',
                      value:
                      'Admin-facing description of ${p.name}. Adjust fields above to match your catalog.',
                      multiline: true,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
    required this.typeLabel,
  });

  final String title;
  final List<Widget> children;
  final String typeLabel;

  String get footerNote {
    switch (typeLabel) {
      case 'Consumable':
        return "Consumables are physical products for which you don't manage stock.";
      case 'Storable Product':
        return "Storable products are managed in stock with quantities on hand.";
      case 'Service':
        return "Services are non-material products; no stock is managed.";
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface.withOpacity(0.5);
    final w = MediaQuery.of(context).size.width;

    // Responsive metrics for card
    final cardRadius      = (w * 0.02).clamp(6.0, 12.0);
    final cardPad         = (w * 0.03).clamp(10.0, 18.0);
    final titleSize       = (w * 0.05).clamp(16.0, 20.0);
    final headerGap       = (w * 0.02).clamp(4.0, 10.0);
    final dividerGap      = (w * 0.02).clamp(4.0, 10.0);
    final rowsGap         = (w * 0.02).clamp(4.0, 12.0);
    final footerTopGap    = (w * 0.025).clamp(6.0, 14.0);
    final footerFontSize  = (w * 0.032).clamp(11.0, 13.0);
    final dividerThickness = (w * 0.002).clamp(0.7, 1.2);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      padding: EdgeInsets.all(cardPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(.85),
              letterSpacing: .2,
            ),
          ),
          SizedBox(height: headerGap),
          Divider(
            height: 1,
            thickness: dividerThickness,
            color: Colors.black.withOpacity(.08),
          ),
          SizedBox(height: dividerGap),

          // Rows with responsive vertical gaps
          ..._withDividers(children, rowsGap),

          if (footerNote.isNotEmpty) ...[
            SizedBox(height: footerTopGap),
            Text(
              footerNote,
              style: TextStyle(
                fontSize: footerFontSize,
                color: Colors.black.withOpacity(.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Insert light spacing between rows (not full dividers, to keep it airy).
  List<Widget> _withDividers(List<Widget> items, double gap) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) out.add(SizedBox(height: gap));
    }
    return out;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // Responsive metrics inside row
        final iconSize      = (w * 0.045).clamp(16.0, 20.0);
        final iconTopPad    = multiline ? (w * 0.004).clamp(1.0, 4.0) : 0.0;
        final gapIconLabel  = (w * 0.025).clamp(6.0, 12.0);
        final labelWidth    = (w * 0.32).clamp(90.0, 160.0);
        final rowVPadding   = (w * 0.01).clamp(4.0, 8.0);

        final labelFontSize = (w * 0.035).clamp(12.0, 14.0);
        final valueFontSize = (w * 0.036).clamp(13.0, 15.0);

        final labelStyle = TextStyle(
          color: Colors.black.withOpacity(.6),
          fontSize: labelFontSize,
          fontWeight: FontWeight.w600,
        );
        final valueStyle = TextStyle(
          color: Colors.black87,
          fontSize: valueFontSize,
          fontWeight: FontWeight.w700,
        );

        return Padding(
          padding: EdgeInsets.symmetric(vertical: rowVPadding),
          child: Row(
            crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: iconTopPad),
                child: Icon(icon, size: iconSize, color: Colors.black54),
              ),
              SizedBox(width: gapIconLabel),

              // Label
              SizedBox(
                width: labelWidth,
                child: Text(
                  label,
                  style: labelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Value
              Expanded(
                child: Text(
                  value,
                  style: valueStyle,
                  textAlign: TextAlign.left,
                  maxLines: multiline ? null : 1,
                  overflow:
                  multiline ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

