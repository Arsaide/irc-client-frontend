import SwiftUI

struct InviteUsersView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: InviteUsersViewModel
    
    init(chat: Chat) {
        _viewModel = StateObject(wrappedValue: InviteUsersViewModel(chat: chat))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.isLoading {
                        ProgressView("Загрузка...")
                            .padding(.top, 50)
                    } else if viewModel.users.isEmpty {
                        ContentUnavailableView(
                            "Никого нет",
                            systemImage: "person.slash",
                            description: Text("Нет доступных пользователей для приглашения")
                        )
                        .padding(.top, 50)
                    } else {
                        ForEach(viewModel.users) { user in
                            userRow(user)
                            Divider()
                        }
                    }
                }
            }
            .navigationTitle("Invite Users")
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add (\(viewModel.selectedUserIds.count))") {
                        viewModel.inviteSelectedUsers { success in
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.selectedUserIds.isEmpty || viewModel.isLoading)
                    .fontWeight(.bold)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onAppear {
                viewModel.loadUsers()
            }
        }
    }
    
    private func userRow(_ user: UserListItem) -> some View {
        Button {
            viewModel.toggleUser(user.id)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(user.email)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                let isSelected = viewModel.selectedUserIds.contains(user.id)
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? .blue : .gray.opacity(0.5))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .background(Color.clear)
        }
        .buttonStyle(.plain)
    }
}
