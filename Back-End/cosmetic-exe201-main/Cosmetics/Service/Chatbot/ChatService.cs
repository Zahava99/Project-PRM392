using AutoMapper;
using Cosmetics.DTO.Chatbot;
using Cosmetics.Interfaces;
using Cosmetics.Models;
using System.Text.Json;

namespace Cosmetics.Service.Chatbot
{
    public class ChatService : IChatService
    {
        private readonly IChatSessionRepository _sessionRepository;
        private readonly IChatMessageRepository _messageRepository;
        private readonly IMapper _mapper;
        private readonly ComedicShopDBContext _context; // ✅ THÊM CONTEXT

        public ChatService(
            IChatSessionRepository sessionRepository,
            IChatMessageRepository messageRepository,
            IMapper mapper,
            ComedicShopDBContext context) // ✅ THÊM CONTEXT VÀO CONSTRUCTOR
        {
            _sessionRepository = sessionRepository;
            _messageRepository = messageRepository;
            _mapper = mapper;
            _context = context; // ✅ ASSIGN CONTEXT
        }

        public async Task<ChatSessionDto> StartNewSessionAsync(StartSessionRequestDto request)
        {
            // Deactivate existing active session
            var existingSession = await _sessionRepository.GetActiveSessionByUserAsync(request.UserId);
            if (existingSession != null)
            {
                await _sessionRepository.DeactivateSessionAsync(existingSession.SessionId);
            }

            // Create new session
            var newSession = new ChatSession
            {
                UserId = request.UserId,
                SessionName = request.SessionName ?? $"Chat Session {DateTime.UtcNow:yyyy-MM-dd HH:mm}",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                IsActive = true
            };

            await _sessionRepository.AddAsync(newSession);
            // ✅ SỬA THÀNH DÙNG CONTEXT TRỰC TIẾP
            await _context.SaveChangesAsync();

            var sessionDto = _mapper.Map<ChatSessionDto>(newSession);
            sessionDto.MessageCount = 0;
            sessionDto.LastMessage = null;
            sessionDto.LastMessageTime = null;

            return sessionDto;
        }

        public async Task<IEnumerable<ChatSessionDto>> GetUserSessionsAsync(int userId)
        {
            var sessions = await _sessionRepository.GetUserSessionsAsync(userId);
            var sessionDtos = new List<ChatSessionDto>();

            foreach (var session in sessions)
            {
                var sessionDto = _mapper.Map<ChatSessionDto>(session);
                
                // Get additional info
                sessionDto.MessageCount = session.Messages?.Count ?? 0;
                var lastMessage = session.Messages?.OrderByDescending(m => m.SentAt).FirstOrDefault();
                if (lastMessage != null)
                {
                    sessionDto.LastMessage = lastMessage.Content.Length > 50 
                        ? lastMessage.Content.Substring(0, 50) + "..." 
                        : lastMessage.Content;
                    sessionDto.LastMessageTime = DateTime.SpecifyKind(lastMessage.SentAt, DateTimeKind.Utc);
                    
                    Console.WriteLine($"🕐 DEBUG GetUserSessions - LastMessage SentAt from DB: {lastMessage.SentAt:yyyy-MM-dd HH:mm:ss.fff}");
                    Console.WriteLine($"🕐 DEBUG GetUserSessions - LastMessageTime in DTO: {sessionDto.LastMessageTime:yyyy-MM-dd HH:mm:ss.fff}");
                }

                sessionDtos.Add(sessionDto);
            }

            return sessionDtos;
        }

        public async Task<GetChatHistoryResponseDto> GetChatHistoryAsync(Guid sessionId)
        {
            var session = await _sessionRepository.GetSessionWithMessagesAsync(sessionId);
            if (session == null)
            {
                throw new InvalidOperationException($"Chat session with ID {sessionId} not found.");
            }

            var sessionDto = _mapper.Map<ChatSessionDto>(session);
            sessionDto.MessageCount = session.Messages?.Count ?? 0;

            var messageDtos = new List<ChatMessageDto>();
            if (session.Messages != null)
            {
                foreach (var message in session.Messages.OrderBy(m => m.SentAt))
                {
                    var messageDto = _mapper.Map<ChatMessageDto>(message);
                    
                    Console.WriteLine($"🛍️ DEBUG GetChatHistory - Message: {message.Content.Substring(0, Math.Min(50, message.Content.Length))}...");
                    Console.WriteLine($"🛍️ DEBUG GetChatHistory - ProductRecommendations from DB: {message.ProductRecommendations ?? "NULL"}");
                    
                    // Parse product recommendations from JSON
                    if (!string.IsNullOrEmpty(message.ProductRecommendations))
                    {
                        try
                        {
                            messageDto.RecommendedProductIds = JsonSerializer.Deserialize<List<Guid>>(message.ProductRecommendations);
                            Console.WriteLine($"🛍️ DEBUG GetChatHistory - Parsed {messageDto.RecommendedProductIds?.Count ?? 0} product IDs: {string.Join(", ", messageDto.RecommendedProductIds ?? new List<Guid>())}");
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"❌ DEBUG GetChatHistory - Error parsing ProductRecommendations: {ex.Message}");
                            messageDto.RecommendedProductIds = new List<Guid>();
                        }
                    }
                    else
                    {
                        Console.WriteLine($"🛍️ DEBUG GetChatHistory - No ProductRecommendations for this message");
                    }

                    messageDtos.Add(messageDto);
                }
            }

            return new GetChatHistoryResponseDto
            {
                Session = sessionDto,
                Messages = messageDtos,
                TotalMessages = messageDtos.Count
            };
        }

        public async Task<ChatMessageDto> SaveMessageAsync(SaveMessageRequestDto request)
        {
            // Verify session exists
            var session = await _sessionRepository.GetByIdAsync(request.SessionId);
            if (session == null)
            {
                throw new InvalidOperationException($"Chat session with ID {request.SessionId} not found.");
            }

            // Create message
            var utcNow = DateTime.UtcNow;
            var localNow = DateTime.Now;
            Console.WriteLine($"🕐 DEBUG TIMEZONE - UTC: {utcNow:yyyy-MM-dd HH:mm:ss.fff}, Local: {localNow:yyyy-MM-dd HH:mm:ss.fff}");
            
            var message = new ChatMessage
            {
                SessionId = request.SessionId,
                Content = request.Content,
                IsFromUser = request.IsFromUser,
                SentAt = utcNow,
                ProductRecommendations = request.RecommendedProductIds?.Any() == true 
                    ? JsonSerializer.Serialize(request.RecommendedProductIds)
                    : null
            };

            await _messageRepository.AddAsync(message);

            // Update session's UpdatedAt
            session.UpdatedAt = DateTime.UtcNow;
            await _sessionRepository.UpdateAsync(session);
            
            // ✅ THÊM SAVE CHANGES ĐỂ PERSIST VÀO DATABASE
            await _context.SaveChangesAsync();

            var messageDto = _mapper.Map<ChatMessageDto>(message);
            messageDto.RecommendedProductIds = request.RecommendedProductIds;
            
            Console.WriteLine($"🛍️ DEBUG SaveMessageAsync - ProductRecommendations saved to DB: {message.ProductRecommendations}");
            Console.WriteLine($"🛍️ DEBUG SaveMessageAsync - RecommendedProductIds in DTO: {string.Join(", ", messageDto.RecommendedProductIds ?? new List<Guid>())}");

            return messageDto;
        }

        public async Task<bool> DeactivateSessionAsync(Guid sessionId)
        {
            return await _sessionRepository.DeactivateSessionAsync(sessionId);
        }

        public async Task<bool> DeleteSessionAsync(Guid sessionId)
        {
            return await _sessionRepository.DeleteSessionAsync(sessionId);
        }

        public async Task<ChatSessionDto?> GetActiveSessionAsync(int userId)
        {
            var session = await _sessionRepository.GetActiveSessionByUserAsync(userId);
            if (session == null) return null;

            var sessionDto = _mapper.Map<ChatSessionDto>(session);
            sessionDto.MessageCount = session.Messages?.Count ?? 0;
            
            var lastMessage = session.Messages?.OrderByDescending(m => m.SentAt).FirstOrDefault();
            if (lastMessage != null)
            {
                sessionDto.LastMessage = lastMessage.Content.Length > 50 
                    ? lastMessage.Content.Substring(0, 50) + "..." 
                    : lastMessage.Content;
                sessionDto.LastMessageTime = DateTime.SpecifyKind(lastMessage.SentAt, DateTimeKind.Utc);
            }

            return sessionDto;
        }
    }
} 