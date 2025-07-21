using System.ComponentModel.DataAnnotations;

namespace Cosmetics.DTO.Chatbot
{
    public class ChatbotRequestDto
    {
        [Required]
        public string Message { get; set; }
        
        public string? SessionId { get; set; }
        
        public int? UserId { get; set; }
        
        public bool IsProductQuery { get; set; }
        
        public string? Context { get; set; }
    }
} 