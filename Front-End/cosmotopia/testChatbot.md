# Test Chatbot - User Perspective

## Mục đích
Tài liệu này mô tả các test case từ góc nhìn người dùng cuối khi sử dụng chatbot trong ứng dụng Cosmotopia.

## Điều kiện tiên quyết
- Người dùng đã đăng nhập vào ứng dụng
- Chatbot đã được tích hợp và hoạt động
- Database có sẵn sản phẩm từ các thương hiệu: L'Oréal Paris, Estée Lauder, MAC Cosmetics, Chanel, Nivea

---

## Test Case 1: Chào hỏi cơ bản
**Mô tả**: Người dùng mở chatbot lần đầu tiên
**Input**: "Xin chào"
**Kết quả mong đợi**: 
- Bot chào lại một cách thân thiện
- Giới thiệu chức năng tư vấn sản phẩm làm đẹp
- Đưa ra gợi ý câu hỏi

---

## Test Case 2: Tìm sản phẩm theo thương hiệu
**Mô tả**: Người dùng muốn tìm sản phẩm của thương hiệu cụ thể
**Input**: "Tôi muốn tìm sản phẩm của L'Oréal"
**Kết quả mong đợi**:
- Hiển thị danh sách sản phẩm L'Oréal Paris
- Kèm theo mô tả ngắn gọn về từng sản phẩm
- Hiển thị giá và hình ảnh

---

## Test Case 3: Tư vấn theo loại da
**Mô tả**: Người dùng tư vấn sản phẩm cho loại da cụ thể
**Input**: "Da tôi khô, bạn có thể tư vấn sản phẩm dưỡng ẩm không?"
**Kết quả mong đợi**:
- Bot hiểu được loại da khô
- Gợi ý sản phẩm dưỡng ẩm phù hợp
- Giải thích tại sao sản phẩm phù hợp với da khô

---

## Test Case 4: Tìm sản phẩm theo giá
**Mô tả**: Người dùng tìm sản phẩm trong tầm giá
**Input**: "Tôi muốn tìm kem dưỡng dưới 500k"
**Kết quả mong đợi**:
- Hiển thị sản phẩm kem dưỡng có giá < 500,000 VND
- Sắp xếp theo giá từ thấp đến cao
- Gợi ý sản phẩm chất lượng tốt trong tầm giá

---

## Test Case 5: Tư vấn theo mục đích sử dụng
**Mô tả**: Người dùng muốn sản phẩm cho mục đích cụ thể
**Input**: "Tôi cần son môi cho buổi tối đi dự tiệc"
**Kết quả mong đợi**:
- Gợi ý son môi có độ bền cao, màu sắc phù hợp buổi tối
- Có thể gợi ý màu đỏ hoặc màu tối
- Giải thích cách sử dụng để son lâu trôi

---

## Test Case 6: So sánh sản phẩm
**Mô tả**: Người dùng muốn so sánh giữa các sản phẩm
**Input**: "So sánh kem dưỡng ẩm của Nivea và L'Oréal"
**Kết quả mong đợi**:
- Hiển thị bảng so sánh 2 sản phẩm
- So sánh giá, thành phần, công dụng
- Đưa ra gợi ý phù hợp với từng loại da

---

## Test Case 7: Tìm sản phẩm cho người khác
**Mô tả**: Người dùng mua quà cho người khác
**Input**: "Tôi muốn mua nước hoa làm quà cho bạn gái"
**Kết quả mong đợi**:
- Gợi ý các loại nước hoa phổ biến cho nữ
- Hỏi thêm thông tin về sở thích của người nhận
- Gợi ý các mùi hương nhẹ nhàng, dễ chịu

---

## Test Case 8: Tư vấn routine làm đẹp
**Mô tả**: Người dùng muốn tư vấn quy trình chăm sóc
**Input**: "Bạn có thể tư vấn quy trình chăm sóc da ban đêm không?"
**Kết quả mong đợi**:
- Mô tả các bước chăm sóc da ban đêm
- Gợi ý sản phẩm cho từng bước
- Giải thích thứ tự sử dụng

---

## Test Case 9: Xử lý từ khóa không rõ ràng
**Mô tả**: Người dùng nhập từ khóa mơ hồ
**Input**: "Tôi muốn đẹp hơn"
**Kết quả mong đợi**:
- Bot hỏi thêm thông tin cụ thể
- Gợi ý các danh mục: skincare, makeup, haircare
- Hướng dẫn người dùng mô tả nhu cầu rõ hơn

---

## Test Case 10: Tìm sản phẩm hết hàng
**Mô tả**: Người dùng tìm sản phẩm không còn trong kho
**Input**: "Tôi muốn mua [tên sản phẩm hết hàng]"
**Kết quả mong đợi**:
- Thông báo sản phẩm tạm hết hàng
- Gợi ý sản phẩm tương tự
- Đề xuất đăng ký thông báo khi có hàng

---

## Test Case 11: Thông tin về thương hiệu
**Mô tả**: Người dùng muốn biết thông tin về thương hiệu
**Input**: "Kể cho tôi biết về thương hiệu Chanel"
**Kết quả mong đợi**:
- Giới thiệu về thương hiệu Chanel
- Nêu đặc điểm nổi bật của sản phẩm
- Hiển thị một số sản phẩm Chanel có sẵn

---

## Test Case 12: Tư vấn theo xu hướng
**Mô tả**: Người dùng quan tâm đến xu hướng làm đẹp
**Input**: "Xu hướng makeup năm nay là gì?"
**Kết quả mong đợi**:
- Mô tả các xu hướng makeup hiện tại
- Gợi ý sản phẩm phù hợp với xu hướng
- Hướng dẫn cách tạo look theo xu hướng

---

## Test Case 13: Xử lý lỗi chính tả
**Mô tả**: Người dùng gõ sai chính tả
**Input**: "Tôi cần kêm dưỡn ẩm" (thay vì "kem dưỡng ẩm")
**Kết quả mong đợi**:
- Bot hiểu được ý định dù có lỗi chính tả
- Tự động sửa và xác nhận với người dùng
- Gợi ý sản phẩm kem dưỡng ẩm

---

## Test Case 14: Hỏi về cách sử dụng
**Mô tả**: Người dùng muốn biết cách sử dụng sản phẩm
**Input**: "Cách sử dụng serum vitamin C như thế nào?"
**Kết quả mong đợi**:
- Hướng dẫn chi tiết cách sử dụng serum vitamin C
- Lưu ý về thời gian sử dụng
- Gợi ý sản phẩm serum vitamin C có sẵn

---

## Test Case 15: Tư vấn cho vấn đề da cụ thể
**Mô tả**: Người dùng có vấn đề da cụ thể
**Input**: "Da tôi hay bị mụn, bạn có thể tư vấn không?"
**Kết quả mong đợi**:
- Hiểu được vấn đề về mụn
- Gợi ý sản phẩm trị mụn
- Tư vấn routine chăm sóc da mụn
- Lưu ý về việc test sản phẩm trước khi dùng

---

## Test Case 16: Xử lý yêu cầu ngoài phạm vi
**Mô tả**: Người dùng hỏi về chủ đề không liên quan
**Input**: "Thời tiết hôm nay thế nào?"
**Kết quả mong đợi**:
- Lịch sự từ chối và giải thích chỉ tư vấn về làm đẹp
- Chuyển hướng về chủ đề sản phẩm làm đẹp
- Gợi ý các câu hỏi mà bot có thể trả lời

---

## Test Case 17: Tìm sản phẩm organic/tự nhiên
**Mô tả**: Người dùng quan tâm đến sản phẩm tự nhiên
**Input**: "Tôi muốn tìm sản phẩm làm đẹp từ thiên nhiên"
**Kết quả mong đợi**:
- Giải thích về sản phẩm organic/tự nhiên
- Gợi ý sản phẩm có thành phần tự nhiên
- Lưu ý về lợi ích của sản phẩm tự nhiên

---

## Test Case 18: Tư vấn theo độ tuổi
**Mô tả**: Người dùng tìm sản phẩm phù hợp độ tuổi
**Input**: "Ở tuổi 30, tôi nên dùng sản phẩm chống lão hóa nào?"
**Kết quả mong đợi**:
- Hiểu được độ tuổi và nhu cầu chống lão hóa
- Gợi ý sản phẩm phù hợp với tuổi 30
- Tư vấn routine chống lão hóa

---

## Test Case 19: Hỏi về promotion/giảm giá
**Mô tả**: Người dùng quan tâm đến ưu đãi
**Input**: "Có sản phẩm nào đang giảm giá không?"
**Kết quả mong đợi**:
- Thông báo về các sản phẩm đang có ưu đãi (nếu có)
- Gợi ý sản phẩm tốt với giá hợp lý
- Hướng dẫn cách theo dõi promotion

---

## Test Case 20: Feedback và đánh giá
**Mô tả**: Người dùng muốn biết đánh giá về sản phẩm
**Input**: "Sản phẩm này có tốt không? Người ta đánh giá thế nào?"
**Kết quả mong đợi**:
- Cung cấp thông tin đánh giá khách quan
- Nêu ưu nhược điểm của sản phẩm
- Gợi ý sản phẩm thay thế nếu cần

---

## Tiêu chí đánh giá chung

### Về độ chính xác:
- Bot hiểu đúng ý định người dùng ≥ 90%
- Gợi ý sản phẩm phù hợp với yêu cầu
- Thông tin sản phẩm chính xác (giá, mô tả, hình ảnh)

### Về trải nghiệm người dùng:
- Thời gian phản hồi < 3 giây
- Ngôn ngữ tự nhiên, thân thiện
- Giao diện chatbot dễ sử dụng
- Hiển thị sản phẩm trực quan

### Về tính năng:
- Lưu lịch sử chat theo session
- Hỗ trợ nhiều loại câu hỏi khác nhau
- Xử lý lỗi chính tả cơ bản
- Từ chối lịch sự các yêu cầu ngoài phạm vi 