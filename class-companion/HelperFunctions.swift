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