//
//  MessagesView.swift
//  ChatApp
//
//  Created by Omer Kırsever on 20.12.2021.
//

import SwiftUI

struct MessagesView: View {
    @State var shouldShowLogOutOptions = false
    var body: some View {
        NavigationView{
            
            VStack{
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
            Image(systemName: "person.fill")
                .font(.system(size: 25))
            VStack(alignment:.leading,spacing: 4){
                Text("Username")
                    .fontWeight(.bold)
                HStack{
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
