//
//  User.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/26.
//

import Foundation
import Firebase

struct User {
    var fullname : String
    let email : String
    var username : String
    var profileimageURL : URL?
    let uid : String
    var isFollowed = false
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid }
    var stats: UserRelationStats?
    var bio: String?
    
    init(uid:String, dictionary:[String:AnyObject]) {
        self.uid = uid
        
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        
        if let bio = dictionary["bio"] as? String {
            self.bio = bio
        }
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrlString) else { return }
            self.profileimageURL = url
        }
        
    }
}

struct UserRelationStats {
    var followers:Int
    var following:Int
}
