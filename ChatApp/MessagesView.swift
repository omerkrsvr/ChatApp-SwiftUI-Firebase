//
//  MessagesView.swift
//  ChatApp
//
//  Created by Omer Kırsever on 20.12.2021.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestoreSwift


class MessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init(){
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
        
        fetchRecentMessages()
        
    }
    
    @Published var recentMessages = [RecentMessage]()
    
    private func fetchRecentMessages(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print("error")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                   
                        let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.id == docId
                    }){
                        self.recentMessages.remove(at: index)
                    }
                    do {
                        if let rm = try? change.document.data(as: RecentMessage.self){
                            self.recentMessages.insert(rm, at: 0)
                        }
                        
                    }catch {
                      print(error)
                    }
                })
                
            }
    }
    func fetchCurrentUser(){
        
        guard let uid  = FirebaseManager.shared.auth.currentUser?.uid
            else {
                self.errorMessage = "Could not find firebase uid"
                return
                
            }
        
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).getDocument { snapshot, error in
                if let error = error{
                    self.errorMessage = "Failed to fetch current user: \(error)"
                    return
                }
                guard let data = snapshot?.data() else{
                    self.errorMessage = "No data found"
                    return
                    
                }
                print(data)
                
                //self.errorMessage = "Data: \(data.description)"
                self.chatUser = .init(data: data)
            }
    }
    
    @Published var isUserCurrentlyLoggedOut = false
    func handleSignOut(){
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}



struct MessagesView: View {
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatLogView = false
    
    @ObservedObject private var vm = MessagesViewModel()
    
    var body: some View {
        NavigationView{
            
            VStack{
                //Text("Current user id \(vm.errorMessage)")
                customNavBar
                Divider()
                messageView
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
            }
        }
    }
    private var customNavBar: some View{
        HStack(spacing:16){
            
            WebImage(url: URL(string: vm.chatUser?.profileImageURL ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 60,height: 60)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label),lineWidth: 1))
                .shadow(radius: 2)
            
            VStack(alignment:.leading,spacing: 4){
                Text(vm.chatUser?.username ?? "username")
                    .fontWeight(.bold)
                HStack(spacing:2){
                    Circle().frame(width: 10, height: 10)
                        .foregroundColor(.green)
                    Text("online")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Button(action: {
                shouldShowLogOutOptions.toggle()
            }) {
                Image(systemName: "gear")
                    .font(.system(size: 24,weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding(.horizontal)
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [.destructive(Text("Sign Out"), action: {
                print("handle sign out")
                vm.handleSignOut()
            }),.cancel()])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            SignInView {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            }
        }
    }
    private var messageView: some View{
        ScrollView{
            ForEach(vm.recentMessages) { recentMessage in
                NavigationLink {
                    Text("Destination")
                } label: {
                    HStack(spacing:16){
                        WebImage(url: URL(string: recentMessage.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipped()
                            .cornerRadius(64)
                            .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label),lineWidth: 1))
                        VStack(alignment:.leading){
                            Text(recentMessage.email)
                                .fontWeight(.bold)
                                .font(.body)
                                .foregroundColor(Color(.label))
                                .multilineTextAlignment(.leading)
                            Text(recentMessage.text)
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        Text(recentMessage.timestamp.description)
                            .fontWeight(.semibold)
                            .font(.system(size: 14))
                            .foregroundColor(Color(.label))
                    }
                }
                Divider()
            }
            .padding(.horizontal)
        }
        .overlay(newMessageButton,alignment: .bottom)
        .navigationBarHidden(true)
    }
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View{
        Button(action: {
            
            shouldShowNewMessageScreen.toggle()
            
        }) {
       HStack{
           Spacer()
           Text("+ New Message")
               .font(.system(size: 16,weight: .bold))
           Spacer()
       }
       .padding(.vertical)
       .background(Color.blue)
       .foregroundColor(.white)
       .cornerRadius(32)
       .padding(.horizontal)
       .shadow(radius: 15)
        }.fullScreenCover(isPresented: $shouldShowNewMessageScreen){
            CreateNewMessageView(didSelectNewUser: {user in
                print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            })
        }
    }
    
    @State var chatUser: ChatUser?
    
}



struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
                   
    }
}
