//
//  BehaviorsModel.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/18/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import Foundation

var allBehaviors = [Behavior]()

class Behavior: Printable {
  var behaviorTitle: String
  var behaviorValue: Int
  
  var description: String {
    return "The behavior name is \(behaviorTitle) and value is \(behaviorValue)"
  }
  // initialize the instance with the json data from the snapshot
  init(key: String, behaviorValue: Int) {
    println("KEY IS \(key) VALUE IS \(behaviorValue)")
    self.behaviorTitle = key
    self.behaviorValue = behaviorValue
  }
  
  // when initializing with the snapshot data
  convenience init(snap: FDataSnapshot) {
        println("IN INIT THE SNAP VALUE IS \(snap.value)")
    if let behaviorValue = snap.value as? Int {
      self.init(key: snap.key, behaviorValue: behaviorValue)
    }
    else {
      fatalError("errored when initializing with snapshot data")
    }
  }
}




func addNewBehavior(newBehavior: Behavior) {
  
  if !behaviorAlreadyExists(allBehaviors, newBehavior) {
    allBehaviors.append(newBehavior)
  }
  
}

func behaviorAlreadyExists (behaviorArray: [Behavior], newBehavior: Behavior) -> Bool {
  for singleBehavior in behaviorArray {
    if singleBehavior.behaviorTitle == newBehavior.behaviorTitle {
      return true
    }
  }
  return false
}

func emptyallBehaviorsLocally() {
  allBehaviors.removeAll()
  
}