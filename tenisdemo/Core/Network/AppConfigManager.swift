import Foundation

struct VersionCheckResponse: Decodable {
    let isUpdateRequired: Bool
    let isUpdateAvailable: Bool
    let latestVersion: String
    let minimumRequiredVersion: String
    let appStoreUrl: String?
    let updateMessage: String?
}

@MainActor
class AppConfigManager: ObservableObject {
    static let shared = AppConfigManager()
    
    @Published var isForceUpdateRequired = false
    @Published var isSoftUpdateAvailable = false
    @Published var updateMessage: String = ""
    @Published var appStoreUrl: String = ""
    @Published var hasChecked = false
    
    // Sürüm uyarısının her açılışta tekrar tekrar çıkmasını engellemek için UserDefaults kullanıyoruz
    private let lastDismissedVersionKey = "TennisLastDismissedVersion"
    
    @Published var isSoftUpdateDismissed = false
    private var latestVersion: String = ""
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = URLSessionAPIClient()) {
        self.apiClient = apiClient
    }
    
    /// Uygulama sürümünü backend'e göndererek kontrol eder
    func checkVersion() async {
        guard !hasChecked else { return }
        
        let platform = "ios"
        // Info.plist'ten güncel uygulama versiyonunu çek
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        
        do {
            let response: VersionCheckResponse = try await apiClient.request(
                AppConfigEndpoint.versionCheck(platform: platform, version: currentVersion)
            )
            
            self.isForceUpdateRequired = response.isUpdateRequired
            self.latestVersion = response.latestVersion
            self.updateMessage = response.updateMessage ?? "Uygulamanın yeni bir versiyonu çıktı. Lütfen güncelleyin."
            self.appStoreUrl = response.appStoreUrl ?? "https://apps.apple.com/app/id6446219477"
            
            // Eğer isteğe bağlı güncelleme varsa, kullanıcının bu sürümü daha önce yoksayıp saymadığını kontrol et
            if response.isUpdateAvailable {
                let dismissedVersion = UserDefaults.standard.string(forKey: lastDismissedVersionKey)
                if dismissedVersion == response.latestVersion {
                    self.isSoftUpdateAvailable = false
                    self.isSoftUpdateDismissed = true
                } else {
                    self.isSoftUpdateAvailable = true
                }
            } else {
                self.isSoftUpdateAvailable = false
            }
            
            self.hasChecked = true
        } catch {
            print("Sürüm kontrolü hatası: \(error.localizedDescription)")
            // Bağlantı sorunlarında kullanıcıyı engellememek için sürüm kontrolü yapılmamış gibi devam etmesini sağlıyoruz
            self.hasChecked = true
        }
    }
    
    /// İsteğe bağlı güncellemeyi kapat/ertele
    func dismissSoftUpdate() {
        self.isSoftUpdateAvailable = false
        self.isSoftUpdateDismissed = true
        // Bu sürümü yoksayılanlar listesine ekle
        UserDefaults.standard.set(latestVersion, forKey: lastDismissedVersionKey)
    }
}
