//
//  HelperFunctions.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/20/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import Foundation

// used for attendance
func getCurrentDateInString() -> String {
  let date = NSDate()
  let dateFormatter:NSDateFormatter = NSDateFormatter()
  dateFormatter.dateFormat = "M-dd-yyyy"
  let currentDate:String = dateFormatter.stringFromDate(date)
  
  return currentDate
  
}

func getRandomIndex(fromArray: [AnyObject]) -> Int {
  let randomIndex = Int(arc4random_uniform(UInt32(fromArray.count)))
  return randomIndex
}


extension Array {
  mutating func shuffle() {
    if count < 2 { return }
    for i in 0..<(count - 1) {
      let j = Int(arc4random_uniform(UInt32(count - i))) + i
      swap(&self[i], &self[j])
    }
  }
}

