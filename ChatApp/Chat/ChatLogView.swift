//
//  ChatLogView.swift
//  ChatApp
//
//  Created by Omer Kırsever on 29.12.2021.
//

import SwiftUI
import Firebase

struct ChatMessage: Identifiable {
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text: String
    
    init(documentId: String, data:[String:Any]){
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
        
    }
}

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    var chatUser: ChatUser?
    
    init(chatUser:ChatUser?){
        self.chatUser = chatUser
    
        fetchMessages()
    }

    var firestoreListener: ListenerRegistration?
   
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid
        else{ return }
        
        guard let toId = chatUser?.uid
        else{ return }
        
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { quarySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for message: \(error)"
                    print(error)
                    return
                }
                
                quarySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                    }
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }
                
            }
    }
    
    func handleSend() {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid
        else{return}
        
        guard let toId = chatUser?.uid
        else{return}
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId: fromId,FirebaseConstants.toId: toId, FirebaseConstants.text :self.chatText,"timestamp":Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message to FireStore : \(error)"
                return
            }
            
            print("succesfuly saved current user sending message")
            
            self.persistRecentMessage()
            
            self.chatText = ""
            self.count += 1
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message to FireStore : \(error)"
                return
            }
            print("recipient saved message as well")
        }
        
    }
    
    private func persistRecentMessage() {
        guard let chatUser = chatUser else { return }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)
        
        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email
        ] as [String : Any]
        
        // you'll need to save another very similar dictionary for the recipient of this message...how?
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        guard let otherUser = FirebaseManager.shared.otherUser else { return }
        let recipientRecentMessageDictionary = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: otherUser.profileImageUrl,
            FirebaseConstants.email: otherUser.email
        ] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(otherUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }
    
    @Published var count = 0
}

struct ChatLogView:View {
//
//    let chatUser : ChatUser?
//
//    init(chatUser:ChatUser?){
//        self.chatUser = chatUser
//        self.vm = .init(chatUser:chatUser)
//
//    }
    

    @ObservedObject var vm: ChatLogViewModel
    
    
    var body: some View {
        ZStack{
            messagesView
            Text(vm.errorMessage)
        }
        .navigationTitle(vm.chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            vm.firestoreListener?.remove()
        }
    }
    
    static let emptyScrollToString = "Empty"
    
    private var messagesView: some View{
        VStack{
            if #available(iOS 15.0, *) {
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        VStack {
                            ForEach(vm.chatMessages) { message in
                                MessageView(message: message)
                            }

                            HStack{ Spacer() }
                            .id(Self.emptyScrollToString)
                        }
                        .onReceive(vm.$count) { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                            }
                        }
                    }
                }
                .background(Color(.init(white: 0.95, alpha: 1)))
                .safeAreaInset(edge: .bottom) {
                    chatBottomBar
                        .background(Color(.systemBackground).ignoresSafeArea())
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private var chatBottomBar: some View{
        HStack(spacing:16){
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack{
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height:40)
              
           //TextField("Description", text: $chatText)
            
            
            Button {
                
                vm.handleSend()
                
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical,8)
            .background(Color.blue)
            .cornerRadius(4)

        }
        .padding(.horizontal)
        .padding(.vertical,8)
        
    }
    
    struct MessageView: View {
        
        let message: ChatMessage
        
        var body: some View{
        VStack{
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid{
                HStack{
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(8)
                }
            }
            else{
                HStack{
                    HStack {
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    Spacer()

                }
            }
        }
        .padding(.horizontal)
        .padding(.top,8)
    }
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
