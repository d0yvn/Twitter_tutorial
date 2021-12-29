//
//  Constants.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/23.
//

import Foundation
import Firebase

//Storage
let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")

//Database
let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_TWEETS = DB_REF.child("tweets")
