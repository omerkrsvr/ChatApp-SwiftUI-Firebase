//
//  SignInView.swift
//  ChatApp
//
//  Created by Omer Kırsever on 19.12.2021.
//

import SwiftUI
import Firebase



struct SignInView: View {

    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var shouldShowImagePicker = false
    @State private var image: UIImage?
    @State private var loginStatusMessage = ""

    let didCompleteLoginProcess: () -> ()
    
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
                        
                        Button(action: {
                            
                            shouldShowImagePicker.toggle()
                            
                        }) {
                            VStack{
                                if let image = image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                }else{
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .foregroundColor(.black)
                                        .padding()
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.black,lineWidth: 3))
                        }
                    }
                    
                    Group {
                        if isLoginMode == false{
                            TextField("Name",text:$username)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
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
                        .background(Color.orange)
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
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
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
     
    
    private func createNewUser(){
        
        if self.image == nil{
            self.loginStatusMessage = "You must select a profile image."
            return
        }
        
        //Auth.auth().createUser
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                self.loginStatusMessage = "Failed to create new user.\(err.localizedDescription)"
                return
            }
            self.loginStatusMessage = "Succes new user."
            
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage(){
        
        //let fileName = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
            else{ return }
        //Storage.storage.referance
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5)
            else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err{
                self.loginStatusMessage = "Failed to push image to storage : \(err.localizedDescription)"
                return
            }
            ref.downloadURL { url, err in
                if let err = err{
                    self.loginStatusMessage = "Failed to retriece downloadURL : \(err.localizedDescription)"
                    return
                }
                self.loginStatusMessage = "Succes stored image."
                
                guard let url = url else{return}
                self.storedUserInformation(imageProfileUrl: url)
            }
        }
        
    }
    
    private func storedUserInformation(imageProfileUrl: URL){
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
              else{ return }
        let userData = ["email": self.email,"username":self.username ,"uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err{
                    print(err)
                    self.loginStatusMessage = "\(err.localizedDescription)"
                    return
                }
                print("succes")
                
                self.didCompleteLoginProcess()
            }
        
    }
    
    private func logInUser(){
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                self.loginStatusMessage = "\(err.localizedDescription)"
                return
            }
            self.loginStatusMessage = "Succes log in!"
            
            self.didCompleteLoginProcess()
        }
    }
}


struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(didCompleteLoginProcess: {})
    }
}
