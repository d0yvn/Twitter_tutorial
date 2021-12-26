//
//  UserServices.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/26.
//

import Foundation
import Firebase

struct UserService {
    static let shared = UserService()
    
    func fetchUser(completion:@escaping(User) -> Void){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("DEBUG : current User = \(uid)")
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
            
        }
        
        
    }
    

}
