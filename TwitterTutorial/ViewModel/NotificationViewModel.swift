//
//  NotificationViewModel.swift
//  TwitterTutorial
//
//  Created by doyun on 2022/01/06.
//

import Foundation
import UIKit

struct NotificationViewModel {
    private let notification: Notification
    private let type:NotificationType
    private let user: User
    
    var timeStampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second,.hour,.month,.day,.weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        
        let now = Date()
        
        return formatter.string(from: notification.timestamp, to: now) ?? "2m"
    }
    
    var notificationMessage : String {
        switch type {
        case .follow: return " started following you"
        case .reply: return " liked one of your tweets"
        case .like: return " replied to your tweet"
        case .retweet: return " retweeted your tweet"
        case .mention: return " mentioned your tweet"
        }
        
    }
    
    var notificationText : NSAttributedString? {
        guard let timestamp = timeStampString else { return nil }
        let attributedText = NSMutableAttributedString(string: user.username, attributes:[NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationMessage, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: " \(timestamp)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),NSAttributedString.Key.foregroundColor:UIColor.lightGray]))
        return attributedText
    }
    
    var profileImageUrl: URL? {
        return user.profileimageURL
    }
    
    var shouldHideFollowButton:Bool {
        return type != .follow
    }
    
    var followButtonText:String {
        return user.isFollowed ? "Following" : "Follow"
    }
    init(notification:Notification) {
        self.notification = notification
        self.type = notification.type
        self.user = notification.user
        
    }
}
