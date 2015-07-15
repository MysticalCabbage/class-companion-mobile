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
  var description: String {
    return "The class name is \(className)"
  }
}

func addNewTeacherClass(newClass: TeacherClass) {
  allTeacherClasses.append(newClass)
  println(allTeacherClasses)
}

func emptyAllTeacherClasses() {
  allTeacherClasses.removeAll()
}