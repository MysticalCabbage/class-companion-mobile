//
//  teacherStudentAttendanceTableViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/20/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class teacherStudentAttendanceTableViewController: TeacherStudentsTableViewController {

  var allPresent = false
  
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
    self.title = "\(currentClassName!) Attendance"
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = self.tableView.dequeueReusableCellWithIdentifier("teacherStudentAttendanceCell") as! UITableViewCell
    
    let row = indexPath.row
    
    cell.textLabel?.text = allTeacherStudents[row].studentTitle
    cell.detailTextLabel?.text = String(allTeacherStudents[row].attendanceStatus)
    
    
    return cell
  }
  


  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let row = indexPath.row
    let selectedStudent = allTeacherStudents[row]
    
  }
  
  func assignAttendanceToAllStudents() {

    for student in allTeacherStudents {
      
      assignAttendanceToOneStudent(student)
      
    }
    
  }
  
  func assignAttendanceToOneStudent(student: TeacherStudent) {

    let currentDate = getCurrentDateInString()

    let firebaseClassStudentAttendanceRef =
    firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("students/")
      .childByAppendingPath(student.studentId)
      .childByAppendingPath("attendance/")
      .childByAppendingPath(currentDate)
    
    firebaseClassStudentAttendanceRef.setValue("Absent")

  }
  
 
  
}
