using Cosmetics.Models;

namespace Cosmetics.DTO.Chatbot
{
    public class ChatbotResponseDto
    {
        public string Message { get; set; }
        
        public List<Cosmetics.Models.Product>? Products { get; set; }
        
        public bool HasProducts { get; set; }
        
        public bool ShouldSendToAPI { get; set; }
        
        public bool IsSearchResult { get; set; }
        
        public List<SimilarProductDto>? SimilarProducts { get; set; }
        
        public bool HasSimilarProducts { get; set; }
        
        public string? Context { get; set; }
        
        public bool Success { get; set; } = true;
        
        public string? ErrorMessage { get; set; }
    }
    
    public class SimilarProductDto
    {
        public string Name { get; set; }
        
        public string? Description { get; set; }
        
        public string? Price { get; set; }
        
        public string? ImageUrl { get; set; }
        
        public string? SourceUrl { get; set; }
        
        public string? Brand { get; set; }
        
        public string? Category { get; set; }
    }
} 