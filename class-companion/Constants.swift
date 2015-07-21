//
//  FirebaseConstants.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/16/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import Foundation

// SANDBOX URL
//let firebaseRef = Firebase(url: "https://shining-fire-7845.firebaseIO.com")

// LIVE URL
let firebaseRef = Firebase(url: "https://mysticalcabbage2.firebaseio.com/")

let firebaseTeacherRootRef = firebaseRef.childByAppendingPath("teachers/")
let firebaseClassRootRef = firebaseRef.childByAppendingPath("classes/")

// User Default Variables
let userDefaults = NSUserDefaults.standardUserDefaults()
let usernameKeyConstant = "usernameKey"
let userIsAuthenticatedConstant = "userLoggedIn"
let currentUserIdKey = "currentUserIdKey"
let currentClassIdKey = "currentClassIdKey"
let currentStudentNameKey = "currentStudentNameKey"
let currentStudentIdKey = "currentStudentIdKey"
let currentClassNameKey = "currentClassNameKey"

var currentUserId: String? {
  get { return userDefaults.stringForKey(currentUserIdKey) }
  set { userDefaults.setObject(newValue, forKey: currentUserIdKey)
  }
}

var currentClassId: String? {
  get { return userDefaults.stringForKey(currentClassIdKey) }
  set { userDefaults.setObject(newValue, forKey: currentClassIdKey)}
}

var currentClassName: String? {
get { return userDefaults.stringForKey(currentClassNameKey) }
set { userDefaults.setObject(newValue, forKey: currentClassNameKey)}
}

var currentStudentName: String? {
  get { return userDefaults.stringForKey(currentStudentNameKey) }
  set { userDefaults.setObject(newValue, forKey: currentStudentNameKey)}
}

var currentStudentId: String? {
  get { return userDefaults.stringForKey(currentStudentIdKey) }
  set { userDefaults.setObject(newValue, forKey: currentStudentIdKey)}
}