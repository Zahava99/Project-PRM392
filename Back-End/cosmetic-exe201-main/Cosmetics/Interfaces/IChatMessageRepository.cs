using Cosmetics.Models;

namespace Cosmetics.Interfaces
{
    public interface IChatMessageRepository : IGenericRepository<ChatMessage>
    {
        Task<IEnumerable<ChatMessage>> GetSessionMessagesAsync(Guid sessionId);
        Task<IEnumerable<ChatMessage>> GetSessionMessagesAsync(Guid sessionId, int skip, int take);
        Task<ChatMessage?> GetLastMessageInSessionAsync(Guid sessionId);
        Task<int> GetMessageCountInSessionAsync(Guid sessionId);
    }
} 