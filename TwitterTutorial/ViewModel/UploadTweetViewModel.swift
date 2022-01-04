//
//  UploadTweetViewModel.swift
//  TwitterTutorial
//
//  Created by doyun on 2022/01/03.
//

import Foundation


enum UploadTweetConfiguration {
    case tweet
    case reply(Tweet)
}

struct UploadTweetViewModel {
    let actionButtonTitle:String
    let placeholderText:String
    var shoulShowReplyLabel:Bool
    var replyText: String?
    
    init(config: UploadTweetConfiguration){
        switch config {
        case .tweet :
            actionButtonTitle = "Tweet"
            placeholderText = "What's happening?"
            shoulShowReplyLabel = false
        case .reply(let tweet):
            actionButtonTitle = "Reply"
            placeholderText = "Tweet your reply"
            shoulShowReplyLabel = true
            replyText = "Replying to @\(tweet.user.username)"
            
        }
    }
}
