import Foundation

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: AuthUser? = nil
    @Published var isLoading = false
    
    private let apiClient: APIClient
    private let tokenService = "TennisApp"
    private let tokenAccount = "AuthToken"
    private let userKey = "TennisCurrentUser"
    
    private init(apiClient: APIClient = URLSessionAPIClient()) {
        self.apiClient = apiClient
        checkAuthStatus()
    }
    
    // Oturum durumunu Keychain ve UserDefaults üzerinden kontrol eder
    func checkAuthStatus() {
        if let tokenData = KeychainHelper.shared.read(service: tokenService, account: tokenAccount),
           let _ = String(data: tokenData, encoding: .utf8) {
            
            if let userData = UserDefaults.standard.data(forKey: userKey),
               let user = try? JSONDecoder().decode(AuthUser.self, from: userData) {
                self.currentUser = user
                self.isAuthenticated = true
            } else {
                logout()
            }
        } else {
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
    
    // Giriş yapma fonksiyonu
    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await apiClient.request(AuthEndpoint.login(request))
        
        saveAuthSession(response)
    }
    
    // Kayıt olma fonksiyonu
    func register(email: String, password: String, fullName: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let request = RegisterRequest(email: email, password: password, fullName: fullName)
        let response: AuthResponse = try await apiClient.request(AuthEndpoint.register(request))
        
        saveAuthSession(response)
    }
    
    // Çıkış yapma fonksiyonu
    func logout() {
        KeychainHelper.shared.delete(service: tokenService, account: tokenAccount)
        UserDefaults.standard.removeObject(forKey: userKey)
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
    // Oturum verilerini kaydeder
    private func saveAuthSession(_ response: AuthResponse) {
        if let tokenData = response.token.data(using: .utf8) {
            KeychainHelper.shared.save(tokenData, service: tokenService, account: tokenAccount)
        }
        
        if let userData = try? JSONEncoder().encode(response.user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
        
        self.currentUser = response.user
        self.isAuthenticated = true
    }
}
