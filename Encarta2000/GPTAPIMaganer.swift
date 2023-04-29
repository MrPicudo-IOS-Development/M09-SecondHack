/* GPTAPIMaganer.swift --> Encarta2000. Created by Miguel Torres on 29/04/23. */

// Importamos las bibliotecas necesarias para trabajar con Foundation y Combine
import Foundation
import Combine

// Definimos una clase GPTAPIManager para manejar las solicitudes a la API de GPT
class GPTAPIManager {
    // Declaramos la clave API y la URL de la API de GPT como constantes privadas
    private let apiKey = "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"
    private let gptURL = "https://api.openai.com/v1/chat/completions"
    
    // Definimos una función sendRequest que toma una cadena de texto como entrada y devuelve un Publisher
    func sendRequest(prompt: String) -> AnyPublisher<String, Error> {
        // Verificamos que la URL sea válida
        guard let url = URL(string: gptURL) else {
            fatalError("Invalid URL")
        }
        
        // Creamos una solicitud HTTP POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Definimos el cuerpo de la solicitud como un diccionario y lo convertimos a datos JSON
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "Estás hablando con un asistente de inteligencia artificial. ¿En qué puedo ayudarte hoy?"],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": NSNumber(value: 150)
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            fatalError("Error encoding JSON")
        }
        
        // Usamos URLSession para enviar la solicitud y manejar la respuesta usando Combine
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                // Verificamos que la respuesta sea válida y tenga un código de estado 200
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                if httpResponse.statusCode != 200 {
                    print("Status Code: \(httpResponse.statusCode)")
                    print("Response: \(String(data: data, encoding: .utf8) ?? "No data")")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            // Decodificamos la respuesta JSON en una instancia de GPTAPIResponse
            .decode(type: GPTAPIResponse.self, decoder: JSONDecoder())
            // Extraemos el contenido del mensaje de la primera opción en la respuesta
            .map { $0.choices[0].message.content }
            // Nos aseguramos de recibir la respuesta en el hilo principal
            .receive(on: DispatchQueue.main)
            // Convertimos el resultado en un Publisher genérico
            .eraseToAnyPublisher()
    }
}

// Definimos las estructuras necesarias para decodificar la respuesta JSON
struct GPTAPIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        let index: Int
        let logprobs: JSONNull?
        let finish_reason: String
        
        // Definimos una estructura anidada Message para almacenar la información del mensaje
        struct Message: Codable {
            let role: String
            let content: String
        }
    }
}

// Definimos una estructura JSONNull para manejar valores nulos en la respuesta JSON
struct JSONNull: Codable {
    init(from decoder: Decoder) throws {}
    func encode(to encoder: Encoder) throws {}
}

