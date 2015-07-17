//
//  TeacherClassesModel.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/14/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import Foundation

var allTeacherClasses = [TeacherClass]()

class TeacherClass: Printable {
  var classTitle: String
  var classId: String
  var teacherId: String
  var description: String {
    return "The class name is \(classTitle)"
  }
  
  init(json: Dictionary<String, AnyObject>) {
    self.classTitle = json["classTitle"] as? String ?? "classNameMissing"
    self.classId = json["classId"] as? String ?? "classIdMissing"
    self.teacherId = json["teacherId"] as? String ?? "TeacherIdMissing"
  }
  
  convenience init(snap: FDataSnapshot) {
    println("IN INIT THE SNAP VALUE IS \(snap.value)")
    if let json = snap.value as? Dictionary<String, AnyObject> {
      self.init(json: json)
    }
    else {
      fatalError("errored when initializing with snapshot data")
    }
  }
}



func addNewTeacherClass(newClass: TeacherClass) {
  
  if !classAlreadyExists(allTeacherClasses, newClass) {
    allTeacherClasses.append(newClass)
  }

}

func classAlreadyExists (classArray: [TeacherClass], newClass: TeacherClass) -> Bool {
  for singleClass in classArray {
    if singleClass.classTitle == newClass.classTitle {
      return true
    }
  }
  return false
}

func emptyAllTeacherClassesLocally() {
  allTeacherClasses.removeAll()

}

//func createNewTeacherClass(className: String, classId: String, teacherId: String) -> TeacherClass {
//  let newTeacherClass = TeacherClass(className: className, classId: classId, teacherId: currentUserId!)
//  return newTeacherClass
//}