//
//  APIError.swift
//  tenisdemo
//
//  Created by Antigravity on 22.07.2026.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingFailed(Error)
    case custom(message: String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL adresi."
        case .requestFailed(let error):
            return "Ağ isteği başarısız oldu: \(error.localizedDescription)"
        case .invalidResponse:
            return "Sunucudan geçersiz bir yanıt alındı."
        case .serverError(let statusCode):
            return "Sunucu hatası. Durum kodu: \(statusCode)"
        case .decodingFailed(let error):
            return "Veri ayrıştırılamadı: \(error.localizedDescription)"
        case .custom(let message):
            return message
        case .unknown:
            return "Bilinmeyen bir ağ hatası oluştu."
        }
    }
}
