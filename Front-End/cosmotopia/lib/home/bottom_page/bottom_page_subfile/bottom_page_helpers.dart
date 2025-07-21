import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cosmotopia/backend/schema/structs/product_struct.dart';
import 'package:cosmotopia/backend/schema/structs/detail_struct.dart';
import 'package:cosmotopia/backend/schema/structs/order_struct.dart';

class BottomPageHelpers {
  static String formatPrice(String priceString) {
    final priceValue = int.tryParse(priceString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(priceValue);
  }

  static Widget buildProductImage(String imageUrl, {double? width, double? height, BoxFit? fit}) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width ?? double.infinity,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/placeholder.png',
            width: width ?? double.infinity,
            height: height,
            fit: fit ?? BoxFit.cover,
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl.isNotEmpty ? imageUrl : 'assets/images/placeholder.png',
        width: width ?? double.infinity,
        height: height,
        fit: fit ?? BoxFit.cover,
      );
    }
  }

  static DetailStruct convertProductToDetail(ProductStruct product) {
    return DetailStruct(
      productId: product.productId,
      id: product.productId.hashCode,
      image: product.imageUrls.isNotEmpty ? product.imageUrls.first : 'assets/images/placeholder.png',
      title: product.name,
      price: product.price.toString(),
      catetype: product.category['name'] ?? '',
      stockQuantity: product.stockQuantity.toString(),
      description: product.description,
      brandName: product.brand['name'] ?? '',
      isFav: FFAppState().isProductFavorite(product.productId),
      isJust: false,
      isNew: false,
      isCart: false,
      isColor: false,
      isResult: '',
      itsResult: false,
    );
  }

  static String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Paid';
      case 2:
        return 'Shipped';
      case 3:
        return 'Delivered';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  static Color getStatusColor(int status, BuildContext context) {
    switch (status) {
      case 0:
        return Color(0xFFFF9800); // Orange for pending
      case 1:
        return Color(0xFF4CAF50); // Green for paid
      case 2:
        return Color(0xFF2196F3); // Blue for shipped
      case 3:
        return Color(0xFF8BC34A); // Light green for delivered
      case 4:
        return Color(0xFFF44336); // Red for cancelled
      default:
        return FlutterFlowTheme.of(context).secondaryText;
    }
  }

  // Refresh trigger methods
  static void triggerDataRefresh() {
    FFAppState().triggerDataRefresh();
    print('🔄 BottomPageHelpers: Triggered general data refresh');
  }

  static void triggerProductRefresh() {
    FFAppState().triggerProductRefresh();
    print('🔄 BottomPageHelpers: Triggered product refresh');
  }

  static void triggerCategoryRefresh() {
    FFAppState().triggerDataRefresh(); // Categories are part of general refresh
    print('🔄 BottomPageHelpers: Triggered category refresh');
  }
} 