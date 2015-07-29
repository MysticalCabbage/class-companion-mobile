//
//  teacherStudentAttendanceTableViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/20/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class teacherStudentAttendanceTableViewController: TeacherStudentsTableViewController {

  var toggleAttendanceStatus = true
  
  @IBOutlet weak var attendanceTableView: UITableView!
  
    override func viewDidLoad() {
      
        attendanceTableView.delegate = self
        attendanceTableView.dataSource = self
      
        super.viewDidLoad()
      
      self.extendedLayoutIncludesOpaqueBars = true;

    }
  
  @IBAction func toggleStudentAttendanceButton(sender: UIBarButtonItem) {
    assignAttendanceToAllStudents()
  }
  override func setUpNavBarTitle() {
//    self.navigationItem.title = "\(currentClassName!) Attendance"
    self.navigationItem.title = "\(currentClassName!)"

  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = self.tableView.dequeueReusableCellWithIdentifier("teacherStudentAttendanceCell") as! UITableViewCell
    
    let row = indexPath.row
    
//    println("TRYING TO GET attendance STUDENT AT ROW \(row)")

    let studentTitle = allTeacherStudents[row].studentTitle
    let attendanceStatus = allTeacherStudents[row].attendanceStatus
    
    cell.textLabel?.text = allTeacherStudents[row].studentTitle
    cell.detailTextLabel?.text = attendanceStatus
    
    if attendanceStatus == "Present" {
      cell.detailTextLabel?.textColor = UIColor.greenColor()
    } else if attendanceStatus == "Late" {
      cell.detailTextLabel?.textColor = UIColor.orangeColor()
    } else if attendanceStatus == "Absent" {
      cell.detailTextLabel?.textColor = UIColor.redColor()
    }
    
    
    return cell
  }
  

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {    
    let row = indexPath.row
    if row > allTeacherStudents.count {
      return
    }
    let selectedStudent = allTeacherStudents[row]
    
    assignAttendanceToOneStudent(selectedStudent, togglingAllStudents: false, cameFromServer: false)
    
  }
  
  func assignAttendanceToAllStudents() {
    
    removeAllFirebaseListeners()

    for student in allTeacherStudents {
      
      assignAttendanceToOneStudent(student, togglingAllStudents: true, cameFromServer: false)
      
    }
    
    toggleAttendanceStatus = !toggleAttendanceStatus
    setupFirebaseListeners()
    getAllStudentsFromServer()
    

  }
  
  func assignAttendanceToOneStudent(student: TeacherStudent, togglingAllStudents: Bool, cameFromServer: Bool) {
    
    let newAttendanceStatus = getNewAttendanceStatus(student, togglingAllStudents: togglingAllStudents)

    let currentDate = getCurrentDateInString()

    let firebaseClassStudentAttendanceRef =
    firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("students/")
      .childByAppendingPath(student.studentId)
      .childByAppendingPath("attendance/")
      .childByAppendingPath(currentDate)
    
    if (!cameFromServer) {
      firebaseClassStudentAttendanceRef.setValue(newAttendanceStatus)
    }
    
  }
  
  func getNewAttendanceStatus(student: TeacherStudent, togglingAllStudents: Bool) -> String {
    if togglingAllStudents {
      if toggleAttendanceStatus {
        return "Absent"
      } else {
        return "Present"
      }
    } else {
      if student.attendanceStatus == "Present" {
        return "Absent"
      } else if student.attendanceStatus == "Absent" {
        return "Late"
      } else {
        return "Present"
      }
    }
  }
  
 
  
}
