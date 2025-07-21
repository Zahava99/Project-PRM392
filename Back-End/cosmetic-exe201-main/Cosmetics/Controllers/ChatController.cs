using Cosmetics.Service.Gemini;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Cosmetics.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChatController : ControllerBase
    {
        private readonly GeminiChatService _chatService;

        public ChatController(GeminiChatService chatService)
        {
            _chatService = chatService;
        }

        [HttpPost]
        public async Task<IActionResult> Chat([FromBody] ChatRequest request)
        {
            if (string.IsNullOrEmpty(request?.Message))
                return BadRequest("Message is required.");

            try
            {
                string response;
                
                // Check if this is an image analysis request
                if (request.HasImage && !string.IsNullOrEmpty(request.ImageBase64))
                {
                    // Handle image analysis
                    response = await _chatService.GetImageAnalysisResponse(request.Message, request.ImageBase64);
                }
                else
                {
                    // Handle text-only chat
                    response = await _chatService.GetChatResponse(request.Message);
                }

                return Ok(new { response });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
    }

    public class ChatRequest
    {
        public string Message { get; set; }
        public string? ImageBase64 { get; set; }
        public bool HasImage { get; set; }
    }
}