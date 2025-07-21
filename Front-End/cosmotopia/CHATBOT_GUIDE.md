# Hướng dẫn sử dụng Chatbot Cosmotopia

## Tổng quan
Chatbot Cosmotopia AI là trợ lý thông minh giúp bạn tìm hiểu và lựa chọn sản phẩm làm đẹp phù hợp. Chatbot có khả năng:

1. **Hiểu và phân tích nhu cầu**: Nhận diện loại da, mục đích sử dụng từ câu hỏi của bạn
2. **Gợi ý sản phẩm**: Hiển thị danh sách sản phẩm phù hợp từ cơ sở dữ liệu Cosmotopia
3. **Tìm kiếm mở rộng**: Tìm thêm thông tin trên Google khi được yêu cầu
4. **Tìm sản phẩm tương tự**: Sử dụng Google Custom Search API để tìm sản phẩm thay thế
5. **Trả lời đa dạng**: Xử lý cả câu hỏi về sản phẩm và các câu hỏi chung khác

## Các tính năng chính

### 1. Tư vấn sản phẩm thông minh
- **Nhận diện từ khóa**: Tự động phát hiện khi bạn hỏi về sản phẩm
- **Phân loại chính xác**: Phân biệt skincare, makeup, haircare, nước hoa
- **Lọc theo tiêu chí**: Xem xét loại da và mục đích sử dụng

### 2. Hiển thị sản phẩm trực quan
- Danh sách sản phẩm dạng horizontal scroll
- Hình ảnh, tên, giá, thông tin thương hiệu
- Nhấn để xem chi tiết và mua hàng

### 3. Tìm kiếm mở rộng với Google Search
- Tìm thêm thông tin khi được yêu cầu
- Kết quả từ các nguồn uy tín
- Lọc nội dung phù hợp với beauty/skincare

### 4. 🆕 Tìm sản phẩm tương tự với Google Custom Search
- Tìm sản phẩm thay thế từ các thương hiệu khác
- Đánh giá độ tương tự và độ tin cậy nguồn
- Hiển thị thông tin chi tiết với link đến nguồn gốc
- Phân loại nguồn đáng tin cậy vs thông tin tham khảo

## Cách sử dụng

### Hỏi về sản phẩm
```
Ví dụ câu hỏi:
- "Giới thiệu các sản phẩm về skincare"
- "Tôi có da khô, cần kem dưỡng ẩm"
- "Sản phẩm chống lão hóa cho da nhạy cảm"
- "Serum tốt cho da dầu"
```

### Tìm thêm thông tin
Sau khi xem sản phẩm, bạn có thể hỏi:
```
- "cho tôi thêm thông tin"
- "tìm hiểu thêm"
- "search thêm"
```

### 🆕 Tìm sản phẩm tương tự
Sau khi xem danh sách sản phẩm, bạn có thể hỏi:
```
- "tìm sản phẩm tương tự"
- "có sản phẩm thay thế nào không"
- "sản phẩm giống như vậy"
- "alternative products"
```

## Từ khóa được hỗ trợ

### Loại sản phẩm
- **Skincare**: kem, serum, toner, cleanser, moisturizer, dưỡng ẩm
- **Makeup**: son, phấn, mascara, foundation, trang điểm
- **Haircare**: gội, xả, dưỡng tóc, shampoo, conditioner
- **Fragrance**: nước hoa, perfume

### Loại da
- Da khô, da dầu, da hỗn hợp, da nhạy cảm, da thường

### Mục đích
- Chống lão hóa, dưỡng ẩm, làm trắng, chống nắng, trị mụn, làm sạch

### 🆕 Yêu cầu sản phẩm tương tự
- tương tự, giống, thay thế, alternative, similar, comparable

## Workflow sử dụng hoàn chỉnh

1. **Hỏi về sản phẩm** → Hiển thị sản phẩm từ DB + gợi ý
2. **"cho tôi thêm thông tin"** → Tìm kiếm thông tin trên Google
3. **"tìm sản phẩm tương tự"** → Hiển thị sản phẩm thay thế từ Google Custom Search

## 🆕 Tính năng Google Custom Search

### Cấu hình API
Để sử dụng Google Custom Search, cần thiết lập:

1. **Tạo API Key**: 
   - Truy cập [Google Cloud Console](https://console.cloud.google.com/)
   - Tạo project mới hoặc chọn project hiện có
   - Enable Custom Search JSON API
   - Tạo API key trong Credentials

2. **Tạo Custom Search Engine**:
   - Truy cập [Programmable Search Engine](https://programmablesearchengine.google.com/)
   - Tạo search engine mới
   - Cấu hình để tìm kiếm toàn web hoặc các site cụ thể
   - Lấy Search Engine ID

3. **Cập nhật code**:
   ```dart
   // Trong google_custom_search_service.dart
   static const String _apiKey = 'YOUR_ACTUAL_API_KEY';
   static const String _searchEngineId = 'YOUR_SEARCH_ENGINE_ID';
   ```

### Các nguồn đáng tin cậy
- ✅ Sephora, Ulta, Dermstore, Beautylish
- ✅ Allure, Byrdie, Harper's Bazaar, Elle
- 🔸 Các nguồn khác (thông tin tham khảo)

### Query Optimization
Hệ thống tự động:
- Loại bỏ tên thương hiệu để tìm sản phẩm từ brand khác
- Thêm từ khóa chất lượng: "review", "best", "top rated"
- Loại trừ các site không mong muốn: YouTube, TikTok, social media
- Tính toán độ tương tự và sắp xếp kết quả

## Lưu ý kỹ thuật

### Dependencies mới
```yaml
dependencies:
  http: ^1.2.2          # Cho API calls
  url_launcher: ^6.3.1  # Cho việc mở link external
```

### API Limitations
- **Google Custom Search**: 100 queries/day (free tier)
- **Rate limiting**: Tối đa 10 queries/minute
- **Fallback**: Sử dụng kết quả dự phòng khi API không khả dụng

### Performance Optimization
- Cache kết quả tìm kiếm
- Limit số lượng kết quả (6 products)
- Async processing để không block UI
- Graceful degradation khi API fail

## Troubleshooting

### Google Custom Search không hoạt động
```
❌ API Key không hợp lệ hoặc đã hết quota
```
**Giải pháp**:
1. Kiểm tra API key có đúng và còn quota
2. Đảm bảo Custom Search JSON API đã được enable
3. Xem log để debug error cụ thể

### Kết quả không chính xác
**Cải thiện**:
1. Điều chỉnh query building logic
2. Thêm/sửa trusted domains list
3. Cải thiện similarity calculation
4. Filter relevance tốt hơn

### UI/UX Issues
**Xử lý**:
1. Kiểm tra import url_launcher
2. Test external link opening
3. Responsive design cho different screen sizes
4. Loading states và error handling

## File Structure mới

```
lib/
├── backend/services/
│   ├── chatbot_service.dart          # Core chatbot logic + enhanced
│   ├── google_search_service.dart    # Basic Google search
│   └── google_custom_search_service.dart  # 🆕 Similar products search
├── all_component/
│   ├── chat_product_list/           # Database products display
│   └── similar_products_list/       # 🆕 Google search results display
└── chat/chat_page/                  # Main chat interface
```

Chatbot giờ đây có thể giúp bạn tìm cả sản phẩm từ Cosmotopia lẫn sản phẩm tương tự từ toàn thế giới! 