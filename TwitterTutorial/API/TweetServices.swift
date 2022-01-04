//
//  TweetServices.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/28.
//

import Foundation
import Firebase
struct TweetService {
    static let shared = TweetService()
    
    // tweet upload : 작성한 유저, 시간, 좋아요, 리트윗, 글 내용 => Value에 저장
    func updateTweet(caption:String,type: UploadTweetConfiguration,completion: @escaping DatabaseCompletion) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["uid":uid,
                      "timestamp":Int(NSDate().timeIntervalSince1970),
                      "likes":0,
                      "retweets":0,
                      "caption":caption] as [String:Any]
        switch type {
        case .tweet:
            // Tweet DB에 저장
            // 자동으로 unique id를 생성하고 거기에 value 업데이트
            REF_TWEETS.childByAutoId().updateChildValues(values) { (err,ref) in
                // update user-tweet structure after tweet upload completes
                guard let tweetID = ref.key else { return }
                REF_USER_TWEETS.child(uid).updateChildValues([tweetID : 1],withCompletionBlock: completion)
            }
        case .reply(let tweet) :
            REF_TWEET_REPLIES.child(tweet.tweetID).childByAutoId()
                .updateChildValues(values,withCompletionBlock: completion)
        }
    }
    
    // tweet 피드 업로드
    func fetchTweets(completion :@escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        // tweet DB에서 정보 조회.
        REF_TWEETS.observe(.childAdded) { snapshot in
            
            //tweet 정보 획득
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            
            // uid 정보로 유저 정보 조회
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    //
    func fetchTweets(forUser user: User, completion:@escaping([Tweet])-> Void) {
        var tweets = [Tweet]()
        
        REF_USER_TWEETS.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            REF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String:Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        
    }
    
    func fetchReplies(forTweet tweet:Tweet,completion:@escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        REF_TWEET_REPLIES.child(tweet.tweetID).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String:AnyObject] else { return }
            
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }

    func likeTweet(tweet:Tweet,completion:@escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        REF_TWEETS.child(tweet.tweetID).child("likes").setValue(likes)
        
        if tweet.didLike {
            // unlike tweet
            REF_USER_LIKES.child(uid).child(tweet.tweetID).removeValue { (err,ref) in
                REF_TWEET_LIKES.child(tweet.tweetID).removeValue(completionBlock: completion)
            }
        } else {
            // like tweet
            REF_USER_LIKES.child(uid).updateChildValues([tweet.tweetID:1]) { (err,ref) in
                REF_TWEET_LIKES.child(tweet.tweetID).updateChildValues([uid:1],withCompletionBlock: completion)
            }
        }
        
    }
    
    func checkIfUserLikedTweet(_ tweet: Tweet,completion:@escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_LIKES.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
}
