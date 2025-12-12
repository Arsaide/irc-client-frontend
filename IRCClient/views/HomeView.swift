import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedChatId: String?
    
    @ObservedObject private var socketManager = SocketManagerWrapper.shared
    
    var onLogout: () -> Void
    
    var body: some View {
        NavigationSplitView {
            sidebarView
        } detail: {
            detailContent
        }
        .overlay(alignment: .bottomTrailing) {
            socketStatusView
        }
        .sheet(isPresented: $viewModel.showCreateChatSheet) {
            Text("Create Chat View Stub")
        }
        .sheet(isPresented: $viewModel.showInviteSheet) {
            if let chat = viewModel.selectedChatForInvite {
                Text("Invite View Stub for \(chat.title ?? "")")
            }
        }
        .alert("Error", isPresented: $viewModel.hasError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .onAppear {
            viewModel.loadData()
            SocketManagerWrapper.shared.connect()
        }
    }
    
    private var sidebarView: some View {
        List(selection: $selectedChatId) {
            Section {
                if viewModel.chats.isEmpty && !viewModel.isLoading {
                    emptyStateView
                }
                
                ForEach(viewModel.chats) { chat in
                    chatRow(for: chat)
                }
            } header: {
                sidebarHeader
            }
        }
        .navigationTitle(viewModel.currentUser?.name ?? "Loading...")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                menuButton
            }
        }
        .refreshable {
            viewModel.loadData()
        }
    }
    
    @ViewBuilder
    private var detailContent: some View {
        if let chatId = selectedChatId,
           let selectedChat = viewModel.chats.first(where: { $0.id == chatId }),
           let user = viewModel.currentUser {
            
            ChatDetailView(chat: selectedChat, myUserId: user.id)
                .id(selectedChat.id)
            
        } else {
            ContentUnavailableView(
                "Select a Channel",
                systemImage: "bubble.left.and.bubble.right",
                description: Text("Choose a channel from the sidebar to start chatting")
            )
        }
    }
    
    private func chatRow(for chat: Chat) -> some View {
        NavigationLink(value: chat.id) {
            HStack {
                Image(systemName: "number")
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(chat.title ?? "Unknown")
                        .font(.headline)
                    
                    if let ircName = chat.ircChannelName {
                        Text(ircName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .contextMenu {
            Button {
            } label: {
                Label("Invite Users", systemImage: "person.badge.plus")
            }
        }
    }
    
    private var sidebarHeader: some View {
        HStack {
            Text("Channels")
            Spacer()
            Button {
            } label: {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.medium)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var menuButton: some View {
        Menu {
            Button {
            } label: {
                Label("New Chat", systemImage: "plus.bubble")
            }
            
            Divider()
            
            Button {
                viewModel.loadData()
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            
            Divider()
            
            Button(role: .destructive, action: onLogout) {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Chats Yet",
            systemImage: "bubble.left.and.bubble.right",
            description: Text("Create your first chat to get started")
        )
    }
    
    private var socketStatusView: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(socketManager.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
        }
        .padding(8)
        .background(.thinMaterial)
        .cornerRadius(20)
        .padding()
    }
}
