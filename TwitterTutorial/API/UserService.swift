//
//  UserServices.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/26.
//

import Foundation
import Firebase

typealias DatabaseCompletion = ((Error?,DatabaseReference) -> Void)

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
    
    func fetchUsers(completion:@escaping([User]) -> Void){
        
        var users = [User]()
        
        REF_USERS.observe(.childAdded) { snapshot in
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String:AnyObject] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            users.append(user)
            completion(users)
        }
    }
    
    func followUser(uid: String,completion:@escaping(DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWINGS.child(currentUid).updateChildValues([uid:1]) { (Error,ref) in
            REF_USER_FOLLOWERS.child(uid).updateChildValues([currentUid: 1],withCompletionBlock: completion)
        }
    }
    
    func unfollowUser(uid: String,completion:@escaping(DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWINGS.child(currentUid).child(uid).removeValue { (err,ref) in
            REF_USER_FOLLOWINGS.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
    }
    
    func checkIfUserIsFollowed(uid:String,completion:@escaping(Bool)->Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWINGS.child(currentUid).child(uid).observeSingleEvent(of: .value) { snapshot in
            print("DEBUG: USer is followed is \(snapshot.exists())")
            completion(snapshot.exists())
        }
    }
    
    func fetchUserStats(uid:String,completion:@escaping(UserRelationStats) -> Void) {
        REF_USER_FOLLOWERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            let followers = snapshot.children.allObjects.count
            
            REF_USER_FOLLOWINGS.child(uid).observeSingleEvent(of: .value) { snapshot in
                let following = snapshot.children.allObjects.count
                
                let stats = UserRelationStats(followers: followers, following: followers)
                completion(stats)
            }
        }
    }
}
