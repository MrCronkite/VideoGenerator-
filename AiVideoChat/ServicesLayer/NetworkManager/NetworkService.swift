//
//  NetworkService.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 18.06.2026.
//

import UIKit


enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case emptyData
    case encodingFailed(Error)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный URL запроса"
        case .invalidResponse:
            return "Некорректный ответ сервера"
        case .serverError(let code):
            return "Ошибка сервера: \(code)"
        case .emptyData:
            return "Сервер вернул пустые данные"
        case .encodingFailed(let error):
            return "Ошибка кодирования запроса: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Ошибка декодирования ответа: \(error.localizedDescription)"
        }
    }
}


protocol NetworkServiceProtocol {

    func sendMessage(text: String, chatId: String) async throws -> SendMessageResponse
    func getMessages(chatID: String) async throws -> [Messages]
    func getChats() async throws -> [ChatInfo]
    func getTemplates() async throws -> TemplatesResponse
    func createVideo(params: VideoParams) async throws -> VideoId
    func getVideoStatus(id: Int) async throws -> VideoStatusResponse
}


final class NetworkService: NetworkServiceProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder

    @BearerToken private var authorizationHeader = NetworkConstants.Auth.token

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = .init()
    ) {
        self.session = session
        self.decoder = decoder
    }

    // MARK: — Public

    func sendMessage(text: String, chatId: String) async throws -> SendMessageResponse {
        try await performRequest(
            buildSendMessageRequest(chatId: chatId, text: text)
        )
    }

    func getMessages(chatID: String) async throws -> [Messages] {
        try await performRequest(
            buildGetMessagesRequest(chatId: chatID)
        )
    }

    func getChats() async throws -> [ChatInfo] {
        try await performRequest(
            buildGetChatsRequest()
        )
    }

    func getTemplates() async throws -> TemplatesResponse {
        try await performRequest(
            buildGetTemplatesRequest()
        )
    }

    func createVideo(params: VideoParams) async throws -> VideoId {
        try await performRequest(
            buildCreateVideoRequest(params: params)
        )
    }

    func getVideoStatus(id: Int) async throws -> VideoStatusResponse {
        try await performRequest(
            buildGetVideoStatusRequest(id: id)
        )
    }
}


// MARK: — Request Execution
extension NetworkService {

    func performRequest<T: Decodable>(
            _ request: URLRequest,
            as type: T.Type = T.self
        ) async throws -> T {

            let (data, response) = try await session.data(for: request)

            try validate(response: response)
            try validate(data: data)

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        }

    // MARK: — Validation

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    private func validate(data: Data) throws {
        guard !data.isEmpty else {
            throw NetworkError.emptyData
        }
    }
}

// MARK: — Shared Request Builders
private extension NetworkService {

    func defaultQueryItems() -> [URLQueryItem] {
        [
            URLQueryItem(
                name: R.Network.QueryKeys.userId,
                value: R.Network.AppInfo.defaultUserId
            ),
            URLQueryItem(
                name: R.Network.QueryKeys.appId,
                value: R.Network.AppInfo.appId
            )
        ]
    }

    func makeURL(
        path: String,
        queryItems: [URLQueryItem] = []
    ) throws -> URL {
        guard var components = URLComponents(
            string: "\(NetworkConstants.API.baseURL)\(path)"
        ) else {
            throw NetworkError.invalidURL
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        return url
    }

    func makeRequest(
        url: URL,
        method: String,
        contentType: String? = nil,
        accept: String = NetworkConstants.Headers.applicationJSON
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method

        request.setValue(
            accept,
            forHTTPHeaderField: "Accept"
        )
        request.setValue(
            authorizationHeader,
            forHTTPHeaderField: NetworkConstants.Headers.authorization
        )

        if let contentType {
            request.setValue(
                contentType,
                forHTTPHeaderField: NetworkConstants.Headers.contentType
            )
        }

        return request
    }
}

// MARK: — Endpoint Builders
private extension NetworkService {

    func buildGetVideoStatusRequest(id: Int) throws -> URLRequest {
        let url = try makeURL(
            path: "/pixverse/api/v1/status",
            queryItems: [URLQueryItem(name: "id", value: "\(id)")] + defaultQueryItems()
        )
        return makeRequest(url: url, method: "GET")
    }

    func buildCreateVideoRequest(params: VideoParams) throws -> URLRequest {
        let url = try makeURL(
            path: "/pixverse/api/v1/template2video",
            queryItems: defaultQueryItems()
        )

        guard let imageData = params.image.jpegData(compressionQuality: 0.7) else {
            throw NetworkError.encodingFailed(NSError(domain: "ImageConversion", code: -1))
        }

        var form = MultipartFormDataBuilder()
        form.addField(name: "template_id", value: "\(params.templateID)")
        form.addFile(name: "image", filename: "image.jpg", mimeType: "image/jpeg", data: imageData)
        form.addField(name: "duration", value: "10")
        form.addField(name: "quality", value: "\(params.quality)")
        form.addField(name: "format", value: "\(params.format)")

        var request = makeRequest(url: url, method: "POST", contentType: form.contentTypeHeader)
        request.httpBody = form.build()
        return request
    }

    func buildGetTemplatesRequest() throws -> URLRequest {
        let url = try makeURL(path: "/pixverse/api/v1/get_templates/\(R.Network.AppInfo.appId)")
        return makeRequest(url: url, method: "GET")
    }

    func buildGetChatsRequest() throws -> URLRequest {
        let url = try makeURL(
            path: NetworkConstants.API.path,
            queryItems: [URLQueryItem(name: "offset", value: "0")] + defaultQueryItems()
        )
        return makeRequest(url: url, method: "GET")
    }

    func buildGetMessagesRequest(chatId: String) throws -> URLRequest {
        @NonEmpty var safeChatId = chatId
        guard !safeChatId.isEmpty else {
            throw NetworkError.invalidURL
        }

        let url = try makeURL(
            path: "\(NetworkConstants.API.path)/\(safeChatId)/messages",
            queryItems: [URLQueryItem(name: "offset", value: "0")] + defaultQueryItems()
        )
        return makeRequest(url: url, method: "GET")
    }

    func buildSendMessageRequest(chatId: String, text: String) throws -> URLRequest {
        @NonEmpty var safeChatId = chatId
        @NonEmpty var safeMessage = text

        guard !safeChatId.isEmpty, !safeMessage.isEmpty else {
            throw NetworkError.invalidURL
        }

        let url = try makeURL(
            path: "\(NetworkConstants.API.path)/\(safeChatId)/messages",
            queryItems: defaultQueryItems()
        )

        var request = makeRequest(
            url: url,
            method: "POST",
            contentType: NetworkConstants.Headers.applicationJSON
        )

        let body = SendMessageRequestBody(message: safeMessage)

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw NetworkError.encodingFailed(error)
        }

        return request
    }
}



