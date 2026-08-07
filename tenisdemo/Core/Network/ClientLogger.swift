import Foundation
import UIKit

class ClientLogger {
    static let shared = ClientLogger()
    
    private var baseURL: URL {
        return AppEnvironment.current.loggingBaseURL
    }
    
    private init() {}
    
    func info(_ message: String) {
        sendLog(level: "info", message: message)
    }
    
    func warn(_ message: String) {
        sendLog(level: "warn", message: message)
    }
    
    func error(_ message: String) {
        sendLog(level: "error", message: message)
    }
    
    private func sendLog(level: String, message: String) {
        print("[\(level.uppercased())] \(message)")
        
        let source = "iOS"
        let deviceModel = UIDevice.current.model
        let osVersion = UIDevice.current.systemVersion
        
        let payload: [String: String] = [
            "level": level,
            "message": message,
            "source": source,
            "device_model": deviceModel,
            "os_version": osVersion
        ]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: payload) else { return }
        
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        if let tokenData = KeychainHelper.shared.read(service: "TennisApp", account: "AuthToken"),
           let tokenString = String(data: tokenData, encoding: .utf8) {
            request.setValue("Bearer \(tokenString)", forHTTPHeaderField: "Authorization")
        }
        
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse {
                    if !(200...299).contains(httpResponse.statusCode) {
                        print("DEBUG ClientLogger: Failed to send log, status code: \(httpResponse.statusCode)")
                    }
                }
            } catch {
                print("DEBUG ClientLogger: Failed to send log, error: \(error.localizedDescription)")
            }
        }
    }
}
