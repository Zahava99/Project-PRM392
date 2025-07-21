using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Cosmetics.Service.Gemini
{
    public class GeminiChatService
    {
        private readonly HttpClient _httpClient;
        private readonly string _apiKey;

        public GeminiChatService(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _apiKey = configuration["GeminiApi:ApiKey"];
            _httpClient.BaseAddress = new Uri("https://generativelanguage.googleapis.com/");
        }

        public async Task<string> GetChatResponse(string userMessage)
        {
            var requestData = new
            {
                contents = new[]
                {
                    new
                    {
                        parts = new[]
                        {
                            new { text = userMessage }
                        }
                    }
                },
                generationConfig = new
                {
                    temperature = 0.7,
                    maxOutputTokens = 1024
                }
            };

            var jsonContent = JsonSerializer.Serialize(requestData);
            var content = new StringContent(jsonContent, System.Text.Encoding.UTF8, "application/json");

            var url = $"v1beta/models/gemini-2.0-flash:generateContent?key={_apiKey}";
            var response = await _httpClient.PostAsync(url, content);

            if (!response.IsSuccessStatusCode)
            {
                var errorContent = await response.Content.ReadAsStringAsync();

                if (response.StatusCode == System.Net.HttpStatusCode.TooManyRequests)
                {
                    Console.WriteLine("Quota exceeded. Waiting before retry...");
                    await Task.Delay(30000); // Đợi 30 giây
                    response = await _httpClient.PostAsync(url, content);
                    if (!response.IsSuccessStatusCode)
                    {
                        errorContent = await response.Content.ReadAsStringAsync();
                        return $"Error: {response.StatusCode} - {errorContent}";
                    }
                }
                else
                {
                    return $"Error: {response.StatusCode} - {errorContent}";
                }
            }

            var responseContent = await response.Content.ReadAsStringAsync();
            Console.WriteLine("Raw Response: " + responseContent);

            var jsonResponse = JsonSerializer.Deserialize<JsonResponse>(responseContent);

            if (jsonResponse?.Error != null)
            {
                return $"API Error: {jsonResponse.Error.Message}";
            }

            if (jsonResponse?.Candidates == null || jsonResponse.Candidates.Length == 0)
            {
                return "No candidates found in response. Raw response: " + responseContent;
            }

            return jsonResponse.Candidates[0]?.Content?.Parts[0]?.Text ?? "No response";
        }

        public async Task<string> GetImageAnalysisResponse(string userMessage, string base64Image)
        {
            try
            {
                var requestData = new
                {
                    contents = new[]
                    {
                        new
                        {
                            parts = new object[]
                            {
                                new { text = userMessage },
                                new { 
                                    inline_data = new {
                                        mime_type = DetermineImageMimeType(base64Image),
                                        data = base64Image
                                    }
                                }
                            }
                        }
                    },
                    generationConfig = new
                    {
                        temperature = 0.7,
                        maxOutputTokens = 1024
                    }
                };

                var jsonContent = JsonSerializer.Serialize(requestData);
                var content = new StringContent(jsonContent, System.Text.Encoding.UTF8, "application/json");

                var url = $"v1beta/models/gemini-2.0-flash:generateContent?key={_apiKey}";
                var response = await _httpClient.PostAsync(url, content);

                if (!response.IsSuccessStatusCode)
                {
                    var errorContent = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"Gemini API Error: {response.StatusCode} - {errorContent}");

                    if (response.StatusCode == System.Net.HttpStatusCode.TooManyRequests)
                    {
                        Console.WriteLine("Quota exceeded. Waiting before retry...");
                        await Task.Delay(30000); // Đợi 30 giây
                        response = await _httpClient.PostAsync(url, content);
                        if (!response.IsSuccessStatusCode)
                        {
                            errorContent = await response.Content.ReadAsStringAsync();
                            return $"Error: {response.StatusCode} - {errorContent}";
                        }
                    }
                    else
                    {
                        return $"Error: {response.StatusCode} - {errorContent}";
                    }
                }

                var responseContent = await response.Content.ReadAsStringAsync();
                Console.WriteLine("Raw Image Analysis Response: " + responseContent);

                var jsonResponse = JsonSerializer.Deserialize<JsonResponse>(responseContent);

                if (jsonResponse?.Error != null)
                {
                    return $"API Error: {jsonResponse.Error.Message}";
                }

                if (jsonResponse?.Candidates == null || jsonResponse.Candidates.Length == 0)
                {
                    return "No candidates found in response. Raw response: " + responseContent;
                }

                return jsonResponse.Candidates[0]?.Content?.Parts[0]?.Text ?? "No response";
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception in GetImageAnalysisResponse: {ex.Message}");
                return $"Xin lỗi, có lỗi xảy ra khi phân tích ảnh: {ex.Message}";
            }
        }

        private string DetermineImageMimeType(string base64Image)
        {
            if (string.IsNullOrEmpty(base64Image))
                return "image/jpeg";

            try
            {
                // Decode the first few bytes to check the magic number
                var bytes = Convert.FromBase64String(base64Image.Substring(0, Math.Min(base64Image.Length, 100)));
                
                // Check for PNG magic number (89 50 4E 47)
                if (bytes.Length >= 4 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47)
                    return "image/png";
                
                // Check for JPEG magic number (FF D8 FF)
                if (bytes.Length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF)
                    return "image/jpeg";
                
                // Check for WebP magic number (52 49 46 46)
                if (bytes.Length >= 4 && bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46)
                    return "image/webp";
                
                // Default to JPEG
                return "image/jpeg";
            }
            catch
            {
                // Default to JPEG if detection fails
                return "image/jpeg";
            }
        }
    }

    internal class JsonResponse
    {
        [JsonPropertyName("candidates")]
        public Candidate[] Candidates { get; set; }

        [JsonPropertyName("error")]
        public GeminiError? Error { get; set; }

        public class Candidate
        {
            [JsonPropertyName("content")]
            public Content Content { get; set; }
        }

        public class Content
        {
            [JsonPropertyName("parts")]
            public Part[] Parts { get; set; }

            [JsonPropertyName("role")]
            public string Role { get; set; }
        }

        public class Part
        {
            [JsonPropertyName("text")]
            public string Text { get; set; }
        }

        public class GeminiError
        {
            [JsonPropertyName("code")]
            public int Code { get; set; }

            [JsonPropertyName("message")]
            public string Message { get; set; }

            [JsonPropertyName("status")]
            public string Status { get; set; }
        }
    }
}
