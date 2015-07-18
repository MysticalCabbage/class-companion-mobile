//
//  BehaviorsModel.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/18/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import Foundation

var allBehaviors = [Behaviors]()

class Behaviors: Printable {
  var behaviorTitle: String
  var behaviorId: String
  var behaviorValue: String
  
  var description: String {
    return "The behavior name is \(behaviorTitle) and value is \(behaviorValue)"
  }
  // initialize the instance with the json data from the snapshot
  init(key: String, json: Dictionary<String, AnyObject>) {
    self.behaviorTitle = json["behaviorTitle"] as? String ?? "behaviorTitleMissing"
    self.behaviorId = key
    self.behaviorValue = json["behaviorValue"] as? String ?? "behaviorValueMissing"
  }
  
  // when initializing with the snapshot data
  convenience init(snap: FDataSnapshot) {
    //    println("IN INIT THE SNAP VALUE IS \(snap.value)")
    if let json = snap.value as? Dictionary<String, AnyObject> {
      self.init(key: snap.key, json: json)
    }
    else {
      fatalError("errored when initializing with snapshot data")
    }
  }
}




func addNewBehavior(newBehavior: Behaviors) {
  
  if !behaviorAlreadyExists(allBehaviors, newBehavior) {
    allBehaviors.append(newBehavior)
  }
  
}

func behaviorAlreadyExists (behaviorArray: [Behaviors], newBehavior: Behaviors) -> Bool {
  for singleBehavior in behaviorArray {
    if singleBehavior.behaviorId == newBehavior.behaviorId {
      return true
    }
  }
  return false
}

func emptyallBehaviorsLocally() {
  allBehaviors.removeAll()
  
}