//
//  FirebaseConstants.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/16/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import Foundation

let firebaseRef = Firebase(url: "https://shining-fire-7845.firebaseIO.com")

let firebaseTeacherRootRef = firebaseRef.childByAppendingPath("teachers/")
let firebaseClassRootRef = firebaseRef.childByAppendingPath("classes/")


let userDefaults = NSUserDefaults.standardUserDefaults()
let usernameKeyConstant = "usernameKey"
let userIsAuthenticatedConstant = "userLoggedIn"
// used for accessing and retrieving the current user's ID
let currentUserIdKey = "currentUserIdKey"

var currentUserId: String? {
  get { return userDefaults.stringForKey(currentUserIdKey) }
  set { userDefaults.setObject(newValue, forKey: currentUserIdKey)
  }
}
