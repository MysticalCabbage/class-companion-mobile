//
//  ClassesModel.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/14/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import Foundation

var allClasses = [Class]()

struct Class: Printable {
  var className: String
  var description: String {
    return "The class name is \(className)"
  }
}

func addNewClass(newClass: Class) {
  allClasses.append(newClass)
  println(allClasses)
}