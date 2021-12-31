//
//  User.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/26.
//

import Foundation
import Firebase

struct User {
    let fullname : String
    let email : String
    let username : String
    var profileimageURL : URL?
    let uid : String
    
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid }
    
    init(uid:String, dictionary:[String:AnyObject]) {
        self.uid = uid
        
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrlString) else { return }
            self.profileimageURL = url
        }
        
    }
}
