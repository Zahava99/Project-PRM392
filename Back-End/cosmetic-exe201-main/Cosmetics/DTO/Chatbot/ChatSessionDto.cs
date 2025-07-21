namespace Cosmetics.DTO.Chatbot
{
    public class ChatSessionDto
    {
        public Guid SessionId { get; set; }
        public int UserId { get; set; }
        public string? SessionName { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public bool IsActive { get; set; }
        public int MessageCount { get; set; }
        public string? LastMessage { get; set; }
        public DateTime? LastMessageTime { get; set; }
    }
} 