//
//  ChatUser.swift
//  ChatApp
//
//  Created by Omer Kırsever on 20.12.2021.
//

import Foundation

struct ChatUser {

    let uid, username ,email, profileImageURL: String
    
    init(data:[String:Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageURL = data["profileImageUrl"] as? String ?? ""
    }
}
