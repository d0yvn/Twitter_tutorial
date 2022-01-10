//
//  NotificationServices.swift
//  TwitterTutorial
//
//  Created by doyun on 2022/01/06.
//

import Foundation
import Firebase

struct NotificationServices {
    static let shared = NotificationServices()
    
    func uploadNotification(toUser user:User,type: NotificationType,tweetID:String? = nil) {
        
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var values : [String:Any] = ["timestamp":Int(NSDate().timeIntervalSince1970),"uid":uid,"type":type.rawValue]
        
        if let tweetID = tweetID {
            values["tweetID"] = tweetID
        }
        REF_NOTIFICATIONS.child(user.uid).childByAutoId().updateChildValues(values)
    }
    
    fileprivate func getNotifications(uid:String,completion:@escaping([Notification])->Void) {
        var notifications = [Notification]()

        REF_NOTIFICATIONS.child(uid).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String:AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let notification = Notification(user: user, dictionary: dictionary)
                notifications.append(notification)
                completion(notifications)
            }
        }
    }
    func fetchNotifications(completion:@escaping([Notification]) -> Void) {
        let notifications = [Notification]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_NOTIFICATIONS.child(uid).observeSingleEvent(of: .value) { snaphot in
            if !snaphot.exists() {
                completion(notifications)
            }else {
                self.getNotifications(uid: uid, completion: completion)
            }
        }
    }
}
