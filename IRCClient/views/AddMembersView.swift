import SwiftUI

struct AddMembersView: View {
    @State private var userIDsString: String = ""
    @State private var isAdding: Bool = false
    @State private var showSuccess: Bool = false
    @State private var errorMessage: String?
    
    let chat: Chat
    private let chatService = ServiceFactory.makeChatService()
    @Environment(\.dismiss) private var dismiss
    
    init(chat: Chat) {
        self.chat = chat
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Enter user IDs (comma separated)", text: $userIDsString)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300)
                    .padding()
                
                Button {
                    addUsersToChat()
                } label: {
                    HStack {
                        if isAdding {
                            ProgressView()
                                .controlSize(.small)
                                .padding(.trailing, 5)
                        }
                        Text("Add Users")
                    }
                    .frame(width: 150)
                }
                .buttonStyle(.borderedProminent)
                .disabled(userIDsString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAdding)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Members")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isAdding)
                }
            }
            .frame(width: 400, height: 250)
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Users have been added to the chat")
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }
    
    private func addUsersToChat() {
        let userIDs = userIDsString
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard !userIDs.isEmpty else { return }
        
        isAdding = true
        
        chatService.addMembers(chatId: chat.id, userIds: userIDs) { [self] result in
            DispatchQueue.main.async {
                isAdding = false
                
                switch result {
                case .success():
                    userIDsString = ""
                    showSuccess = true
                    print("Members added successfully")
                    
                case .failure(let error):
                    errorMessage = "Failed to add members: \(error.localizedDescription)"
                    print("Failed to add members: \(error)")
                }
            }
        }
    }
}
