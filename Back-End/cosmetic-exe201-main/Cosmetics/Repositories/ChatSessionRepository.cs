using Cosmetics.Interfaces;
using Cosmetics.Models;
using Microsoft.EntityFrameworkCore;

namespace Cosmetics.Repositories
{
    public class ChatSessionRepository : GenericRepository<ChatSession>, IChatSessionRepository
    {
        public ChatSessionRepository(ComedicShopDBContext context) : base(context)
        {
        }

        public async Task<IEnumerable<ChatSession>> GetUserSessionsAsync(int userId)
        {
            return await _dbSet
                .Where(s => s.UserId == userId)
                .Include(s => s.Messages)
                .OrderByDescending(s => s.UpdatedAt)
                .ToListAsync();
        }

        public async Task<ChatSession?> GetSessionWithMessagesAsync(Guid sessionId)
        {
            return await _dbSet
                .Include(s => s.Messages.OrderBy(m => m.SentAt))
                .Include(s => s.User)
                .FirstOrDefaultAsync(s => s.SessionId == sessionId);
        }

        public async Task<ChatSession?> GetActiveSessionByUserAsync(int userId)
        {
            return await _dbSet
                .Where(s => s.UserId == userId && s.IsActive)
                .Include(s => s.Messages)
                .OrderByDescending(s => s.UpdatedAt)
                .FirstOrDefaultAsync();
        }

        public async Task<bool> DeactivateSessionAsync(Guid sessionId)
        {
            var session = await _dbSet.FindAsync(sessionId);
            if (session == null) return false;

            session.IsActive = false;
            session.UpdatedAt = DateTime.UtcNow;
            
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteSessionAsync(Guid sessionId)
        {
            var session = await _dbSet.FindAsync(sessionId);
            if (session == null) return false;

            _dbSet.Remove(session);
            await _context.SaveChangesAsync();
            return true;
        }
    }
} 