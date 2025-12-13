import SwiftUI

struct ChatDetailView: View {
    @StateObject private var viewModel: ChatDetailViewModel
    @FocusState private var isInputFocused: Bool
    
    private let bottomID = "BOTTOM_ANCHOR"
    
    init(chat: Chat, myUserId: String) {
        _viewModel = StateObject(wrappedValue: ChatDetailViewModel(chat: chat, myUserId: myUserId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            chatHeader
            
            Divider()
            
            ScrollViewReader { proxy in
                messagesScrollView(proxy: proxy)
            }
            
            Divider()
            
            messageInputBar
        }
        .navigationTitle(viewModel.chat.title ?? "Chat")
        .alert("Error", isPresented: $viewModel.hasError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .onAppear {
            viewModel.onAppear()
            isInputFocused = true
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
    
    private var chatHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.chat.title ?? "Unknown")
                    .font(.headline)
                
                if let ircName = viewModel.chat.ircChannelName {
                    Text(ircName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text("\(viewModel.messages.count) messages")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private func messagesScrollView(proxy: ScrollViewProxy) -> some View {
        ScrollView {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.messages.isEmpty {
                ContentUnavailableView(
                    "No Messages",
                    systemImage: "bubble.left",
                    description: Text("Be the first to send a message!")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 0)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            isMy: viewModel.isMyMessage(message)
                        )
                        .id(message.id)
                    }
                }
                .padding()
            }
        }
        .onChange(of: viewModel.messages.count) { oldValue, newValue in
            if newValue > oldValue {
                scrollToLastMessage(proxy: proxy, animated: true)
            }
        }
        .onChange(of: isInputFocused) { _, focused in
            if focused {
                scrollToLastMessage(proxy: proxy, animated: true)
            }
        }
        .onChange(of: viewModel.isLoading) { _, loading in
            if !loading {
                scrollToLastMessage(proxy: proxy, animated: false)
            }
        }
    }
        
    private func scrollToLastMessage(proxy: ScrollViewProxy, animated: Bool) {
        guard let lastId = viewModel.messages.last?.id else { return }
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if animated {
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo(lastId, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
        
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool) {
        DispatchQueue.main.async {
            if animated {
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo(bottomID, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
        }
    }
    
    private var messageInputBar: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $viewModel.newMessageText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(10)
                .background(Color(.textBackgroundColor))
                .cornerRadius(20)
                .focused($isInputFocused)
                .onSubmit {
                    if !viewModel.newMessageText.isEmpty {
                        viewModel.sendMessage()
                    }
                }
            
            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        viewModel.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.gray
                        : Color.blue
                    )
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(viewModel.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private func sendMessage() {
        if !viewModel.newMessageText.isEmpty {
            viewModel.sendMessage()
            isInputFocused = true
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isMy: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isMy { Spacer(minLength: 60) }
            
            VStack(alignment: isMy ? .trailing : .leading, spacing: 4) {
                if !isMy {
                    Text(message.user.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
                
                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isMy ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundStyle(isMy ? .white : .primary)
                    .cornerRadius(18)

                Text(formatDate(message.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if !isMy { Spacer(minLength: 60) }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        return displayFormatter.string(from: date)
    }
}
