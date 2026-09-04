import SwiftUI

struct LegalView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var content: String = ""
    @State private var isLoading = true
    @State private var errorMessage = ""
    
    private let apiClient: APIClient = URLSessionAPIClient()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.zinc950.ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .zinc400))
                        Text("Metin Yükleniyor...")
                            .font(.system(size: 13))
                            .foregroundColor(.zinc400)
                    }
                } else if !errorMessage.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 32))
                            .foregroundColor(.statusRed)
                        
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.zinc400)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button(action: {
                            loadKvkkText()
                        }) {
                            Text("Tekrar Dene")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.zinc950)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.zinc50)
                                .cornerRadius(6)
                        }
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if let attributedString = try? AttributedString(markdown: content, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                                Text(attributedString)
                                    .foregroundColor(.zinc200)
                                    .font(.system(size: 13))
                            } else {
                                Text(content)
                                    .foregroundColor(.zinc200)
                                    .font(.system(size: 13))
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("KVKK Aydınlatma Metni")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Kapat")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.zinc200)
                    }
                }
            }
            .onAppear {
                loadKvkkText()
            }
        }
    }
    
    private func loadKvkkText() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let response: LegalResponse = try await apiClient.request(LegalEndpoint.getKvkk)
                self.content = response.content
                self.isLoading = false
            } catch {
                self.errorMessage = "Yasal metin yüklenirken bir hata oluştu. Lütfen bağlantınızı kontrol edin."
                self.isLoading = false
            }
        }
    }
}

struct LegalResponse: Decodable {
    let content: String
}
