//
//  CreateNewMessageView.swift
//  ChatApp
//
//  Created by Omer Kırsever on 20.12.2021.
//

import SwiftUI
import SDWebImageSwiftUI

class CreateNewMessageViewModel: ObservableObject {

    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers(){
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments {documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users:\(error)"
                    print("Failed to fetch users:\(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({snapshot in
                    let user = try? snapshot.data(as: ChatUser.self)
                    if user?.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(user!)
                    }
                })
               // self.errorMessage = "Fetched user succesfuly"
            }
    }
}

struct CreateNewMessageView: View {
    
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView{
            ScrollView{
                
                Text(vm.errorMessage)
                
                ForEach(vm.users){user in
                    Button {
                        
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                        
                    } label: {
                        HStack(spacing:12){
                            
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60,height: 60)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label),lineWidth: 1))
                            Text(user.email)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    Divider()
                }
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button{
                        presentationMode.wrappedValue.dismiss()
                    }label: {
                        Text("Cancel")
                    }
                }
            }
            
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        //CreateNewMessageView(didSelectNewUser: {})
        MessagesView()
    }
}
