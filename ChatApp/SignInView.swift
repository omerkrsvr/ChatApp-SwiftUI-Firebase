//
//  SignInView.swift
//  ChatApp
//
//  Created by Omer Kırsever on 19.12.2021.
//

import SwiftUI
import Firebase

class FirebaseManager: NSObject {
    
    let auth: Auth
    static let shared = FirebaseManager()
    
    override init(){
        FirebaseApp.configure()
        self.auth = Auth.auth()
        super.init()
    }
}


struct SignInView: View {

    @State var isLoginMode = false
    @State var email = ""
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
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(10)
                   
                    HStack{
                        Button(action: {
                            handleAction()
                        }) {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical,10)
                            Spacer()
                        }
                        .background(Color.blue)
                        .cornerRadius(15)
                    }.padding()
                    
                    VStack(alignment:.center){
                        Text(loginStatusMessage)
                            .foregroundColor(.red)
                    }
                    
                        
                        
                }
            }
            .padding()
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
        
      
    }
    private func handleAction(){
        if isLoginMode{
            logInUser()
            print("login action")
        }else{
            
            createNewUser()
            print("create account action")
        }
    }
     @State var loginStatusMessage = ""
    
    private func createNewUser(){
        //Auth.auth().createUser
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                self.loginStatusMessage = "Failed to create new user.\(err.localizedDescription)"
                return
            }
            self.loginStatusMessage = "Succes new user."
        }
    }
    
    private func logInUser(){
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                self.loginStatusMessage = "\(err.localizedDescription)"
                return
            }
            self.loginStatusMessage = "Succes log in!"
        }
        
    }
    

}


struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
