using Cosmetics.DTO.Chatbot;

namespace Cosmetics.Interfaces
{
    public interface IChatService
    {
        Task<ChatSessionDto> StartNewSessionAsync(StartSessionRequestDto request);
        Task<IEnumerable<ChatSessionDto>> GetUserSessionsAsync(int userId);
        Task<GetChatHistoryResponseDto> GetChatHistoryAsync(Guid sessionId);
        Task<ChatMessageDto> SaveMessageAsync(SaveMessageRequestDto request);
        Task<bool> DeactivateSessionAsync(Guid sessionId);
        Task<bool> DeleteSessionAsync(Guid sessionId);
        Task<ChatSessionDto?> GetActiveSessionAsync(int userId);
    }
} 