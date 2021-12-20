//
//  MessagesView.swift
//  ChatApp
//
//  Created by Omer Kırsever on 20.12.2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatUser {

    let uid, username ,email, profileImageURL: String
}

class MessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init(){
        fetchCurrentUser()
    }
    private func fetchCurrentUser(){
        
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
                self.errorMessage = "123"
                
                guard let data = snapshot?.data() else{
                    self.errorMessage = "No data found"
                    return
                    
                }
                //print(data)
                //self.errorMessage = "Data: \(data.description)"
                
                let uid = data["uid"] as? String ?? ""
                let username = data["username"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let profileImageUrl = data["profileImageUrl"] as? String ?? ""
                self.chatUser = ChatUser(uid: uid, username: username, email: email, profileImageURL: profileImageUrl)
            }
    }
}



struct MessagesView: View {
    @State var shouldShowLogOutOptions = false
    
    @ObservedObject private var vm = MessagesViewModel()
    
    var body: some View {
        NavigationView{
            
            VStack{
                //Text("Current user id \(vm.errorMessage)")
                customNavBar
                .padding(.horizontal)
                .actionSheet(isPresented: $shouldShowLogOutOptions) {
                    .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [.destructive(Text("Sign Out"), action: {
                        print("handle sign out")
                    }),.cancel()])
                }
                messageView
                    .overlay(newMessageView,alignment: .bottom)
                    .navigationBarHidden(true)
                
               
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
                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label),lineWidth: 2))
                .shadow(radius: 5)
            
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
                    .foregroundColor(.black)
            }
            
        }
    }
    private var messageView: some View{
        ScrollView{
            ForEach(0..<10, id: \.self) { num in
                
                HStack(spacing:16){
                    Image(systemName: "person.fill")
                        .font(.system(size: 32))
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label),lineWidth: 1))
                    VStack(alignment:.leading){
                        Text("Username")
                            .fontWeight(.bold)
                            .font(.caption)
                        Text("Message")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("22m")
                        .fontWeight(.semibold)
                        .font(.system(size: 14))
                }
                Divider()
                
            }.padding(.horizontal)
            
            
            
        }
    }
    private var newMessageView: some View{
        Button(action: {}) {
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
   }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
            
            
    }
}
