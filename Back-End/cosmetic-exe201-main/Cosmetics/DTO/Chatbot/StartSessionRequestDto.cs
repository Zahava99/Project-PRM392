using System.ComponentModel.DataAnnotations;

namespace Cosmetics.DTO.Chatbot
{
    public class StartSessionRequestDto
    {
        [Required]
        public int UserId { get; set; }
        
        [StringLength(255)]
        public string? SessionName { get; set; }
    }
} 