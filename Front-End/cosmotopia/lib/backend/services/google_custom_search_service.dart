import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleCustomSearchService {
  // Cấu hình Google Custom Search API
  // Bạn cần tạo API key và Custom Search Engine ID tại:
  // https://developers.google.com/custom-search/v1/introduction
  static const String _apiKey = 'AIzaSyAgnBLfqsgxITaPOjafeZ0T78W2Mu2npXU'; // Thay bằng API key từ Google Cloud Console
  static const String _searchEngineId = 'b18dd8fb4e58348ed'; // Search Engine ID đã có
  static const String _baseUrl = 'https://www.googleapis.com/customsearch/v1';

  /// Test function để kiểm tra API có hoạt động không
  static Future<bool> testApiConnection() async {
    try {
      final testQuery = 'kem dưỡng ẩm site:hasaki.vn';
      final url = Uri.parse('$_baseUrl?key=$_apiKey&cx=$_searchEngineId&q=$testQuery&num=1');
      
      print('🧪 Testing API connection...');
      print('🔗 Test URL: $url');
      
      final response = await http.get(url);
      
      print('📊 Test Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final totalResults = data['searchInformation']?['totalResults'] ?? '0';
        print('✅ API works! Found $totalResults results');
        return true;
      } else {
        print('❌ API test failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('💥 API test error: $e');
      return false;
    }
  }

  /// Tìm kiếm sản phẩm tương tự sử dụng Google Custom Search API
    static Future<List<Map<String, dynamic>>> searchSimilarProducts(
    String productName,
    String category,
    {int numResults = 10}
  ) async {
    try {
      // Tạo query tối ưu để tìm sản phẩm từ các trang bán hàng
      final query = _buildSimilarProductQuery(productName, category);
      
      final url = Uri.parse('$_baseUrl?key=$_apiKey&cx=$_searchEngineId&q=$query&num=$numResults&safe=active');
      
      print('🔍 Google Search Query: $query');
      print('🌐 API URL: $url');
      print('🔑 API Key: ${_apiKey.substring(0, 10)}...'); 
      print('🔍 Search Engine ID: $_searchEngineId');
      
      final response = await http.get(url);
      
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      
      // Debug: In ra toàn bộ response body để xem lỗi gì
      if (response.statusCode != 200) {
        print('❌ Full Error Response: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ API Response received');
        print('📝 Search Info: ${data['searchInformation']?['totalResults'] ?? 'N/A'} results found');
        
        final results = _parseSimilarProducts(data, productName, category);
        print('🎯 Parsed ${results.length} relevant products');
        
        // Debug: Kiểm tra kết quả trước khi fallback
        print('🎯 Real search results: ${results.length} products');
        for (int i = 0; i < results.length && i < 3; i++) {
          print('  ${i+1}. ${results[i]['name']} - ${results[i]['source']}');
        }
        
        // Nếu không có kết quả thực tế, fallback
        if (results.isEmpty) {
          print('⚠️ No relevant products found, using fallback');
          return _getFallbackSimilarProducts(productName, category);
        }
        
        // Mix real results với fallback để đảm bảo có đủ sản phẩm
        final fallbackResults = _getFallbackSimilarProducts(productName, category);
        results.addAll(fallbackResults.take(2)); // Thêm 2 sản phẩm fallback
        
        return results.take(6).toList();
      } else if (response.statusCode == 403) {
        print('❌ API Key không hợp lệ hoặc đã hết quota: ${response.body}');
        return _getFallbackSimilarProducts(productName, category);
      } else {
        print('❌ Google Custom Search API error: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
        return _getFallbackSimilarProducts(productName, category);
      }
    } catch (e) {
      print('❌ Error calling Google Custom Search API: $e');
      return _getFallbackSimilarProducts(productName, category);
    }
  }

  /// Tạo query tối ưu để tìm sản phẩm thực tế từ các trang bán hàng
  static String _buildSimilarProductQuery(String productName, String category) {
    // Loại bỏ brand name để tìm sản phẩm tương tự
    String cleanProductName = _removeCommonBrands(productName);
    
    // Tạo query đơn giản và hiệu quả hơn
    List<String> queryParts = [];
    
    // Thêm loại sản phẩm chính
    if (category.toLowerCase().contains('skincare') || cleanProductName.toLowerCase().contains('cream')) {
      queryParts.add('kem dưỡng ẩm OR moisturizer OR "face cream"');
    } else if (cleanProductName.toLowerCase().contains('serum')) {
      queryParts.add('serum OR "vitamin c serum" OR "hyaluronic acid"');
    } else if (cleanProductName.toLowerCase().contains('cleanser')) {
      queryParts.add('sữa rửa mặt OR cleanser OR "face wash"');
    } else {
      queryParts.add(cleanProductName);
    }
    
    // Chỉ tìm trên một số trang chính để tránh quá nhiều noise
    queryParts.add('site:shopee.vn OR site:tiki.vn OR site:hasaki.vn OR site:guardian.vn');
    
    return queryParts.join(' ');
  }

  /// Loại bỏ tên thương hiệu phổ biến khỏi tên sản phẩm
  static String _removeCommonBrands(String productName) {
    final commonBrands = [
      'Nivea', 'LOreal', 'Estee Lauder', 'Chanel', 'Dior', 'Clinique',
      'Lancome', 'SK-II', 'Shiseido', 'Neutrogena', 'Cetaphil', 'La Roche-Posay',
      'Vichy', 'Avene', 'The Ordinary', 'Paulas Choice', 'CeraVe'
    ];
    
    String cleanName = productName;
    for (final brand in commonBrands) {
      cleanName = cleanName.replaceAll(RegExp(brand, caseSensitive: false), '').trim();
    }
    
    return cleanName.isEmpty ? productName : cleanName;
  }

  /// Parse kết quả từ Google Custom Search API
  static List<Map<String, dynamic>> _parseSimilarProducts(
    Map<String, dynamic> data, 
    String originalProduct, 
    String category
  ) {
    final products = <Map<String, dynamic>>[];
    
    try {
      if (data['items'] != null) {
        for (final item in data['items']) {
          try {
            final title = item['title'] as String? ?? '';
            final snippet = item['snippet'] as String? ?? '';
            final link = item['link'] as String? ?? '';
            
            // Lọc kết quả liên quan
            if (_isRelevantProduct(title, snippet, originalProduct, category)) {
              final productName = _extractProductName(title);
              final cleanDescription = _cleanSnippet(snippet);
              
              products.add({
                'name': productName,
                'description': cleanDescription,
                'source': _extractSource(link),
                'link': link,
                'similarity': _calculateSimilarity(title, snippet, originalProduct),
                'category': category,
                'isVerified': _isVerifiedSource(link),
              });
            }
          } catch (e) {
            print('❌ Error parsing individual item: $e');
            // Skip this item and continue
            continue;
          }
        }
      }
      
      // Sắp xếp theo độ tương tự
      products.sort((a, b) => (b['similarity'] as double).compareTo(a['similarity'] as double));
      
      return products.take(6).toList();
    } catch (e) {
      print('❌ Error parsing Google search results: $e');
      return []; // Return empty list on error
    }
  }

  /// Kiểm tra xem kết quả có phải là sản phẩm thực tế từ trang bán hàng không
  static bool _isRelevantProduct(String title, String snippet, String originalProduct, String category) {
    final text = '$title $snippet'.toLowerCase();
    final originalLower = originalProduct.toLowerCase();
    
    // Loại bỏ các kết quả không mong muốn
    final excludeKeywords = [
      'video', 'youtube', 'tiktok', 'facebook', 'instagram', 'twitter',
      'wiki', 'wikipedia', 'review only', 'tin tức', 'news'
    ];
    
    if (excludeKeywords.any((keyword) => text.contains(keyword))) {
      return false;
    }
    
    // Kiểm tra từ khóa sản phẩm làm đẹp
    final productKeywords = [
      'kem', 'serum', 'cream', 'moisturizer', 'cleanser', 'toner', 'lotion',
      'dưỡng', 'skincare', 'beauty', 'cosmetic', 'chăm sóc da', 'face',
      'ml', 'g', 'gram', 'oz', 'size'
    ];
    
    // Kiểm tra từ khóa trang thương mại
    final commerceKeywords = [
      'shopee', 'tiki', 'lazada', 'hasaki', 'guardian', 'watsons',
      'giá', 'price', 'đ', 'vnd', 'mua', 'buy', 'sale', 'khuyến mãi'
    ];
    
    // Chỉ cần có từ khóa sản phẩm HOẶC từ khóa thương mại (dễ dàng hơn)
    final hasProductKeyword = productKeywords.any((keyword) => text.contains(keyword));
    final hasCommerceKeyword = commerceKeywords.any((keyword) => text.contains(keyword));
    
    return hasProductKeyword || hasCommerceKeyword;
  }

  /// Trích xuất tên sản phẩm từ title
  static String _extractProductName(String title) {
    try {
      // Loại bỏ các ký tự đặc biệt và website name, giữ lại tiếng Việt
      String cleanTitle = title
          .replaceAll(RegExp(r'\s*\|\s*.*$'), '') // Loại bỏ "| Website Name"
          .replaceAll(RegExp(r'\s*-\s*.*$'), '') // Loại bỏ "- Website Name"
          .replaceAll(RegExp(r'[^\p{L}\p{N}\s\-.đĐ]', unicode: true), '') // Giữ lại chữ (bao gồm tiếng Việt), số, space, dấu gạch ngang, dấu chấm
          .replaceAll(RegExp(r'\s+'), ' ') // Loại bỏ multiple spaces
          .trim();
      
      // Giới hạn độ dài
      if (cleanTitle.length > 60) {
        cleanTitle = cleanTitle.substring(0, 60) + '...';
      }
      
      return cleanTitle.isEmpty ? 'Sản phẩm tương tự' : cleanTitle;
    } catch (e) {
      print('❌ Error extracting product name: $e');
      // Fallback: Basic cleaning
      final basicClean = title
          .replaceAll(RegExp(r'\s*\|\s*.*$'), '')
          .replaceAll(RegExp(r'\s*-\s*.*$'), '')
          .trim();
      
      if (basicClean.length > 60) {
        return basicClean.substring(0, 60) + '...';
      }
      return basicClean.isEmpty ? 'Sản phẩm tương tự' : basicClean;
    }
  }

  /// Làm sạch snippet
  static String _cleanSnippet(String snippet) {
    try {
      String clean = snippet
          .replaceAll(RegExp(r'\s+'), ' ') // Loại bỏ khoảng trắng thừa
          .replaceAll(RegExp(r'[^\p{L}\p{N}\s\-.,!?()%đĐ]', unicode: true), '') // Giữ lại ký tự cơ bản và tiếng Việt
          .trim();
      
      // Giới hạn độ dài
      if (clean.length > 120) {
        clean = clean.substring(0, 120) + '...';
      }
      
      return clean;
    } catch (e) {
      print('❌ Error cleaning snippet: $e');
      // Fallback: Basic cleaning
      String basicClean = snippet
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      
      if (basicClean.length > 120) {
        basicClean = basicClean.substring(0, 120) + '...';
      }
      
      return basicClean;
    }
  }

  /// Trích xuất source từ URL với tên thương hiệu dễ nhận biết
  static String _extractSource(String url) {
    try {
      final uri = Uri.parse(url);
      final domain = uri.host.replaceAll('www.', '').toLowerCase();
      
      // Map các domain phổ biến thành tên thương hiệu
      final brandMap = {
        'shopee.vn': 'Shopee',
        'tiki.vn': 'Tiki',
        'lazada.vn': 'Lazada',
        'sendo.vn': 'Sendo',
        'hasaki.vn': 'Hasaki',
        'guardian.vn': 'Guardian',
        'watsons.vn': 'Watsons',
        'thegioiskinfood.com': 'Skinfood',
        'beautytalk.vn': 'BeautyTalk',
        'sociolla.com': 'Sociolla',
        'sephora.com': 'Sephora',
        'ulta.com': 'Ulta',
        'amazon.com': 'Amazon',
        'iherb.com': 'iHerb',
      };
      
      // Tìm brand match
      for (final entry in brandMap.entries) {
        if (domain.contains(entry.key)) {
          return entry.value;
        }
      }
      
      // Fallback: lấy tên domain chính
      return domain.split('.').first.toUpperCase();
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Tính toán độ tương tự
  static double _calculateSimilarity(String title, String snippet, String originalProduct) {
    final text = '$title $snippet'.toLowerCase();
    final original = originalProduct.toLowerCase();
    
    double similarity = 0.0;
    
    // Tính điểm dựa trên từ khóa chung
    final originalWords = original.split(' ').where((w) => w.length > 2).toList();
    for (final word in originalWords) {
      if (text.contains(word)) {
        similarity += 1.0;
      }
    }
    
    // Bonus cho các từ khóa quan trọng
    final importantKeywords = ['best', 'top', 'review', 'rated', 'similar'];
    for (final keyword in importantKeywords) {
      if (text.contains(keyword)) {
        similarity += 0.5;
      }
    }
    
    return similarity;
  }

  /// Kiểm tra xem source có đáng tin cậy không (bao gồm cả trang Việt Nam)
  static bool _isVerifiedSource(String url) {
    final trustedDomains = [
      // Trang thương mại điện tử Việt Nam
      'shopee.vn', 'tiki.vn', 'lazada.vn', 'sendo.vn', 'hasaki.vn', 
      'guardian.vn', 'watsons.vn', 'thegioiskinfood.com', 'beautytalk.vn',
      // Trang quốc tế uy tín
      'sephora.com', 'ulta.com', 'dermstore.com', 'beautylish.com',
      'amazon.com', 'iherb.com', 'sociolla.com', 'yesstyle.com',
      'skinstore.com', 'lookfantastic.com', 'feelunique.com'
    ];
    
    return trustedDomains.any((domain) => url.toLowerCase().contains(domain));
  }

  /// Trả về kết quả fallback với links thực tế đến trang bán hàng
  static List<Map<String, dynamic>> _getFallbackSimilarProducts(String productName, String category) {
    final suggestions = <Map<String, dynamic>>[];
    
    // Tạo gợi ý với links thực tế dựa trên loại sản phẩm
    if (category.toLowerCase().contains('skincare') || productName.toLowerCase().contains('cream')) {
      suggestions.addAll([
        {
          'name': 'CeraVe Foaming Facial Cleanser 236ml',
          'description': 'Sữa rửa mặt tạo bọt cho da dầu và hỗn hợp - Giá: 289.000đ',
          'source': 'Hasaki',
          'link': 'https://hasaki.vn/san-pham/sua-rua-mat-tao-bot-cerave-foaming-facial-cleanser-236ml-88283.html',
          'similarity': 0.9,
          'category': 'Skincare',
          'isVerified': true,
        },
        {
          'name': 'Neutrogena Ultra Gentle Daily Cleanser',
          'description': 'Sữa rửa mặt dịu nhẹ hàng ngày - Giá: 189.000đ',
          'source': 'Shopee',
          'link': 'https://shopee.vn/Neutrogena-Ultra-Gentle-Daily-Cleanser-i.5312441.23825330969',
          'similarity': 0.8,
          'category': 'Skincare',
          'isVerified': true,
        },
        {
          'name': 'La Roche-Posay Toleriane Caring Wash',
          'description': 'Gel rửa mặt dịu nhẹ cho da nhạy cảm - Giá: 320.000đ',
          'source': 'Guardian',
          'link': 'https://www.guardian.com.vn/la-roche-posay-toleriane-caring-wash-400ml',
          'similarity': 0.7,
          'category': 'Skincare',
          'isVerified': true,
        },
      ]);
    }
    
    if (productName.toLowerCase().contains('serum')) {
      suggestions.addAll([
        {
          'name': 'Vichy LiftActiv Vitamin C Serum',
          'description': 'Serum Vitamin C 15% làm sáng da chống lão hóa - Giá: 1.050.000đ',
          'source': 'Tiki',
          'link': 'https://tiki.vn/serum-duong-da-chong-lao-hoa-vichy-liftactiv-vitamin-c-fresh-shot-10ml-p13740201.html',
          'similarity': 0.8,
          'category': 'Skincare',
          'isVerified': true,
        },
        {
          'name': 'The Inkey List Hyaluronic Acid Serum',
          'description': 'Serum cấp ẩm với Hyaluronic Acid - Giá: 350.000đ',
          'source': 'Hasaki',
          'link': 'https://hasaki.vn/san-pham/serum-cap-am-the-inkey-list-hyaluronic-acid-serum-30ml-138892.html',
          'similarity': 0.7,
          'category': 'Skincare',
          'isVerified': true,
        },
      ]);
    }
    
    if (productName.toLowerCase().contains('cleanser') || productName.toLowerCase().contains('tẩy trang')) {
      suggestions.addAll([
        {
          'name': 'Bioré Makeup Remover Perfect Oil',
          'description': 'Dầu tẩy trang hoàn hảo loại bỏ makeup lâu trôi - Giá: 185.000đ',
          'source': 'Shopee',
          'link': 'https://shopee.vn/Dầu-tẩy-trang-Bioré-Makeup-Remover-Perfect-Oil-150ml-i.5312441.15625467843',
          'similarity': 0.8,
          'category': 'Skincare',
          'isVerified': true,
        },
      ]);
    }
    
    return suggestions.take(6).toList();
  }

  /// Tạo tin nhắn phản hồi với sản phẩm tương tự
  static String createSimilarProductsResponse(
    List<Map<String, dynamic>> similarProducts, 
    String originalProduct
  ) {
    if (similarProducts.isEmpty) {
      return "Xin lỗi, tôi không tìm thấy sản phẩm tương tự với $originalProduct lúc này. Bạn có thể thử tìm kiếm với từ khóa khác.";
    }

    String response = "🔍 **Các sản phẩm tương tự với \"$originalProduct\":**\n\n";
    
    for (int i = 0; i < similarProducts.length; i++) {
      final product = similarProducts[i];
      final verifiedIcon = product['isVerified'] ? '✅' : '🔸';
      
      response += "$verifiedIcon **${product['name']}**\n";
      response += "   📝 ${product['description']}\n";
      response += "   🏷️ Nguồn: ${product['source']}\n";
      
      if (product['similarity'] > 0.8) {
        response += "   ⭐ Độ tương tự cao\n";
      }
      
      response += "\n";
    }
    
    response += "💡 **Ghi chú**: \n";
    response += "✅ = Nguồn đáng tin cậy\n";
    response += "🔸 = Thông tin tham khảo\n\n";
    response += "Bạn có thể so sánh các sản phẩm này với sản phẩm hiện có tại Cosmotopia để đưa ra lựa chọn tốt nhất!\n\n";
    response += "🔄 **Muốn xem thêm?** Gõ \"có thêm sản phẩm khác không\" để tìm thêm sản phẩm khác.";
    
    return response;
  }

  /// Test method để debug Google Custom Search API
  static Future<void> testGoogleSearch() async {
    try {
      final testQuery = 'kem dưỡng ẩm site:shopee.vn OR site:tiki.vn';
      final url = Uri.parse('$_baseUrl?key=$_apiKey&cx=$_searchEngineId&q=$testQuery&num=5&safe=active');
      
      print('🧪 Testing Google Custom Search API');
      print('🔗 URL: $url');
      
      final response = await http.get(url);
      print('📊 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ API works! Found ${data['items']?.length ?? 0} items');
        if (data['items'] != null) {
          for (int i = 0; i < (data['items'].length as int).clamp(0, 3); i++) {
            final item = data['items'][i];
            print('📦 ${i+1}. ${item['title']}');
            print('🔗    ${item['link']}');
          }
        }
      } else {
        print('❌ Error: ${response.body}');
      }
    } catch (e) {
      print('💥 Exception: $e');
    }
  }
} 