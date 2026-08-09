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
                // Koyu Arka Plan
                Color.black.ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .emerald))
                        Text("Metin Yükleniyor...")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.gray)
                    }
                } else if !errorMessage.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 36))
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button(action: {
                            loadKvkkText()
                        }) {
                            Text("Tekrar Dene")
                                .font(.system(.body, design: .rounded))
                                .bold()
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.emerald)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if let attributedString = try? AttributedString(markdown: content, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                                Text(attributedString)
                                    .foregroundColor(.white)
                                    .font(.system(.body, design: .rounded))
                            } else {
                                // AttributedString başarısız olursa düz metin göster
                                Text(content)
                                    .foregroundColor(.white)
                                    .font(.system(.body, design: .rounded))
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
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(.emerald)
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
