//
//  ChatLogView.swift
//  ChatApp
//
//  Created by Omer Kırsever on 29.12.2021.
//

import SwiftUI



struct ChatLogView:View {
    
    let chatUser : ChatUser?
    
    @State var chatText = ""
    
    var body: some View {

        ZStack{
            messagesView
            VStack{
                Spacer()
                chatBottomBar
                    .background(Color.white)
            }
            
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messagesView: some View{
        ScrollView{
            ForEach(0..<10){ _ in
                
                HStack{
                    Spacer()
                    HStack {
                        Text("FAKE MESSAGE FOR NOW")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top,8)
            }
            HStack { Spacer() }
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        
    }
    
    private var chatBottomBar: some View{
        HStack(spacing:16){
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            
//                TextEditor(text: $chatText)
            TextField("Description", text: $chatText)
            
            
            Button {
                
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
    
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView{
            ChatLogView(chatUser: .init(data: ["uid" : "REAL USER ID" , "email": "deneme@gmail.com"]))
        }
    }
}
