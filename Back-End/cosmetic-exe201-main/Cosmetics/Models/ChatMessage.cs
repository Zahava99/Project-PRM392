using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Cosmetics.Models
{
    public class ChatMessage
    {
        [Key]
        public Guid MessageId { get; set; } = Guid.NewGuid();

        [Required]
        public Guid SessionId { get; set; }

        [Required]
        [Column(TypeName = "nvarchar(max)")]
        public string Content { get; set; } = string.Empty;

        [Required]
        public bool IsFromUser { get; set; }

        [Required]
        public DateTime SentAt { get; set; } = DateTime.UtcNow;

        [Column(TypeName = "nvarchar(max)")]
        public string? ProductRecommendations { get; set; } // JSON array of product IDs

        // Navigation properties
        [ForeignKey("SessionId")]
        public virtual ChatSession Session { get; set; } = null!;
    }
} 