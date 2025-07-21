import 'package:http/http.dart' as http;

class GoogleSearchService {
  // Bạn có thể sử dụng API key miễn phí từ Google Custom Search
  // Hoặc sử dụng web scraping đơn giản (không cần API key)
  static const String _userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

  /// Tìm kiếm sản phẩm skincare trên Google
  static Future<List<Map<String, String>>> searchSkincareProducts(String query) async {
    try {
      // Tạo query tìm kiếm tối ưu
      final searchQuery = '$query skincare products reviews best';
      final encodedQuery = Uri.encodeComponent(searchQuery);
      
      // Sử dụng Google Search với region=vn để có kết quả phù hợp với Việt Nam
      final url = 'https://www.google.com/search?q=$encodedQuery&gl=vn&hl=vi&num=10';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'vi-VN,vi;q=0.8,en-US;q=0.5,en;q=0.3',
          'Accept-Encoding': 'gzip, deflate',
          'Connection': 'keep-alive',
        },
      );

      if (response.statusCode == 200) {
        return _parseSearchResults(response.body, query);
      } else {
        print('Google search failed with status: ${response.statusCode}');
        return _getFallbackResults(query);
      }
    } catch (e) {
      print('Error searching Google: $e');
      return _getFallbackResults(query);
    }
  }

  /// Parse kết quả tìm kiếm từ HTML của Google
  static List<Map<String, String>> _parseSearchResults(String html, String originalQuery) {
    final results = <Map<String, String>>[];
    
    try {
      // Tìm các link và title từ kết quả Google Search
      // Đây là cách đơn giản, trong thực tế có thể sử dụng HTML parser chuyên nghiệp
      final titleRegex = RegExp(r'<h3[^>]*>([^<]+)</h3>', multiLine: true);
      final linkRegex = RegExp(r'href="([^"]+)"', multiLine: true);
      
      final titleMatches = titleRegex.allMatches(html);
      final linkMatches = linkRegex.allMatches(html);
      
      int count = 0;
      for (final titleMatch in titleMatches) {
        if (count >= 5) break; // Giới hạn 5 kết quả
        
        final title = titleMatch.group(1)?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '';
        if (title.isNotEmpty && _isRelevantTitle(title, originalQuery)) {
          results.add({
            'title': title,
            'description': 'Tìm hiểu thêm về $title và các sản phẩm skincare tương tự',
            'source': 'Google Search',
          });
          count++;
        }
      }
    } catch (e) {
      print('Error parsing search results: $e');
    }
    
    if (results.isEmpty) {
      return _getFallbackResults(originalQuery);
    }
    
    return results;
  }

  /// Kiểm tra xem title có liên quan đến skincare không
  static bool _isRelevantTitle(String title, String query) {
    final lowerTitle = title.toLowerCase();
    final lowerQuery = query.toLowerCase();
    
    // Loại bỏ các kết quả không mong muốn
    final excludeKeywords = ['video', 'youtube', 'tiktok', 'facebook', 'instagram', 'ads', 'quảng cáo'];
    if (excludeKeywords.any((keyword) => lowerTitle.contains(keyword))) {
      return false;
    }
    
    // Kiểm tra từ khóa liên quan đến skincare
    final skincareKeywords = [
      'skincare', 'kem', 'serum', 'toner', 'moisturizer', 'cleanser', 'chăm sóc da',
      'dưỡng da', 'làm đẹp', 'mỹ phẩm', 'beauty', 'cosmetics', 'skin care'
    ];
    
    return skincareKeywords.any((keyword) => lowerTitle.contains(keyword)) ||
           lowerQuery.split(' ').any((word) => word.length > 2 && lowerTitle.contains(word));
  }

  /// Trả về kết quả mặc định khi không thể tìm kiếm
  static List<Map<String, String>> _getFallbackResults(String query) {
    return [
      {
        'title': 'Tìm hiểu thêm về $query',
        'description': 'Khám phá các sản phẩm $query phổ biến và được đánh giá cao từ các thương hiệu uy tín',
        'source': 'Gợi ý từ Cosmotopia',
      },
      {
        'title': 'So sánh các sản phẩm $query',
        'description': 'Đọc review và so sánh các sản phẩm $query để chọn được sản phẩm phù hợp nhất',
        'source': 'Gợi ý từ Cosmotopia',
      },
      {
        'title': 'Hướng dẫn sử dụng $query',
        'description': 'Tìm hiểu cách sử dụng $query đúng cách để đạt hiệu quả tốt nhất cho làn da',
        'source': 'Gợi ý từ Cosmotopia',
      },
    ];
  }

  /// Tạo tin nhắn phản hồi với kết quả tìm kiếm Google
  static String createSearchResponse(List<Map<String, String>> searchResults, String originalQuery) {
    if (searchResults.isEmpty) {
      return "Xin lỗi, tôi không thể tìm thêm thông tin về $originalQuery lúc này. Bạn có thể thử tìm kiếm trực tiếp trên Google hoặc liên hệ với chúng tôi để được tư vấn.";
    }

    String response = "Dựa trên tìm kiếm trên Google, đây là thêm thông tin về $originalQuery:\n\n";
    
    for (int i = 0; i < searchResults.length; i++) {
      final result = searchResults[i];
      response += "${i + 1}. **${result['title']}**\n";
      response += "   ${result['description']}\n";
      response += "   _Nguồn: ${result['source']}_\n\n";
    }
    
    response += "💡 **Lưu ý**: Thông tin trên được tổng hợp từ internet. Bạn nên tham khảo ý kiến chuyên gia và đọc kỹ thành phần trước khi sử dụng sản phẩm mới.\n\n";
    response += "Nếu bạn muốn mua sản phẩm, hãy quay lại xem các sản phẩm có sẵn tại Cosmotopia nhé!";
    
    return response;
  }

  /// Nhận diện yêu cầu tìm kiếm thêm thông tin
  static bool isSearchMoreRequest(String message) {
    final lowerMessage = message.toLowerCase();
    final searchKeywords = [
      'thêm', 'nữa', 'khác', 'tìm kiếm', 'search', 'google', 'tìm hiểu',
      'thông tin', 'chi tiết', 'more', 'additional', 'other', 'another',
      'còn gì', 'gì khác', 'tìm thêm', 'cho tôi thêm', 'muốn biết thêm',
      'các sản phẩm khác', 'sản phẩm khác', 'option khác', 'lựa chọn khác',
      'có gì khác', 'còn có gì', 'có thêm gì', 'show thêm'
    ];
    
    return searchKeywords.any((keyword) => lowerMessage.contains(keyword));
  }
} 