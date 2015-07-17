//
//  TeacherClassesModel.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/14/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import Foundation

var allTeacherClasses = [TeacherClass]()

struct TeacherClass: Printable {
  var className: String
  var classId: String
  var description: String {
    return "The class name is \(className)"
  }
}



func addNewTeacherClass(newClass: TeacherClass) {
  
  if !classAlreadyExists(allTeacherClasses, newClass) {
    allTeacherClasses.append(newClass)
  }

}

func classAlreadyExists (classArray: [TeacherClass], newClass: TeacherClass) -> Bool {
  for singleClass in classArray {
    if singleClass.className == newClass.className {
      return true
    }
  }
  return false
}

func emptyAllTeacherClassesLocally() {
  allTeacherClasses.removeAll()

}
