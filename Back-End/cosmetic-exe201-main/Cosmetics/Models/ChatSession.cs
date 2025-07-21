using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Cosmetics.Models
{
    public class ChatSession
    {
        [Key]
        public Guid SessionId { get; set; } = Guid.NewGuid();

        [Required]
        public int UserId { get; set; }

        [StringLength(255)]
        public string? SessionName { get; set; }

        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Required]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [Required]
        public bool IsActive { get; set; } = true;

        // Navigation properties
        [ForeignKey("UserId")]
        public virtual User User { get; set; } = null!;

        public virtual ICollection<ChatMessage> Messages { get; set; } = new List<ChatMessage>();
    }
} 