using System.ComponentModel.DataAnnotations;

namespace Cosmetics.DTO.Chatbot
{
    public class SaveMessageRequestDto
    {
        [Required]
        public Guid SessionId { get; set; }
        
        [Required]
        public string Content { get; set; } = string.Empty;
        
        [Required]
        public bool IsFromUser { get; set; }
        
        public List<Guid>? RecommendedProductIds { get; set; }
    }
} 