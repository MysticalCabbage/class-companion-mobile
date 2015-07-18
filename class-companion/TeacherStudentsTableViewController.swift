//
//  TeacherStudentsTableViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/17/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class TeacherStudentsTableViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.

    
    // Deletes all classes currently in the array
    emptyAllTeacherStudentsLocally()
    
    setupDeleteListener()
    
    getAllStudentsFromServer()
    
  }
  
//   func didReceiveMemoryWarning() {
//    super.didReceiveMemoryWarning()
//    // Dispose of any resources that can be recreated.
//  }

  
  @IBAction func addNewTeacherStudentAlert(sender: UIBarButtonItem) {
    var alertController:UIAlertController?
    
    alertController = UIAlertController(title: "Add Class",
      message: "Enter the class name below",
      preferredStyle: .Alert)
    
    alertController!.addTextFieldWithConfigurationHandler(
      {(textField: UITextField!) in
        textField.placeholder = "Class Name"
        textField.autocapitalizationType = UITextAutocapitalizationType.Words
    })
    
    let submitAction = UIAlertAction(
      title: "Submit",
      style: UIAlertActionStyle.Default,
      handler: {[weak self]
        (paramAction:UIAlertAction!) in
        if let textFields = alertController?.textFields{
          let theTextFields = textFields as! [UITextField]
          let enteredText = theTextFields[0].text
          let newstudentName = enteredText
          self!.sendStudentToServer(newstudentName)
          self!.tableView.reloadData()
          
        }
      })
    
    let cancelAction = UIAlertAction(
      title: "Cancel",
      style: UIAlertActionStyle.Cancel,
      handler: nil
    )
    
    alertController?.addAction(cancelAction)
    alertController?.addAction(submitAction)
    
    self.presentViewController(alertController!,
      animated: true,
      completion: nil)
  }
  
  
  // MARK: - Add / Delete Class Alerts
  // ADD CLASS ALERT
  @IBAction func addNewTeacherStudentAlert2(sender: AnyObject) {
    var alertController:UIAlertController?
    
    alertController = UIAlertController(title: "Add Student",
      message: "Enter the student name below",
      preferredStyle: .Alert)
    
    alertController!.addTextFieldWithConfigurationHandler(
      {(textField: UITextField!) in
        textField.placeholder = "Student Name"
        textField.autocapitalizationType = UITextAutocapitalizationType.Words
    })
    
    let submitAction = UIAlertAction(
      title: "Submit",
      style: UIAlertActionStyle.Default,
      handler: {[weak self]
        (paramAction:UIAlertAction!) in
        if let textFields = alertController?.textFields{
          let theTextFields = textFields as! [UITextField]
          let enteredText = theTextFields[0].text
          let newstudentName = enteredText
          self!.sendStudentToServer(newstudentName)
          self!.tableView.reloadData()
          
        }
      })
    
    let cancelAction = UIAlertAction(
      title: "Cancel",
      style: UIAlertActionStyle.Cancel,
      handler: nil
    )
    
    alertController?.addAction(cancelAction)
    alertController?.addAction(submitAction)
    
    self.presentViewController(alertController!,
      animated: true,
      completion: nil)
    
    
  }
  
  let classCellIdentifier = "TeacherStudentCell"
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allTeacherStudents.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("teacherStudentCell") as! UITableViewCell
    
    let row = indexPath.row
    
    cell.textLabel?.text = allTeacherStudents[row].studentTitle
    
    return cell
  }
  
  // FOR TESTING  adds a point to a student's behavior
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let row = indexPath.row
    let selectedStudent = allTeacherStudents[row]
//    let selectedCellStudentId = selectedCell.studentId
    
    addBehaviorPoints(selectedStudent)
    
//    performSegueWithIdentifier("showTeacherStudentsView", sender: nil)
    
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.Delete) {
      let row = Int(indexPath.row)
      let studentToDelete = allTeacherStudents[row]
      
      showDeleteConfirmationAlert(studentToDelete)
      
    }
  }
  
  func removeStudent(studentNameToRemove: String, row: Int) {
    allTeacherStudents.removeAtIndex(row)
    self.tableView.reloadData()
  }
  
  
  func showDeleteConfirmationAlert(studentToDelete: TeacherStudent){
    
    let studentName = studentToDelete.studentTitle
    
    
    var deleteConfirmationAlert = UIAlertController(title: "Delete Student", message: "Are you sure you want to delete the \"\(studentName)\" student? All data will be lost!!", preferredStyle: UIAlertControllerStyle.Alert)
    
    deleteConfirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
    
    
    let deleteAction = UIAlertAction(
      title: "Delete \(studentName) student",
      style: UIAlertActionStyle.Default,
      handler: { (action: UIAlertAction!) -> Void in
        self.deleteStudentFromServer(studentToDelete)
      }
    )
    
    deleteConfirmationAlert.addAction(deleteAction)
    
    
    
    presentViewController(deleteConfirmationAlert, animated: true, completion: nil)
    
  }
  
  // MARK: - Firebase Add Points
  func addBehaviorPoints(selectedStudent: TeacherStudent) {
    
    let studentId = selectedStudent.studentId
    
    let firebaseStudentBehaviorRef =
      firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("students/")
      .childByAppendingPath(studentId)
      .childByAppendingPath("behavior/")
    
    firebaseStudentBehaviorRef.runTransactionBlock({
      (currentData:FMutableData!) in
      
      if let behaviorValue = currentData.value as? Int {
        currentData.value = behaviorValue + 1
      } else {
        currentData.value = 1
      }

      return FTransactionResult.successWithValue(currentData)
    })
    
  }
  
  // MARK: - Firebase Class Retrieval
  
  func getAllStudentsFromServer() {
    let firebaseClassStudentRef =
    firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("students/")
    
    firebaseClassStudentRef.observeEventType(.Value, withBlock: { snapshot in
      for studentFromServer in snapshot.children.allObjects as! [FDataSnapshot] {
//        println("STUDENT FROM SERVER IS \(studentFromServer)")
        let newTeacherStudent = TeacherStudent(snap: studentFromServer)
        addNewTeacherStudent(newTeacherStudent)
//        println(allTeacherStudents)
      }
      // after adding the new classes to the classes array, reload the table
      self.tableView.reloadData()
      
      }, withCancelBlock: { error in
        println(error.description)
    })
    
  }
  
  
  // MARK: - Firebase Class Sending
  
  func sendStudentToServer(studentName: String) {
    
    if let currentUserId = userDefaults.stringForKey(currentUserIdKey) {
      

      // prepare data to send to teacher section of database
      
      let firebaseClassStudentRef = 
        firebaseClassRootRef
        .childByAppendingPath(currentClassId)
        .childByAppendingPath("students/")
        .childByAutoId()
      
      let studentInfoForClassRoot =
      [
        "studentTitle": studentName,
        "behavior": "0"
      ]
      
      // add the class to the teacher section
      firebaseClassStudentRef.setValue(studentInfoForClassRoot)
      
    }
    else {
      println("ERROR: trying to send class to server without userID in user defaults")
    }
    
  }
  
  // MARK: - Firebase Class Deleting
  
  
  func deleteStudentFromServer(studentToDelete: TeacherStudent) {
    let studentId = studentToDelete.studentId
    let firebaseDeleteStudentRef =
      firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("students/")
      .childByAppendingPath(studentId)
    
    firebaseDeleteStudentRef.removeValue()

    
  }

  
  // MARK: - Firebase Listeners
  
  func setupDeleteListener() {

    let firebaseClassStudentRef =
      firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("students/")
    
    firebaseClassStudentRef.observeEventType(.ChildRemoved, withBlock: { snapshot in
      emptyAllTeacherStudentsLocally()
      self.getAllStudentsFromServer()
    })
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */

}
