//
//  TeacherStudentsTableViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/17/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class TeacherStudentsTableViewController: UITableViewController {
  
  var allFirebaseListenerRefs = [Firebase]()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set up the navigation bar itle
    setUpNavBarTitle()
    
    // set up listeners
    setupReloadDataListener()
    
    setupFirebaseListeners()
    
    // refresh the table
    emptyAllTeacherStudentsLocally()  
    getAllStudentsFromServer()
  }
  
  
  func setUpNavBarTitle() {
    self.navigationItem.title = "\(currentClassName!)"

  }
  
  override func viewWillDisappear(animated: Bool) {
    removeAllFirebaseListeners()
  }
  
  @IBAction func returnToTeacherDashboard(sender: UIBarButtonItem) {
    var next = self.storyboard?.instantiateViewControllerWithIdentifier("TeacherDashboard") as! TeacherDashboardViewController
    
    self.presentViewController(next, animated: true, completion: nil)
    
    
  }

  
  
  // MARK: - Add / Delete Class Alerts
  @IBAction func addNewTeacherStudentAlert(sender: AnyObject) {
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
          NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)

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
  
  // MARK: - Table Logic
  
  let classCellIdentifier = "TeacherStudentCell"
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allTeacherStudents.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = self.tableView.dequeueReusableCellWithIdentifier("teacherStudentCell") as! UITableViewCell
    
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
    NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
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
      .childByAppendingPath("behaviorTotal/")
    
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
  
  // MARK: - Firebase Student Retrieval
  
  func getAllStudentsFromServer() {
    let firebaseClassStudentRef =
      firebaseClassRootRef
        .childByAppendingPath(currentClassId)
        .childByAppendingPath("students/")
    
    addFirebaseReferenceToCollection(firebaseClassStudentRef)
    
    
    firebaseClassStudentRef.observeEventType(.Value, withBlock: { snapshot in
      for studentFromServer in snapshot.children.allObjects as! [FDataSnapshot] {
//        println("STUDENT FROM SERVER IS \(studentFromServer)")
        let newTeacherStudent = TeacherStudent(snap: studentFromServer)
        addNewTeacherStudent(newTeacherStudent)
      }
      // after adding the new classes to the classes array, reload the table
      NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
      
      }, withCancelBlock: { error in
        println(error.description)
    })
    
  }
  
  
  // MARK: - Firebase Send Student
  
  func sendStudentToServer(studentName: String) {
    
    if let currentUserId = userDefaults.stringForKey(currentUserIdKey) {
      
      let currentDate = getCurrentDateInString()

      // prepare data to send to teacher section of database
      
      let firebaseClassStudentRef = 
        firebaseClassRootRef
        .childByAppendingPath(currentClassId)
        .childByAppendingPath("students/")
        .childByAutoId()
      
      let studentKey = firebaseClassStudentRef.key
      
      let firebaseClassStudentBehaviorRef =
        firebaseClassStudentRef
        .childByAppendingPath("behavior/")
      
      let firebaseClassStudentAttendanceRef =
        firebaseClassStudentRef
        .childByAppendingPath("attendance/")
        .childByAppendingPath(currentDate)
      
      let firebaseClassGroupsRef =
      firebaseClassRootRef
        .childByAppendingPath(currentClassId)
        .childByAppendingPath("groups/")
        .childByAppendingPath(studentKey)
      
      let studentInfoForClassRoot =
      [
        "studentTitle": studentName,
        "behaviorTotal": 0,
      ]
      
      var defaultBehaviorAmounts = [String: Int]()
      
      for behaviorName in defaultBehaviors.keys {
        defaultBehaviorAmounts["\(behaviorName)"] = 0
      }
      
      // add the student to the teacher section
      firebaseClassStudentRef.setValue(studentInfoForClassRoot)
      
      // add the behaviors to the student section with the current amounts set to 0
      firebaseClassStudentBehaviorRef.setValue(defaultBehaviorAmounts)
      
      // by default, set the student attendance to "Present" for today
      firebaseClassStudentAttendanceRef.setValue("Present")
      
      // by default, set the student group to 1
      firebaseClassGroupsRef.setValue("1")
      
    }
    else {
      println("ERROR: trying to send class to server without userID in user defaults")
    }
    
  }
  
  // MARK: - Firebase Student Deleting
  
  
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
  
  func setupFirebaseListeners() {
    setupDeleteListener()
    setupStudentsChangeListener()
  }
  
  func setupDeleteListener() {

    let firebaseClassStudentRef =
      firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("students/")
    
    addFirebaseReferenceToCollection(firebaseClassStudentRef)
    
    firebaseClassStudentRef.observeEventType(.ChildRemoved, withBlock: { snapshot in
      emptyAllTeacherStudentsLocally()
      self.getAllStudentsFromServer()
    })
  }
  
  func setupStudentsChangeListener() {
    // TODO set firebase ref to student behavior
    let firebaseStudentsrRef =
    firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("students/")
    
    addFirebaseReferenceToCollection(firebaseStudentsrRef)
    
    firebaseStudentsrRef.observeEventType(.ChildChanged, withBlock: { snapshot in
      emptyAllTeacherStudentsLocally()
      self.getAllStudentsFromServer()
    })
  }
  
  
  // MARK: - Reload Table Data Listener
  func setupReloadDataListener() {
    // add Listener for reloading the table
    // this allows sub-classes of this class to reload their table data
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadTableData:", name: "reload", object: nil)

  }
  
  func addFirebaseReferenceToCollection(newRef: Firebase) {
    allFirebaseListenerRefs.append(newRef)
  }
  
  // called on viewWillDisappear to remove every listener
  func removeAllFirebaseListeners() {
    for listener in allFirebaseListenerRefs {
      listener.removeAllObservers()
    }
  }

  
  // MARK: - Reload Table Data
  func reloadTableData(notification: NSNotification) {
    tableView.reloadData()
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
