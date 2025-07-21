using Cosmetics.DTO.Chatbot;
using Cosmetics.Service.Chatbot;
using Cosmetics.Service.Gemini;
using Cosmetics.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;

namespace Cosmetics.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChatbotController : ControllerBase
    {
        private readonly IChatbotService _chatbotService;
        private readonly GeminiChatService _geminiChatService;
        private readonly IChatService _chatService;
        private readonly ILogger<ChatbotController> _logger;

        public ChatbotController(
            IChatbotService chatbotService, 
            GeminiChatService geminiChatService,
            IChatService chatService,
            ILogger<ChatbotController> logger)
        {
            _chatbotService = chatbotService;
            _geminiChatService = geminiChatService;
            _chatService = chatService;
            _logger = logger;
        }

        /// <summary>
        /// Xử lý tin nhắn chatbot với logic phân tích sản phẩm
        /// </summary>
        [HttpPost("process")]
        public async Task<IActionResult> ProcessMessage([FromBody] ChatbotRequestDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var result = await _chatbotService.ProcessMessage(request);

                // Nếu cần gửi đến AI chatbot
                if (result.ShouldSendToAPI)
                {
                    try
                    {
                        var aiResponse = await _geminiChatService.GetChatResponse(request.Message);
                        result.Message = aiResponse;
                        result.ShouldSendToAPI = false;
                    }
                    catch (Exception aiEx)
                    {
                        _logger.LogError(aiEx, "Error calling Gemini AI for message: {Message}", request.Message);
                        result.Message = "Hệ thống AI tạm thời không khả dụng. Vui lòng thử lại sau.";
                    }
                }

                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing chatbot message: {Message}", request.Message);
                return StatusCode(500, new ChatbotResponseDto
                {
                    Success = false,
                    ErrorMessage = "Lỗi hệ thống",
                    Message = "Không thể xử lý yêu cầu. Vui lòng thử lại sau."
                });
            }
        }

        /// <summary>
        /// Xử lý tin nhắn chatbot với auto-save lịch sử chat
        /// </summary>
        [HttpPost("process-with-history")]
        public async Task<IActionResult> ProcessMessageWithHistory([FromBody] ChatbotRequestDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var result = await _chatbotService.ProcessMessageWithHistory(request);

                // Nếu cần gửi đến AI chatbot
                if (result.ShouldSendToAPI)
                {
                    try
                    {
                        var aiResponse = await _geminiChatService.GetChatResponse(request.Message);
                        result.Message = aiResponse;
                        result.ShouldSendToAPI = false;

                        // Save AI response to database if we have session info
                        if (request.UserId.HasValue && !string.IsNullOrEmpty(request.SessionId) && Guid.TryParse(request.SessionId, out var sessionId))
                        {
                            var aiMessageRequest = new SaveMessageRequestDto
                            {
                                SessionId = sessionId,
                                Content = aiResponse,
                                IsFromUser = false,
                                RecommendedProductIds = null
                            };
                            await _chatService.SaveMessageAsync(aiMessageRequest);
                            _logger.LogInformation("✅ AI response saved to database");
                        }
                    }
                    catch (Exception aiEx)
                    {
                        _logger.LogError(aiEx, "Error calling Gemini AI for message: {Message}", request.Message);
                        result.Message = "Hệ thống AI tạm thời không khả dụng. Vui lòng thử lại sau.";
                    }
                }

                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing chatbot message with history: {Message}", request.Message);
                return StatusCode(500, new ChatbotResponseDto
                {
                    Success = false,
                    ErrorMessage = "Lỗi hệ thống",
                    Message = "Không thể xử lý yêu cầu. Vui lòng thử lại sau."
                });
            }
        }

        /// <summary>
        /// Tìm kiếm sản phẩm phù hợp với tin nhắn
        /// </summary>
        [HttpPost("search-products")]
        public async Task<IActionResult> SearchProducts([FromBody] ProductSearchRequestDto request)
        {
            if (string.IsNullOrEmpty(request?.Query))
            {
                return BadRequest("Query is required");
            }

            try
            {
                var products = await _chatbotService.GetRelevantProducts(request.Query);
                return Ok(new
                {
                    products = products,
                    count = products.Count,
                    query = request.Query
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching products for query: {Query}", request.Query);
                return StatusCode(500, "Error searching products");
            }
        }

        /// <summary>
        /// Reset context phiên chat
        /// </summary>
        [HttpPost("reset-context")]
        public IActionResult ResetContext([FromBody] ResetContextRequestDto request)
        {
            if (string.IsNullOrEmpty(request?.SessionId))
            {
                return BadRequest("SessionId is required");
            }

            try
            {
                _chatbotService.ResetContext(request.SessionId);
                return Ok(new { message = "Đã reset context thành công" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error resetting context for session: {SessionId}", request.SessionId);
                return StatusCode(500, "Error resetting context");
            }
        }

        /// <summary>
        /// Xử lý tin nhắn với hình ảnh (kết hợp với AI analysis)
        /// </summary>
        [HttpPost("process-with-image")]
        public async Task<IActionResult> ProcessWithImage([FromBody] ChatbotImageRequestDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                // Xử lý hình ảnh với Gemini AI trước
                string aiResponse;
                if (!string.IsNullOrEmpty(request.ImageBase64))
                {
                    aiResponse = await _geminiChatService.GetImageAnalysisResponse(request.Message, request.ImageBase64);
                }
                else
                {
                    // Nếu không có ảnh, xử lý như tin nhắn thường
                    var chatbotRequest = new ChatbotRequestDto
                    {
                        Message = request.Message,
                        SessionId = request.SessionId,
                        UserId = request.UserId
                    };
                    var result = await _chatbotService.ProcessMessage(chatbotRequest);
                    return Ok(result);
                }

                // Kết hợp kết quả AI với logic sản phẩm nếu cần
                var response = new ChatbotResponseDto
                {
                    Message = aiResponse,
                    Products = new List<Cosmetics.Models.Product>(),
                    HasProducts = false,
                    Context = request.SessionId
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing image message: {Message}", request.Message);
                return StatusCode(500, new ChatbotResponseDto
                {
                    Success = false,
                    ErrorMessage = "Lỗi xử lý hình ảnh",
                    Message = "Không thể phân tích hình ảnh lúc này."
                });
            }
        }

        // ===== CHAT HISTORY ENDPOINTS =====

        /// <summary>
        /// Bắt đầu session chat mới cho user
        /// </summary>
        [HttpPost("sessions/start")]
        public async Task<IActionResult> StartSession([FromBody] StartSessionRequestDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var session = await _chatService.StartNewSessionAsync(request);
                return Ok(session);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error starting chat session for user {UserId}", request.UserId);
                return StatusCode(500, new { error = "Internal server error", details = ex.Message });
            }
        }

        /// <summary>
        /// Lấy danh sách chat sessions của user
        /// </summary>
        [HttpGet("sessions/{userId}")]
        public async Task<IActionResult> GetUserSessions(int userId)
        {
            try
            {
                var sessions = await _chatService.GetUserSessionsAsync(userId);
                return Ok(sessions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting chat sessions for user {UserId}", userId);
                return StatusCode(500, new { error = "Internal server error", details = ex.Message });
            }
        }

        /// <summary>
        /// Lấy lịch sử chat của một session
        /// </summary>
        [HttpGet("sessions/{sessionId}/history")]
        public async Task<IActionResult> GetChatHistory(Guid sessionId)
        {
            try
            {
                var history = await _chatService.GetChatHistoryAsync(sessionId);
                return Ok(history);
            }
            catch (InvalidOperationException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting chat history for session {SessionId}", sessionId);
                return StatusCode(500, new { error = "Internal server error", details = ex.Message });
            }
        }

        /// <summary>
        /// Lưu tin nhắn vào session
        /// </summary>
        [HttpPost("sessions/messages")]
        public async Task<IActionResult> SaveMessage([FromBody] SaveMessageRequestDto request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var message = await _chatService.SaveMessageAsync(request);
                return Ok(message);
            }
            catch (InvalidOperationException ex)
            {
                return NotFound(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving message for session {SessionId}", request.SessionId);
                return StatusCode(500, new { error = "Internal server error", details = ex.Message });
            }
        }

        /// <summary>
        /// Lấy active session của user
        /// </summary>
        [HttpGet("sessions/{userId}/active")]
        public async Task<IActionResult> GetActiveSession(int userId)
        {
            try
            {
                var session = await _chatService.GetActiveSessionAsync(userId);
                if (session == null)
                {
                    return NotFound(new { error = "No active session found" });
                }
                return Ok(session);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting active session for user {UserId}", userId);
                return StatusCode(500, new { error = "Internal server error", details = ex.Message });
            }
        }

        /// <summary>
        /// Deactivate session
        /// </summary>
        [HttpPut("sessions/{sessionId}/deactivate")]
        public async Task<IActionResult> DeactivateSession(Guid sessionId)
        {
            try
            {
                var result = await _chatService.DeactivateSessionAsync(sessionId);
                if (!result)
                {
                    return NotFound(new { error = "Session not found" });
                }
                return Ok(new { success = true, message = "Session deactivated successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deactivating session {SessionId}", sessionId);
                return StatusCode(500, new { error = "Internal server error", details = ex.Message });
            }
        }

        /// <summary>
        /// Xóa session và tất cả messages của nó
        /// </summary>
        [HttpDelete("sessions/{sessionId}")]
        public async Task<IActionResult> DeleteSession(Guid sessionId)
        {
            try
            {
                var result = await _chatService.DeleteSessionAsync(sessionId);
                if (!result)
                {
                    return NotFound(new { error = "Session not found" });
                }
                return Ok(new { success = true, message = "Session deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting session {SessionId}", sessionId);
                return StatusCode(500, new { error = "Internal server error", details = ex.Message });
            }
        }
    }

    // Additional DTOs for specific endpoints
    public class ProductSearchRequestDto
    {
        [Required]
        public string Query { get; set; }
    }

    public class ResetContextRequestDto
    {
        [Required]
        public string SessionId { get; set; }
    }

    public class ChatbotImageRequestDto
    {
        [Required]
        public string Message { get; set; }
        
        public string? SessionId { get; set; }
        
        public int? UserId { get; set; }
        
        public string? ImageBase64 { get; set; }
    }
} 