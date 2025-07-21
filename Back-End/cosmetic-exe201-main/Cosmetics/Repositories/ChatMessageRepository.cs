using Cosmetics.Interfaces;
using Cosmetics.Models;
using Microsoft.EntityFrameworkCore;

namespace Cosmetics.Repositories
{
    public class ChatMessageRepository : GenericRepository<ChatMessage>, IChatMessageRepository
    {
        public ChatMessageRepository(ComedicShopDBContext context) : base(context)
        {
        }

        public async Task<IEnumerable<ChatMessage>> GetSessionMessagesAsync(Guid sessionId)
        {
            return await _dbSet
                .Where(m => m.SessionId == sessionId)
                .OrderBy(m => m.SentAt)
                .ToListAsync();
        }

        public async Task<IEnumerable<ChatMessage>> GetSessionMessagesAsync(Guid sessionId, int skip, int take)
        {
            return await _dbSet
                .Where(m => m.SessionId == sessionId)
                .OrderBy(m => m.SentAt)
                .Skip(skip)
                .Take(take)
                .ToListAsync();
        }

        public async Task<ChatMessage?> GetLastMessageInSessionAsync(Guid sessionId)
        {
            return await _dbSet
                .Where(m => m.SessionId == sessionId)
                .OrderByDescending(m => m.SentAt)
                .FirstOrDefaultAsync();
        }

        public async Task<int> GetMessageCountInSessionAsync(Guid sessionId)
        {
            return await _dbSet
                .CountAsync(m => m.SessionId == sessionId);
        }
    }
} 