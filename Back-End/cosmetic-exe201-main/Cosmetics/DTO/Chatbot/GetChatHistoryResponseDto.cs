namespace Cosmetics.DTO.Chatbot
{
    public class GetChatHistoryResponseDto
    {
        public ChatSessionDto Session { get; set; } = null!;
        public List<ChatMessageDto> Messages { get; set; } = new List<ChatMessageDto>();
        public int TotalMessages { get; set; }
    }
} 