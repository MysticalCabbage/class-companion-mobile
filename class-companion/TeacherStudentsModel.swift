//
//  TeacherStudentsModel.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/17/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import Foundation

var allTeacherStudents = [TeacherStudent]()

class TeacherStudent: Printable {
  var studentTitle: String
  var studentId: String
  var behaviorTotal: Int
  var attendanceStatus: String
  var currentlySelected: Bool
  var groupNumber: Int?
  var description: String {
    return "The student name is \(studentTitle)"
  }
  // initialize the instance with the json data from the snapshot
  init(key: String, json: Dictionary<String, AnyObject>) {
    let currentDate = getCurrentDateInString()
    
    self.studentTitle = json["studentTitle"] as? String ?? "studentTitleMissing"
    self.studentId = key
    self.behaviorTotal = json["behaviorTotal"] as? Int ?? 0
    
    // if there is an attendance section for that student in the database
    if let tempAttendance: AnyObject = json["attendance"] as AnyObject? {
      // use the value for the current date, or by default set it to "Present"
      self.attendanceStatus = tempAttendance[currentDate] as? String ?? "Present"
    } else {
      // if there is no attendance section for that student, 
      self.attendanceStatus = "Present"
    }
    self.currentlySelected = false
    // TODO:
    self.groupNumber = 1
  }
  
  // when initializing with the snapshot data
  convenience init(snap: FDataSnapshot) {
    if let json = snap.value as? Dictionary<String, AnyObject> {
      self.init(key: snap.key, json: json)
    }
    else {
      fatalError("errored when initializing with snapshot data")
    }
  }
}



func addNewTeacherStudent(newStudent: TeacherStudent) {
  
  if !studentAlreadyExists(allTeacherStudents, newStudent) {
    allTeacherStudents.append(newStudent)
  }
  
}

func studentAlreadyExists (studentsArray: [TeacherStudent], newStudent: TeacherStudent) -> Bool {
  for singleStudent in studentsArray {
    if singleStudent.studentId == newStudent.studentId {
      return true
    }
  }
  return false
}

func emptyAllTeacherStudentsLocally() {
  allTeacherStudents.removeAll()
  
}

func assignStudentModelToGroup(studentId: String, groupNumber: Int) {
  if let studentToGroupIndex = getIndexByStudentId(studentId) {
    allTeacherStudents[studentToGroupIndex].groupNumber = groupNumber
  } else {
    println("ERROR: Trying to group a student that doesn't exist")
  }
  
  
}

func sortTeacherStudentsByGroupNumber () {
  allTeacherStudents.sort({$0.groupNumber < $1.groupNumber})
}

