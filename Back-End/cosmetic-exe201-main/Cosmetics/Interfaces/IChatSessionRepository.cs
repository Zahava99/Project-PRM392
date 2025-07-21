using Cosmetics.Models;

namespace Cosmetics.Interfaces
{
    public interface IChatSessionRepository : IGenericRepository<ChatSession>
    {
        Task<IEnumerable<ChatSession>> GetUserSessionsAsync(int userId);
        Task<ChatSession?> GetSessionWithMessagesAsync(Guid sessionId);
        Task<ChatSession?> GetActiveSessionByUserAsync(int userId);
        Task<bool> DeactivateSessionAsync(Guid sessionId);
        Task<bool> DeleteSessionAsync(Guid sessionId);
    }
} 