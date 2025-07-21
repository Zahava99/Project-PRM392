# Data Refresh Guide

## Hướng dẫn sử dụng cơ chế refresh dữ liệu

### Mô tả vấn đề
Trước đây, khi cập nhật sản phẩm trong product management, dữ liệu trong bottom_page không được cập nhật tự động. Người dùng phải logout và login lại để thấy thay đổi.

### Giải pháp
Đã implement các cơ chế sau:

1. **Automatic Refresh Triggers**
2. **Manual Refresh với Pull-to-Refresh**
3. **Lifecycle-based Refresh**
4. **State Management Refresh**

---

## Cách sử dụng

### 1. Từ Product Management Page
Sau khi cập nhật sản phẩm thành công, thêm code sau:

```dart
import '/home/bottom_page/bottom_page_subfile/bottom_page_helpers.dart';

// Sau khi cập nhật sản phẩm thành công
await updateProduct(productData);

// Trigger refresh cho bottom_page
BottomPageHelpers.triggerProductRefresh();

// Hoặc refresh toàn bộ data
BottomPageHelpers.triggerDataRefresh();
```

### 2. Từ Category Management Page
```dart
// Sau khi cập nhật category
await updateCategory(categoryData);

// Trigger refresh
BottomPageHelpers.triggerCategoryRefresh();
```

### 3. Sử dụng Pull-to-Refresh
Người dùng có thể vuốt xuống trên Home tab, Order tab, hoặc Favorite tab để refresh dữ liệu thủ công.

### 4. Automatic Refresh
- Khi app được focus lại từ background
- Khi chuyển đổi giữa các tab
- Khi có thay đổi trong FFAppState

---

## API Methods

### BottomPageHelpers
```dart
// Refresh toàn bộ dữ liệu (products, categories, orders, favorites, user)
BottomPageHelpers.triggerDataRefresh();

// Refresh chỉ products và favorites
BottomPageHelpers.triggerProductRefresh();

// Refresh categories và toàn bộ data
BottomPageHelpers.triggerCategoryRefresh();
```

### FFAppState Methods
```dart
// Trigger refresh flags
FFAppState().triggerDataRefresh();
FFAppState().triggerProductRefresh();

// Clear refresh flags (tự động được gọi sau khi refresh)
FFAppState().clearDataRefreshFlag();
FFAppState().clearProductRefreshFlag();

// Check refresh flags
bool needsRefresh = FFAppState().needsDataRefresh;
bool needsProductRefresh = FFAppState().needsProductRefresh;
```

---

## Ví dụ thực tế

### Product Management Page
```dart
// Trong product_management_page.dart
class _ProductManagementPageState extends State<ProductManagementPage> {
  
  Future<void> updateProductData(ProductStruct product) async {
    try {
      // Cập nhật sản phẩm
      final response = await ApiService.updateProduct(product);
      
      if (response.statusCode == 200) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật sản phẩm thành công!')),
        );
        
        // Trigger refresh cho bottom_page
        BottomPageHelpers.triggerProductRefresh();
        
        // Navigate back hoặc refresh current page
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating product: $e');
    }
  }
}
```

### Admin Dashboard
```dart
// Sau khi thêm/sửa/xóa sản phẩm từ admin panel
Future<void> onProductAction() async {
  // Thực hiện action
  await performProductAction();
  
  // Refresh data cho tất cả users
  BottomPageHelpers.triggerDataRefresh();
}
```

---

## Notes
- Refresh sẽ được throttle để tránh spam (tối đa 1 lần mỗi 30 giây cho lifecycle refresh)
- Pull-to-refresh hoạt động độc lập và không bị throttle
- Các refresh flag sẽ tự động được clear sau khi refresh hoàn thành
- Debug logs được in ra để tracking việc refresh 