using Cosmetics.DTO.Chatbot;
using Cosmetics.Interfaces;
using Cosmetics.Models;
using Microsoft.Extensions.Caching.Memory;
using System.Globalization;
using System.Text.RegularExpressions;

namespace Cosmetics.Service.Chatbot
{
    public interface IChatbotService
    {
        Task<ChatbotResponseDto> ProcessMessage(ChatbotRequestDto request);
        Task<ChatbotResponseDto> ProcessMessageWithHistory(ChatbotRequestDto request);
        Task<List<Cosmetics.Models.Product>> GetRelevantProducts(string message);
        void ResetContext(string sessionId);
    }

    public class ChatbotService : IChatbotService
    {
        private readonly IProductRepository _productRepository;
        private readonly IProductService _productService;
        private readonly IMemoryCache _cache;
        private readonly ILogger<ChatbotService> _logger;
        private readonly IChatService _chatService;

        // Từ khóa để nhận diện câu hỏi về sản phẩm
        private readonly List<string> _productKeywords = new List<string>
        {
            "sản phẩm", "mỹ phẩm", "kem", "serum", "tẩy trang", "rửa mặt",
            "dưỡng ẩm", "chống nắng", "trang điểm", "son", "phấn", "mascara",
            "giới thiệu", "gợi ý", "khuyến nghị", "tư vấn", "mua", "bán",
            "tốt", "hiệu quả", "phù hợp", "da", "tóc", "môi", "mắt",
            "chống lão hóa", "trắng da", "dưỡng da", "làm sạch", "tẩy tế bào chết",
            "dưỡng ẩm", "se khít lỗ chân lông", "giảm mụn", "làm mờ vết thâm",
            "chống nắng", "dưỡng tóc", "gội đầu", "xả tóc", "dưỡng môi",
            "dưỡng mắt", "che khuyết điểm", "nền", "phấn phủ", "phấn má hồng",
            "kẻ mắt", "kẻ môi", "đánh phấn", "tạo kiểu tóc", "nhuộm tóc",
            "uốn tóc", "duỗi tóc", "cắt tóc", "làm móng", "sơn móng",
            "dưỡng móng", "tẩy da chết", "kem nền", "moisturizer", "cleanser"
        };

        // Từ khóa để nhận diện các loại câu hỏi khác nhau
        private readonly Dictionary<string, List<string>> _questionTypeKeywords = new Dictionary<string, List<string>>
        {
            { "price", new List<string> { "giá", "bao nhiêu tiền", "giá cả", "chi phí", "price", "cost", "đắt", "rẻ", "tiền" } },
            { "brand", new List<string> { "thương hiệu", "hãng", "brand", "nhãn hiệu", "của hãng nào" } },
            { "comparison", new List<string> { "so sánh", "khác nhau", "giống nhau", "tốt hơn", "compare", "vs", "khác gì" } },
            { "usage", new List<string> { "cách dùng", "sử dụng", "how to use", "dùng như thế nào", "thoa", "apply" } },
            { "benefits", new List<string> { "công dụng", "tác dụng", "benefits", "hiệu quả", "lợi ích", "có tác dụng gì" } },
            { "ingredients", new List<string> { "thành phần", "ingredients", "chứa gì", "có chứa" } },
            { "suitability", new List<string> { "phù hợp", "suitable", "cho da", "dành cho", "ai nên dùng" } }
        };

        // Từ khóa để nhận diện loại da
        private readonly Dictionary<string, List<string>> _skinTypeKeywords = new Dictionary<string, List<string>>
        {
            { "da khô", new List<string> { "da khô", "khô", "bong tróc", "nứt nẻ", "thiếu ẩm" } },
            { "da dầu", new List<string> { "da dầu", "dầu", "bóng nhờn", "mụn", "lỗ chân lông to" } },
            { "da hỗn hợp", new List<string> { "da hỗn hợp", "hỗn hợp", "vừa khô vừa dầu", "t-zone" } },
            { "da nhạy cảm", new List<string> { "da nhạy cảm", "nhạy cảm", "dị ứng", "đỏ", "ngứa" } },
            { "da thường", new List<string> { "da thường", "bình thường", "cân bằng" } }
        };

        // Từ khóa để nhận diện mục đích sử dụng
        private readonly Dictionary<string, List<string>> _purposeKeywords = new Dictionary<string, List<string>>
        {
            { "chống lão hóa", new List<string> { "chống lão hóa", "trẻ hóa", "nếp nhăn", "lão hóa" } },
            { "dưỡng ẩm", new List<string> { "dưỡng ẩm", "cấp ẩm", "giữ ẩm", "khô" } },
            { "làm trắng", new List<string> { "làm trắng", "trắng da", "sáng da", "đều màu" } },
            { "chống nắng", new List<string> { "chống nắng", "bảo vệ", "uv", "tia cực tím" } },
            { "trị mụn", new List<string> { "trị mụn", "giảm mụn", "kháng khuẩn", "se khít lỗ chân lông" } },
            { "làm sạch", new List<string> { "làm sạch", "tẩy trang", "rửa mặt", "tẩy tế bào chết" } }
        };

        public ChatbotService(IProductRepository productRepository, IProductService productService, IMemoryCache cache, ILogger<ChatbotService> logger, IChatService chatService)
        {
            _productRepository = productRepository;
            _productService = productService;
            _cache = cache;
            _logger = logger;
            _chatService = chatService;
        }

        public async Task<ChatbotResponseDto> ProcessMessage(ChatbotRequestDto request)
        {
            try
            {
                var sessionId = request.SessionId ?? Guid.NewGuid().ToString();
                var context = GetSessionContext(sessionId);

                // Xử lý các tình huống đặc biệt trước
                var specialResponse = HandleSpecialCases(request.Message);
                if (specialResponse != null)
                {
                    return new ChatbotResponseDto
                    {
                        Message = specialResponse,
                        Products = new List<Cosmetics.Models.Product>(),
                        HasProducts = false,
                        Context = sessionId
                    };
                }

                // Kiểm tra xem có phải yêu cầu tìm kiếm thêm không
                if (IsSearchMoreRequest(request.Message) && !string.IsNullOrEmpty(context.LastProductQuery))
                {
                    return await HandleSearchMoreRequest(request.Message, context.LastProductQuery, sessionId);
                }

                // Kiểm tra yêu cầu tìm sản phẩm tương tự
                if (IsSimilarProductRequest(request.Message) && context.LastProductResults?.Any() == true)
                {
                    return await FindSimilarProducts(context.LastProductResults.First().Name, sessionId);
                }

                // Kiểm tra yêu cầu tìm thêm sản phẩm khác
                if (IsSearchAnotherMoreRequest(request.Message) && context.LastSimilarProducts?.Any() == true)
                {
                    return await FindMoreSimilarProducts(request.Message, sessionId);
                }

                if (IsProductRelated(request.Message))
                {
                    var products = await GetRelevantProducts(request.Message);
                    
                    // Phân tích loại câu hỏi và tạo response phù hợp
                    var questionType = DetectQuestionType(request.Message);
                    var response = CreateSpecializedResponse(products, questionType, request.Message);

                    // Lưu context
                    context.LastProductQuery = request.Message;
                    context.LastProductResults = products;
                    context.LastQueryTime = DateTime.UtcNow;
                    SaveSessionContext(sessionId, context);

                    return new ChatbotResponseDto
                    {
                        Message = response,
                        Products = products,
                        HasProducts = products.Any(),
                        Context = sessionId
                    };
                }
                else
                {
                    // Nếu không liên quan đến sản phẩm, chuyển đến AI chatbot
                    return new ChatbotResponseDto
                    {
                        Message = "Tôi sẽ chuyển câu hỏi này đến hệ thống AI để có câu trả lời tốt nhất.",
                        Products = new List<Cosmetics.Models.Product>(),
                        HasProducts = false,
                        ShouldSendToAPI = true,
                        Context = sessionId
                    };
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing chatbot message: {Message}", request.Message);
                return new ChatbotResponseDto
                {
                    Success = false,
                    ErrorMessage = "Có lỗi xảy ra. Vui lòng thử lại.",
                    Message = "Xin lỗi, tôi không thể xử lý yêu cầu này lúc này.",
                    Products = new List<Cosmetics.Models.Product>(),
                    HasProducts = false
                };
            }
        }

        public async Task<ChatbotResponseDto> ProcessMessageWithHistory(ChatbotRequestDto request)
        {
            try
            {
                _logger.LogInformation("🚀 ProcessMessageWithHistory called - UserId: {UserId}, SessionId: {SessionId}, Message: {Message}", 
                    request.UserId, request.SessionId, request.Message);

                // Validate request
                if (request.UserId == null || string.IsNullOrEmpty(request.SessionId))
                {
                    _logger.LogError("❌ Invalid request: UserId={UserId}, SessionId={SessionId}", request.UserId, request.SessionId);
                    throw new ArgumentException("UserId and SessionId are required for chat history");
                }

                // Parse SessionId as Guid
                if (!Guid.TryParse(request.SessionId, out var sessionId))
                {
                    _logger.LogError("❌ Invalid SessionId format: {SessionId}", request.SessionId);
                    throw new ArgumentException("Invalid SessionId format");
                }

                // 1. Save user message to database
                var currentTime = DateTime.UtcNow;
                _logger.LogInformation("💾 Saving user message to database at UTC: {UtcTime}, Local: {LocalTime}", 
                    currentTime.ToString("yyyy-MM-dd HH:mm:ss.fff"), 
                    currentTime.ToLocalTime().ToString("yyyy-MM-dd HH:mm:ss.fff"));
                    
                var userMessageRequest = new SaveMessageRequestDto
                {
                    SessionId = sessionId,
                    Content = request.Message,
                    IsFromUser = true,
                    RecommendedProductIds = null
                };

                var savedUserMessage = await _chatService.SaveMessageAsync(userMessageRequest);
                _logger.LogInformation("✅ User message saved with ID: {MessageId}, SentAt: {SentAt}", 
                    savedUserMessage.MessageId, savedUserMessage.SentAt.ToString("yyyy-MM-dd HH:mm:ss.fff"));

                // 2. Process message to get bot response
                _logger.LogInformation("🤖 Processing message through chatbot logic...");
                var botResponse = await ProcessMessage(request);

                // 3. Save bot response to database if processing was successful
                if (botResponse.Success)
                {
                    _logger.LogInformation("💾 Saving bot response to database...");
                    
                    // Prepare product recommendations if any
                    var recommendedProductIds = botResponse.Products?.Select(p => p.ProductId).ToList();

                    var botMessageRequest = new SaveMessageRequestDto
                    {
                        SessionId = sessionId,
                        Content = botResponse.Message,
                        IsFromUser = false,
                        RecommendedProductIds = recommendedProductIds
                    };

                    var savedBotMessage = await _chatService.SaveMessageAsync(botMessageRequest);
                    _logger.LogInformation("✅ Bot response saved with ID: {MessageId}", savedBotMessage.MessageId);
                }
                else
                {
                    _logger.LogWarning("⚠️ Bot response was not successful, not saving to database");
                }

                _logger.LogInformation("🎉 ProcessMessageWithHistory completed successfully");
                return botResponse;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "💥 Error in ProcessMessageWithHistory: {Message}", ex.Message);
                return new ChatbotResponseDto
                {
                    Success = false,
                    ErrorMessage = "Lỗi lưu lịch sử chat",
                    Message = "Xin lỗi, có lỗi xảy ra khi lưu tin nhắn.",
                    Products = new List<Cosmetics.Models.Product>(),
                    HasProducts = false
                };
            }
        }

        public async Task<List<Cosmetics.Models.Product>> GetRelevantProducts(string message)
        {
            try
            {
                // Lấy tất cả sản phẩm với Brand relation included
                var allProducts = await _productService.GetAllProductsAsync(pageNumber: 1, pageSize: 1000);
                
                // Lọc sản phẩm phù hợp
                return FilterRelevantProducts(allProducts, message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting relevant products for message: {Message}", message);
                return new List<Cosmetics.Models.Product>();
            }
        }

        private bool IsProductRelated(string message)
        {
            var lowerMessage = message.ToLower();
            return _productKeywords.Any(keyword => lowerMessage.Contains(keyword));
        }

        /// Phân tích loại câu hỏi
        private string DetectQuestionType(string message)
        {
            var lowerMessage = message.ToLower();
            foreach (var entry in _questionTypeKeywords)
            {
                if (entry.Value.Any(keyword => lowerMessage.Contains(keyword)))
                {
                    return entry.Key;
                }
            }
            return "general";
        }

        /// Xử lý các tình huống đặc biệt
        private string? HandleSpecialCases(string message)
        {
            var lowerMessage = message.ToLower().Trim();

            // Câu chào hỏi
            var greetings = new[] { "xin chào", "hello", "hi", "chào", "hey", "good morning", "good afternoon" };
            if (greetings.Any(g => lowerMessage.Contains(g)))
            {
                return "Xin chào! Tôi có thể giúp bạn tìm sản phẩm mỹ phẩm phù hợp. Bạn cần tư vấn gì?";
            }

            // Cảm ơn
            var thanks = new[] { "cảm ơn", "thank you", "thanks", "cám ơn", "tks" };
            if (thanks.Any(t => lowerMessage.Contains(t)))
            {
                return "Không có gì! Tôi luôn sẵn sàng hỗ trợ bạn.";
            }

            // Câu hỏi về store/cửa hàng
            var storeQuestions = new[] { "cửa hàng", "store", "địa chỉ", "liên hệ", "hotline", "ở đâu" };
            if (storeQuestions.Any(s => lowerMessage.Contains(s)))
            {
                return "Cosmotopia là cửa hàng mỹ phẩm trực tuyến. Bạn có thể mua sắm qua ứng dụng này. Cần hỗ trợ gì khác?";
            }

            // Câu hỏi về giao hàng
            var shippingQuestions = new[] { "giao hàng", "ship", "vận chuyển", "delivery", "bao lâu", "khi nào nhận" };
            if (shippingQuestions.Any(s => lowerMessage.Contains(s)))
            {
                return "Chúng tôi giao hàng toàn quốc trong 2-3 ngày làm việc. Miễn phí ship đơn từ 200.000đ.";
            }

            // Câu hỏi về thanh toán
            var paymentQuestions = new[] { "thanh toán", "payment", "trả tiền", "pay", "tiền mặt", "chuyển khoản" };
            if (paymentQuestions.Any(p => lowerMessage.Contains(p)))
            {
                return "Chúng tôi hỗ trợ thanh toán qua thẻ, chuyển khoản và tiền mặt khi nhận hàng.";
            }

            // Câu hỏi về đổi trả
            var returnQuestions = new[] { "đổi trả", "return", "hoàn tiền", "refund", "không ưng" };
            if (returnQuestions.Any(r => lowerMessage.Contains(r)))
            {
                return "Chúng tôi hỗ trợ đổi trả trong 7 ngày nếu sản phẩm còn nguyên seal.";
            }

            return null; // Không phải tình huống đặc biệt
        }

        /// Tạo response dựa trên loại câu hỏi
        private string CreateSpecializedResponse(List<Cosmetics.Models.Product> products, string questionType, string originalMessage)
        {
            if (!products.Any())
            {
                return "Không tìm thấy sản phẩm phù hợp. Vui lòng thử với từ khóa khác.";
            }

            var response = "";
            var limitedProducts = products.Take(3).ToList(); // Giới hạn 3 sản phẩm cho response ngắn gọn

            switch (questionType)
            {
                case "price":
                    response = "Thông tin giá sản phẩm:\n\n";
                    foreach (var product in limitedProducts)
                    {
                        var price = product.Price.ToString("N0", new CultureInfo("vi-VN"));
                        response += $"- {product.Name}: {price}đ\n";
                    }
                    break;

                case "brand":
                    response = "Thông tin thương hiệu:\n\n";
                    foreach (var product in limitedProducts)
                    {
                        var brand = product.Brand?.Name ?? "Chưa xác định";
                        response += $"- {product.Name}: {brand}\n";
                    }
                    break;

                case "benefits":
                    response = "Công dụng sản phẩm:\n\n";
                    foreach (var product in limitedProducts)
                    {
                        var desc = !string.IsNullOrEmpty(product.Description) && product.Description.Length > 60
                            ? product.Description.Substring(0, 60) + "..."
                            : product.Description ?? "Chưa có thông tin chi tiết";
                        response += $"- {product.Name}: {desc}\n";
                    }
                    break;

                case "suitability":
                    response = "Sản phẩm phù hợp:\n\n";
                    var skinType = DetectSkinType(originalMessage);
                    if (skinType != null)
                    {
                        response += $"Dành cho {skinType}:\n";
                    }
                    foreach (var product in limitedProducts)
                    {
                        response += $"- {product.Name}\n";
                        if (product.Category?.Name != null)
                        {
                            response += $"  Loại: {product.Category.Name}\n";
                        }
                    }
                    break;

                case "usage":
                    response = "Hướng dẫn sử dụng:\n\n";
                    foreach (var product in limitedProducts)
                    {
                        response += $"- {product.Name}: ";
                        var category = product.Category?.Name?.ToLower() ?? "";
                        if (category.Contains("cleanser") || category.Contains("tẩy trang"))
                        {
                            response += "Thoa lên da, massage nhẹ, rửa sạch với nước.\n";
                        }
                        else if (category.Contains("serum"))
                        {
                            response += "Thoa sau bước làm sạch, trước kem dưỡng.\n";
                        }
                        else if (category.Contains("moisturizer") || category.Contains("dưỡng ẩm"))
                        {
                            response += "Thoa đều lên da sau serum, massage nhẹ.\n";
                        }
                        else
                        {
                            response += "Sử dụng theo hướng dẫn trên bao bì.\n";
                        }
                    }
                    break;

                default:
                    return CreateProductResponse(products, originalMessage);
            }

            response += "\nNhấn vào sản phẩm để xem chi tiết.";
            return response;
        }

        private string? DetectSkinType(string message)
        {
            var lowerMessage = message.ToLower();
            foreach (var entry in _skinTypeKeywords)
            {
                if (entry.Value.Any(keyword => lowerMessage.Contains(keyword)))
                {
                    return entry.Key;
                }
            }
            return null;
        }

        private List<string> DetectPurposes(string message)
        {
            var lowerMessage = message.ToLower();
            var purposes = new List<string>();

            foreach (var entry in _purposeKeywords)
            {
                if (entry.Value.Any(keyword => lowerMessage.Contains(keyword)))
                {
                    purposes.Add(entry.Key);
                }
            }

            return purposes;
        }

        private List<Cosmetics.Models.Product> FilterRelevantProducts(List<Cosmetics.Models.Product> products, string message)
        {
            var lowerMessage = message.ToLower();
            var relevantProducts = new List<Cosmetics.Models.Product>();

            // Detect brand name từ message
            var requestedBrand = DetectBrandFromMessage(lowerMessage);
            
            // Detect purposes từ message
            var purposes = DetectPurposes(message);

            // Định nghĩa từ khóa cho từng loại sản phẩm
            var skincareKeywords = new[] { "skincare", "chăm sóc da", "dưỡng da", "kem", "serum", "toner", "cleanser", "moisturizer", "cream", "lotion" };
            var haircareKeywords = new[] { "haircare", "chăm sóc tóc", "dưỡng tóc", "gội", "xả", "shampoo", "conditioner" };
            var makeupKeywords = new[] { "makeup", "trang điểm", "son", "phấn", "mascara", "foundation", "lipstick" };
            var fragranceKeywords = new[] { "nước hoa", "perfume", "fragrance", "cologne" };

            // Xác định loại sản phẩm được hỏi
            bool isSkincareQuery = skincareKeywords.Any(keyword => lowerMessage.Contains(keyword));
            bool isHaircareQuery = haircareKeywords.Any(keyword => lowerMessage.Contains(keyword));
            bool isMakeupQuery = makeupKeywords.Any(keyword => lowerMessage.Contains(keyword));
            bool isFragranceQuery = fragranceKeywords.Any(keyword => lowerMessage.Contains(keyword));

            // Từ khóa chung
            var generalKeywords = new[] { "sản phẩm", "mỹ phẩm", "làm đẹp", "giới thiệu", "tốt", "hay", "chất lượng", "recommend", "gợi ý" };
            var isGeneralQuery = generalKeywords.Any(keyword => lowerMessage.Contains(keyword)) &&
                                !isSkincareQuery && !isHaircareQuery && !isMakeupQuery && !isFragranceQuery;

            foreach (var product in products)
            {
                bool isRelevant = false;
                var productName = product.Name.ToLower();
                var productDescription = (product.Description ?? "").ToLower();
                var categoryName = product.Category?.Name?.ToLower() ?? "";
                var brandName = product.Brand?.Name?.ToLower() ?? "";

                // **PRIORITY 1: Brand filtering** - Nếu có brand được specify, chỉ trả về products của brand đó
                if (!string.IsNullOrEmpty(requestedBrand))
                {
                    // Exact brand matching (case-insensitive)
                    var productBrand = product.Brand?.Name?.Trim() ?? "";
                    
                    if (!string.Equals(productBrand, requestedBrand, StringComparison.OrdinalIgnoreCase))
                    {
                        continue; // Skip product if brand doesn't match exactly
                    }
                }

                // **PRIORITY 2: Purpose filtering** - Nếu có purpose được specify, filter theo purpose
                if (purposes.Any())
                {
                    bool matchesPurpose = false;
                    foreach (var purpose in purposes)
                    {
                        if (ProductMatchesPurpose(product, purpose, productName, productDescription, categoryName))
                        {
                            matchesPurpose = true;
                            break;
                        }
                    }
                    if (!matchesPurpose)
                    {
                        continue; // Skip product if purpose doesn't match
                    }
                }

                // **PRIORITY 3: Category filtering**
                // Nếu có brand specified, chấp nhận TẤT CẢ products của brand đó
                if (!string.IsNullOrEmpty(requestedBrand))
                {
                    isRelevant = true; // Brand already filtered, accept all products of that brand
                }
                else if (isSkincareQuery)
                {
                    isRelevant = IsSkincareProduct(productName, productDescription, categoryName);
                }
                else if (isHaircareQuery)
                {
                    isRelevant = IsHaircareProduct(productName, productDescription, categoryName);
                }
                else if (isMakeupQuery)
                {
                    isRelevant = IsMakeupProduct(productName, productDescription, categoryName);
                }
                else if (isFragranceQuery)
                {
                    isRelevant = IsFragranceProduct(productName, productDescription, categoryName);
                }
                else if (isGeneralQuery)
                {
                    isRelevant = IsSkincareProduct(productName, productDescription, categoryName) ||
                                IsMakeupProduct(productName, productDescription, categoryName);
                }
                else
                {
                    isRelevant = MatchesSpecificKeywords(product, lowerMessage);
                }

                if (isRelevant)
                {
                    relevantProducts.Add(product);
                }
            }

            // Nếu không tìm thấy sản phẩm nào và là câu hỏi chung (KHÔNG có brand specified), trả về một số sản phẩm skincare
            if (!relevantProducts.Any() && (isGeneralQuery || isSkincareQuery) && products.Any() && string.IsNullOrEmpty(requestedBrand))
            {
                foreach (var product in products)
                {
                    var productName = product.Name.ToLower();
                    var productDescription = (product.Description ?? "").ToLower();
                    var categoryName = product.Category?.Name?.ToLower() ?? "";

                    if (IsSkincareProduct(productName, productDescription, categoryName))
                    {
                        relevantProducts.Add(product);
                        if (relevantProducts.Count >= 6) break;
                    }
                }
            }

            // Giới hạn số lượng sản phẩm trả về (tối đa 6 sản phẩm)
            return relevantProducts.Take(6).ToList();
        }

        /// <summary>
        /// Detect brand name từ message
        /// </summary>
        private string? DetectBrandFromMessage(string lowerMessage)
        {
            // Brand mapping: từ trong message -> brand name trong database
            var brandMappings = new Dictionary<string, string>
            {
                // Database brands (exact matches từ SQL screenshots)
                { "nivea", "Nivea" },
                { "l'oreal", "L'Oreal Paris" },
                { "loreal", "L'Oreal Paris" },
                { "l'oreal paris", "L'Oreal Paris" },
                { "chanel", "Chanel" },
                { "mac", "MAC Cosmetics" },
                { "mac cosmetics", "MAC Cosmetics" },
                { "estée lauder", "Estée Lauder" },
                { "estee lauder", "Estée Lauder" },
                
                // Additional fallback variations
                { "l'oréal", "L'Oreal Paris" },
                { "loréal", "L'Oreal Paris" }
            };

            // Tìm brand longest match first để tránh conflicts
            var sortedBrands = brandMappings.Keys.OrderByDescending(k => k.Length);
            
            foreach (var brandKeyword in sortedBrands)
            {
                if (lowerMessage.Contains(brandKeyword))
                {
                    return brandMappings[brandKeyword]; // Return DB brand name
                }
            }

            return null;
        }

        /// <summary>
        /// Kiểm tra product có match với purpose không
        /// </summary>
        private bool ProductMatchesPurpose(Cosmetics.Models.Product product, string purpose, string productName, string productDescription, string categoryName)
        {
            switch (purpose.ToLower())
            {
                case "chống lão hóa":
                    return IsAntiAgingProduct(productName, productDescription, categoryName);

                case "dưỡng ẩm":
                    return IsMoisturizingProduct(productName, productDescription, categoryName);

                case "làm trắng":
                    return IsWhiteningProduct(productName, productDescription, categoryName);

                case "chống nắng":
                    return IsSunscreenProduct(productName, productDescription, categoryName);

                case "trị mụn":
                    return IsAcneTreatmentProduct(productName, productDescription, categoryName);

                case "làm sạch":
                    return IsCleansingProduct(productName, productDescription, categoryName);

                default:
                    return false;
            }
        }

        // Helper methods for purpose matching
        private bool IsAntiAgingProduct(string name, string description, string category)
        {
            var antiAgingKeywords = new[]
            {
                "anti-aging", "chống lão hóa", "anti aging", "wrinkle", "nếp nhăn",
                "serum", "retinol", "vitamin c", "collagen", "peptide", "firming",
                "lifting", "renewal", "regenerating", "youth", "age", "mature skin"
            };

            var text = $"{name} {description} {category}";
            return antiAgingKeywords.Any(keyword => text.Contains(keyword)) &&
                   !IsMakeupProduct(name, description, category); // Exclude makeup products
        }

        private bool IsMoisturizingProduct(string name, string description, string category)
        {
            var moisturizingKeywords = new[]
            {
                "moisturizer", "dưỡng ẩm", "cấp ẩm", "hydrating", "hydra", "moisture",
                "cream", "kem dưỡng", "lotion", "emulsion", "hyaluronic", "ceramide"
            };

            var text = $"{name} {description} {category}";
            return moisturizingKeywords.Any(keyword => text.Contains(keyword));
        }

        private bool IsWhiteningProduct(string name, string description, string category)
        {
            var whiteningKeywords = new[]
            {
                "whitening", "làm trắng", "brightening", "sáng da", "vitamin c",
                "niacinamide", "arbutin", "kojic", "spot corrector", "đều màu da"
            };

            var text = $"{name} {description} {category}";
            return whiteningKeywords.Any(keyword => text.Contains(keyword));
        }

        private bool IsSunscreenProduct(string name, string description, string category)
        {
            var sunscreenKeywords = new[]
            {
                "sunscreen", "chống nắng", "spf", "sun protection", "uv protection",
                "broad spectrum", "pa++", "zinc oxide", "titanium dioxide"
            };

            var text = $"{name} {description} {category}";
            return sunscreenKeywords.Any(keyword => text.Contains(keyword));
        }

        private bool IsAcneTreatmentProduct(string name, string description, string category)
        {
            var acneKeywords = new[]
            {
                "acne", "mụn", "blemish", "spot treatment", "salicylic acid",
                "benzoyl peroxide", "tea tree", "anti-bacterial", "pore minimizing"
            };

            var text = $"{name} {description} {category}";
            return acneKeywords.Any(keyword => text.Contains(keyword));
        }

        private bool IsCleansingProduct(string name, string description, string category)
        {
            var cleansingKeywords = new[]
            {
                "cleanser", "cleansing", "tẩy trang", "rửa mặt", "làm sạch",
                "makeup remover", "micellar", "cleansing oil", "foam cleanser",
                "gel cleanser", "cream cleanser"
            };

            var text = $"{name} {description} {category}";
            return cleansingKeywords.Any(keyword => text.Contains(keyword));
        }

        private bool IsSkincareProduct(string name, string description, string category)
        {
            var skincareKeywords = new[]
            {
                "cream", "kem", "serum", "toner", "cleanser", "moisturizer", "lotion",
                "facial", "face", "skin", "da", "dưỡng", "chăm sóc da", "skincare",
                "rửa mặt", "tẩy trang", "dưỡng ẩm", "chống nắng", "anti-aging",
                "hydrating", "cleansing", "night cream", "day cream"
            };

            var text = $"{name} {description} {category}";
            return skincareKeywords.Any(keyword => text.Contains(keyword)) &&
                   !IsHaircareProduct(name, description, category) &&
                   !IsFragranceProduct(name, description, category);
        }

        private bool IsHaircareProduct(string name, string description, string category)
        {
            var haircareKeywords = new[]
            {
                "shampoo", "gội", "xả", "conditioner", "hair", "tóc", "dưỡng tóc",
                "chăm sóc tóc", "haircare", "volumizing"
            };

            var text = $"{name} {description} {category}";
            return haircareKeywords.Any(keyword => text.Contains(keyword));
        }

        private bool IsMakeupProduct(string name, string description, string category)
        {
            var makeupKeywords = new[]
            {
                "lipstick", "son", "mascara", "foundation", "phấn", "makeup",
                "trang điểm", "rouge", "blush", "eyeshadow", "concealer"
            };

            var text = $"{name} {description} {category}";
            return makeupKeywords.Any(keyword => text.Contains(keyword));
        }

        private bool IsFragranceProduct(string name, string description, string category)
        {
            var fragranceKeywords = new[]
            {
                "perfume", "nước hoa", "fragrance", "cologne", "eau de",
                "parfum", "scent"
            };

            var text = $"{name} {description} {category}";
            return fragranceKeywords.Any(keyword => text.Contains(keyword));
        }

        private bool MatchesSpecificKeywords(Cosmetics.Models.Product product, string message)
        {
            var productName = product.Name.ToLower();
            var productDescription = (product.Description ?? "").ToLower();
            var categoryName = product.Category?.Name?.ToLower() ?? "";
            var brandName = product.Brand?.Name?.ToLower() ?? "";

            // Kiểm tra từ khóa trong tên sản phẩm
            if (productName.Contains(message) ||
                message.Split(' ').Any(word => word.Length > 2 && productName.Contains(word)))
            {
                return true;
            }

            // Kiểm tra từ khóa trong mô tả
            if (productDescription.Contains(message) ||
                message.Split(' ').Any(word => word.Length > 2 && productDescription.Contains(word)))
            {
                return true;
            }

            // Kiểm tra từ khóa trong danh mục
            if (categoryName.Contains(message) ||
                message.Split(' ').Any(word => word.Length > 2 && categoryName.Contains(word)))
            {
                return true;
            }

            // Kiểm tra từ khóa trong thương hiệu
            if (brandName.Contains(message) ||
                message.Split(' ').Any(word => word.Length > 2 && brandName.Contains(word)))
            {
                return true;
            }

            return false;
        }

        private string CreateProductResponse(List<Cosmetics.Models.Product> products, string originalMessage)
        {
            if (!products.Any())
            {
                return "Không tìm thấy sản phẩm phù hợp. Vui lòng thử với từ khóa khác.";
            }

            var lowerMessage = originalMessage.ToLower();
            var skinType = DetectSkinType(originalMessage);
            var purposes = DetectPurposes(originalMessage);

            // Kiểm tra xem có phải câu hỏi chung không
            var generalKeywords = new[] { "skincare", "sản phẩm", "mỹ phẩm", "làm đẹp", "chăm sóc da", "giới thiệu" };
            var isGeneralQuery = generalKeywords.Any(keyword => lowerMessage.Contains(keyword));

            var response = "";

            if (isGeneralQuery)
            {
                response = "Một số sản phẩm phổ biến:\n\n";
            }
            else
            {
                response = "Sản phẩm phù hợp";

                if (skinType != null)
                {
                    response += $" cho {skinType}";
                }

                if (purposes.Any())
                {
                    response += $" với mục đích {string.Join(", ", purposes)}";
                }

                response += ":\n\n";
            }

            for (int i = 0; i < products.Count && i < 5; i++) // Giới hạn 5 sản phẩm
            {
                var product = products[i];
                var price = product.Price.ToString("N0", new CultureInfo("vi-VN"));
                response += $"{i + 1}. {product.Name} - {price}đ\n";

                // Thêm thông tin ngắn gọn
                var productInfo = new List<string>();
                if (product.Brand?.Name != null)
                {
                    productInfo.Add(product.Brand.Name);
                }
                if (product.Category?.Name != null)
                {
                    productInfo.Add(product.Category.Name);
                }
                if (productInfo.Any())
                {
                    response += $"   {string.Join(" - ", productInfo)}\n";
                }

                // Mô tả ngắn gọn hơn
                if (!string.IsNullOrEmpty(product.Description))
                {
                    string desc = product.Description;
                    if (desc.Length > 50)
                    {
                        desc = desc.Substring(0, 50) + "...";
                    }
                    response += $"   {desc}\n";
                }
                response += "\n";
            }

            response += "Nhấn vào sản phẩm để xem chi tiết.";

            return response;
        }

        // Các phương thức hỗ trợ cho tính năng mở rộng
        private bool IsSearchMoreRequest(string message)
        {
            var keywords = new[] { "thêm thông tin", "more info", "tìm kiếm thêm", "search more", "google" };
            return keywords.Any(keyword => message.ToLower().Contains(keyword));
        }

        private bool IsSimilarProductRequest(string message)
        {
            var keywords = new[] { "tương tự", "giống", "như", "so sánh", "thay thế", "alternative", "similar" };
            return keywords.Any(keyword => message.ToLower().Contains(keyword));
        }

        private bool IsSearchAnotherMoreRequest(string message)
        {
            var keywords = new[] { "sản phẩm khác", "option khác", "lựa chọn khác", "có gì khác", "thêm nữa", "more" };
            return keywords.Any(keyword => message.ToLower().Contains(keyword));
        }

        private async Task<ChatbotResponseDto> HandleSearchMoreRequest(string message, string originalQuery, string sessionId)
        {
            // Placeholder cho tính năng tìm kiếm Google
            return new ChatbotResponseDto
            {
                Message = "Tính năng tìm kiếm Google đang phát triển. Vui lòng thử lại sau.",
                Products = new List<Cosmetics.Models.Product>(),
                HasProducts = false,
                IsSearchResult = true,
                Context = sessionId
            };
        }

        private async Task<ChatbotResponseDto> FindSimilarProducts(string productName, string sessionId)
        {
            // Placeholder cho tính năng tìm sản phẩm tương tự
            return new ChatbotResponseDto
            {
                Message = "Tính năng tìm sản phẩm tương tự đang phát triển.",
                Products = new List<Cosmetics.Models.Product>(),
                HasProducts = false,
                SimilarProducts = new List<SimilarProductDto>(),
                HasSimilarProducts = false,
                Context = sessionId
            };
        }

        private async Task<ChatbotResponseDto> FindMoreSimilarProducts(string message, string sessionId)
        {
            // Placeholder cho tính năng tìm thêm sản phẩm tương tự
            return new ChatbotResponseDto
            {
                Message = "Tính năng này đang phát triển.",
                Products = new List<Cosmetics.Models.Product>(),
                HasProducts = false,
                SimilarProducts = new List<SimilarProductDto>(),
                HasSimilarProducts = false,
                Context = sessionId
            };
        }

        // Context management
        private ChatSessionContextDto GetSessionContext(string sessionId)
        {
            var cacheKey = $"chatbot_context_{sessionId}";
            return _cache.GetOrCreate(cacheKey, entry =>
            {
                entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(2); // Context expires after 2 hours
                return new ChatSessionContextDto { SessionId = sessionId };
            });
        }

        private void SaveSessionContext(string sessionId, ChatSessionContextDto context)
        {
            var cacheKey = $"chatbot_context_{sessionId}";
            _cache.Set(cacheKey, context, TimeSpan.FromHours(2));
        }

        public void ResetContext(string sessionId)
        {
            var cacheKey = $"chatbot_context_{sessionId}";
            _cache.Remove(cacheKey);
        }
    }
} 