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
    
    // uid를 통해 유저 정보 조회
    func fetchUser(uid: String, completion:@escaping(User) -> Void){
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
        
    }
    

}
