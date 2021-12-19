//
//  SignInView.swift
//  ChatApp
//
//  Created by Omer Kırsever on 19.12.2021.
//

import SwiftUI

struct SignInView: View {

    @State var isLoginMode = false
    @State var eMail = ""
    @State var password = ""
    
    var body: some View {
        
        NavigationView{
            VStack{
                ScrollView{
                    
                    Picker(selection:$isLoginMode,label: Text("picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    if isLoginMode == false {
                        
                        Button(action: {}) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.black)
                                .padding()
                        }
                        
                    }
                    
                    Group {
                        TextField("Email", text: $eMail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(10)
                   
                    HStack{
                        Button(action: {}) {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical,10)
                            Spacer()
                        }
                        .background(Color.blue)
                        .cornerRadius(15)
                    }.padding()
                }
            }
            .padding()
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
        
      
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
