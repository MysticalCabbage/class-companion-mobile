//
//  teacherStudentAttendanceTableViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/20/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class teacherStudentAttendanceTableViewController: TeacherStudentsTableViewController {

  @IBOutlet weak var attendanceTableView: UITableView!
  
    override func viewDidLoad() {
      
        attendanceTableView.delegate = self
        attendanceTableView.dataSource = self
//      self.tableView = attendanceTableView
      
        super.viewDidLoad()
      
      self.extendedLayoutIncludesOpaqueBars = true;
      

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
  
  override func setUpNavBarTitle() {
    self.title = "\(currentClassName!) Attendance"
  }
  /*
  override func setUpRightBarButton() {
//    var addStudentButton : UIBarButtonItem = UIBarButtonItem(title: "Toggle", style: UIBarButtonItemStyle.Plain, target: self, action: "assignAttendanceToAllStudents")
    
//    self.navigationItem.rightBarButtonItem = addStudentButton
//    self.tabBarController!.navigationItem.rightBarButtonItem = addStudentButton
    
  }
*/

  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = self.tableView.dequeueReusableCellWithIdentifier("teacherStudentAttendanceCell") as! UITableViewCell
    
    let row = indexPath.row
    
    cell.textLabel?.text = allTeacherStudents[row].studentTitle
    cell.detailTextLabel?.text = String(allTeacherStudents[row].behaviorTotal)
    
    
    return cell
  }
  


  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let row = indexPath.row
    let selectedStudent = allTeacherStudents[row]
    //    let selectedCellStudentId = selectedCell.studentId
    
    //    addBehaviorPoints(selectedStudent)
    
    currentStudentName = selectedStudent.studentTitle
    currentStudentId = selectedStudent.studentId
    
    performSegueWithIdentifier("showStudentBehaviorList", sender: nil)
    
  }
  
  func assignAttendanceToAllStudents() {

    let currentDate = getCurrentDateInString()
    
    for student in allTeacherStudents {
      
    }
    
    
    println(currentDate)
  }
  
  func getCurrentDateInString() -> String {
    let date = NSDate()
    let dateFormatter:NSDateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "M-dd-yyyy"
    let currentDate:String = dateFormatter.stringFromDate(date)
    
    return currentDate
    
  }
  
}
