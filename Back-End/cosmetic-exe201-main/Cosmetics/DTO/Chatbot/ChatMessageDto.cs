namespace Cosmetics.DTO.Chatbot
{
    public class ChatMessageDto
    {
        public Guid MessageId { get; set; }
        public Guid SessionId { get; set; }
        public string Content { get; set; } = string.Empty;
        public bool IsFromUser { get; set; }
        public DateTime SentAt { get; set; }
        public List<Guid>? RecommendedProductIds { get; set; }
    }
} 