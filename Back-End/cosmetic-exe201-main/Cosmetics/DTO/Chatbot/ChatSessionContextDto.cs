using Cosmetics.Models;

namespace Cosmetics.DTO.Chatbot
{
    public class ChatSessionContextDto
    {
        public string? LastProductQuery { get; set; }
        
        public List<Cosmetics.Models.Product>? LastProductResults { get; set; }
        
        public List<SimilarProductDto>? LastSimilarProducts { get; set; }
        
        public DateTime? LastQueryTime { get; set; }
        
        public string? SessionId { get; set; }
        
        public int? UserId { get; set; }
        
        public Dictionary<string, object>? AdditionalData { get; set; }
    }
} 