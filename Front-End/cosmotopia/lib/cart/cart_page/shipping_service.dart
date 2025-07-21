class ShippingService {
  static const String warehouseAddress = '39 Phan Huy Ích, Phường An Hội Tây, Thành Phố Hồ Chí Minh';
  static const double taxRate = 0.10; // 10% VAT for cosmetics
  static const int defaultShippingFee = 20000;

  static String calculateDeliveryTime(String userAddr) {
    if (userAddr.isEmpty) return 'Không thể tính toán';
    
    String lowerAddr = userAddr.toLowerCase();
    
    // Same expanded city (Ho Chi Minh City - after merger)
    if (lowerAddr.contains('hồ chí minh') || lowerAddr.contains('tp hcm') || lowerAddr.contains('sài gòn') ||
        lowerAddr.contains('thủ đức') || lowerAddr.contains('dĩ an') || lowerAddr.contains('thuận an') ||
        lowerAddr.contains('vũng tàu') || lowerAddr.contains('bà rịa')) {
      if (lowerAddr.contains('tân phú') || lowerAddr.contains('an hội')) {
        return '1-2 giờ';
      }
      return '2-4 giờ';
    }
    
    // Different city but same region (South Vietnam)
    if (lowerAddr.contains('đồng nai') || lowerAddr.contains('long an') || 
        lowerAddr.contains('tây ninh') || lowerAddr.contains('cần thơ') ||
        lowerAddr.contains('an giang') || lowerAddr.contains('tiền giang')) {
      return '1-2 ngày';
    }
    
    // Central Vietnam
    if (lowerAddr.contains('đà nẵng') || lowerAddr.contains('huế') || 
        lowerAddr.contains('nha trang') || lowerAddr.contains('quy nhon')) {
      return '2-3 ngày';
    }
    
    // North Vietnam
    if (lowerAddr.contains('hà nội') || lowerAddr.contains('hải phòng') || 
        lowerAddr.contains('nam định') || lowerAddr.contains('thái bình')) {
      return '3-5 ngày';
    }
    
    return '3-7 ngày';
  }

  static int calculateShippingFee(String userAddr) {
    if (userAddr.isEmpty) return defaultShippingFee;
    
    String lowerAddr = userAddr.toLowerCase();
    
    if (_isWithinFreeShippingRadius(lowerAddr)) {
      return 0; // Free shipping
    }
    
    // Same city (Ho Chi Minh City) but different ward/area
    if (lowerAddr.contains('hồ chí minh') || lowerAddr.contains('tp hcm') || lowerAddr.contains('sài gòn') ||
        lowerAddr.contains('thủ đức') || lowerAddr.contains('thu duc') ||
        lowerAddr.contains('dĩ an') || lowerAddr.contains('di an') ||
        lowerAddr.contains('thuận an') || lowerAddr.contains('thuan an') ||
        lowerAddr.contains('vũng tàu') || lowerAddr.contains('vung tau') ||
        lowerAddr.contains('bà rịa') || lowerAddr.contains('ba ria')) {
      return 15000;
    }
    
    // Different city but same region (South Vietnam)
    if (lowerAddr.contains('đồng nai') || lowerAddr.contains('long an') || 
        lowerAddr.contains('tây ninh') || lowerAddr.contains('cần thơ') ||
        lowerAddr.contains('an giang') || lowerAddr.contains('tiền giang')) {
      return 25000;
    }
    
    // Central Vietnam
    if (lowerAddr.contains('đà nẵng') || lowerAddr.contains('huế') || 
        lowerAddr.contains('nha trang') || lowerAddr.contains('quy nhon') ||
        lowerAddr.contains('quảng nam') || lowerAddr.contains('quảng ngãi')) {
      return 35000;
    }
    
    // North Vietnam
    if (lowerAddr.contains('hà nội') || lowerAddr.contains('hải phòng') || 
        lowerAddr.contains('nam định') || lowerAddr.contains('thái bình') ||
        lowerAddr.contains('quảng ninh') || lowerAddr.contains('hải dương')) {
      return 45000;
    }
    
    return 30000; // Default
  }

  static bool _isWithinFreeShippingRadius(String userAddr) {
    if (userAddr.contains('an hội tây') || userAddr.contains('an hoi tay')) {
      return true;
    }
    
    List<String> formerTanPhuWards = [
      'hiệp tân', 'hòa thạnh', 'phú thạnh', 'phú trung',
      'sơn kỳ', 'tân quý', 'tân sơn nhì', 'tây thạnh',
      'an hoi tay', 'an hội tây'
    ];
    
    for (String ward in formerTanPhuWards) {
      if (userAddr.contains(ward)) return true;
    }
    
    List<String> nearbyWards = [
      'phường 1', 'phường 2', 'phường 3', 'phường 4', 'phường 5',
      'phường 6', 'phường 7', 'phường 8', 'phường 9', 'phường 10',
      'phường 11', 'phường 12', 'phường 13', 'phường 14',
      'phường 15', 'phường 16', 'phường 17',
      'gò vấp', 'go vap', 'phường 1 gò vấp', 'phường 3 gò vấp',
      'bình tân', 'binh tan', 'an lạc', 'an lac', 'bình hưng hòa',
      'bình hưng hoa', 'tân tạo', 'tan tao'
    ];
    
    for (String ward in nearbyWards) {
      if (userAddr.contains(ward)) return true;
    }
    
    return false;
  }

  static int calculateTax(List<dynamic> cartItems) {
    if (cartItems.isEmpty) return 0;
    
    num subtotal = cartItems.fold<num>(0, (sum, item) => 
      sum + ((item['product']['price'] ?? 0) * (item['quantity'] ?? 1))
    );
    
    double tax = subtotal * taxRate;
    return (tax / 1000).round() * 1000;
  }
} 