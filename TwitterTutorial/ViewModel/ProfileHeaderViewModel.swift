//
//  ProfileHeaderViewModel.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/31.
//

import Foundation
import UIKit

enum ProfileFilterOptions: Int,CaseIterable {
    case tweets = 0
    case replies
    case likes
    
    var description: String{
        switch self {
        case .tweets: return "Tweets"
        case .replies : return "Tweets & Replies"
        case .likes : return "Likes"
        }
    }
    
}

struct ProfileHeaderViewModel {
    
    private let user : User
    
    let usernameText: String
    
    var followerText: NSAttributedString? {
        return attributedText(withValue: user.stats?.followers ?? 0, text: "followers")
    }
    
    var followingText: NSAttributedString? {
        return attributedText(withValue: user.stats?.following ?? 0, text: "following")
    }
    
    var actionButtonTitle : String {
        if user.isCurrentUser {
            return "Edit Profile"
        }else if !user.isFollowed{
            return "Follow"
        }else {
            return "Following"
        }
        
    }
    
    init(user:User) {
        self.user = user
        self.usernameText = "@\(user.username)"
    }
    
    func attributedText(withValue value:Int,text:String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)",
                                                        attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : UIColor.systemGray]))
        
        return attributedTitle
    }
}
