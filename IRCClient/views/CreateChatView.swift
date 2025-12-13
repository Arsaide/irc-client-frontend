import SwiftUI

struct CreateChatView: View {
    @State private var chatTitle: String = ""
    @ObservedObject private var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Enter chat title", text: $chatTitle)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300)
                    .padding()
                
                Button {
                    createChat()
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .controlSize(.small)
                                .padding(.trailing, 5)
                        }
                        Text("Create Chat")
                    }
                    .frame(width: 150)
                }
                .buttonStyle(.borderedProminent)
                .disabled(chatTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Create New Chat")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .frame(width: 400, height: 250)
        }
    }
    
    private func createChat() {
        let title = chatTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        
        viewModel.createChat(title: title)
        chatTitle = ""
        dismiss()
    }
}
