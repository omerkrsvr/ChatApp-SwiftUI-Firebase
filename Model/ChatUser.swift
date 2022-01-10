//
//  ChatUser.swift
//  ChatApp
//
//  Created by Omer Kırsever on 20.12.2021.
//
import FirebaseFirestoreSwift

struct ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    let uid, email, profileImageUrl: String
}
