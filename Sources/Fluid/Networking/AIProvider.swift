import Foundation

protocol AIProvider
{
    func process(systemPrompt: String, userText: String, model: String, apiKey: String, baseURL: String) async -> String
}

final class OpenAICompatibleProvider: AIProvider
{
    struct ChatMessage: Codable { let role: String; let content: String }
    struct ChatRequest: Codable { let model: String; let messages: [ChatMessage] }
    struct ChatChoiceMessage: Codable { let role: String; let content: String }
    struct ChatChoice: Codable { let index: Int?; let message: ChatChoiceMessage }
    struct ChatResponse: Codable { let choices: [ChatChoice] }

    func process(systemPrompt: String, userText: String, model: String, apiKey: String, baseURL: String) async -> String
    {
        let endpoint = baseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "https://api.openai.com/v1" : baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: endpoint + "/chat/completions") else { return "Error: Invalid Base URL" }

        let body = ChatRequest(
            model: model,
            messages: [
                ChatMessage(role: "system", content: systemPrompt),
                ChatMessage(role: "user", content: userText)
            ]
        )

        guard let jsonData = try? JSONEncoder().encode(body) else { return "Error: Failed to encode request" }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        do
        {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode >= 400
            {
                let errText = String(data: data, encoding: .utf8) ?? "Unknown error"
                return "Error: HTTP \(http.statusCode): \(errText)"
            }
            let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
            return decoded.choices.first?.message.content ?? "<no content>"
        }
        catch
        {
            return "Error: \(error.localizedDescription)"
        }
    }
}


