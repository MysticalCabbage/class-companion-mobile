//
//  TeacherDashboardViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/14/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class TeacherDashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIBarPositioningDelegate {

  @IBOutlet weak var dashboardNavigationBar: UINavigationBar!
  
    var allFirebaseListenerRefs = [Firebase]()
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
      classTableView.delegate = self
      classTableView.dataSource = self
      
//      dashboar
//      dashboardNavigationBar.delegate = self
//      self.navigationItem.appearance()
      
//      let barPosition: UIBarPosition
      
      // Deletes all classes currently in the array
      emptyAllTeacherClassesLocally()
      
      setupDeleteListener()
      
      // Set default behaviors
      setDefaultBehaviors()
      
      
      // Gets all current class data from the server
      getAllClassesFromServer()
      
    }

  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
  
  override func viewWillDisappear(animated: Bool) {
    removeAllFirebaseListeners()
  }
  
  override func viewWillAppear(animated: Bool){
    super.viewWillAppear(true)
    emptyAllTeacherStudentsLocally()
  }
  
  
  
  // MARK: - Add / Delete Class Alerts
  // ADD CLASS ALERT
  @IBAction func addNewTeacherClassAlert(sender: AnyObject) {
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
          let newClassName = enteredText
          self!.sendClassToServer(newClassName)
          self!.classTableView.reloadData()
          
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
  @IBOutlet var classTableView: TeacherClassesUITableView!
  
  let classCellIdentifier = "ClassCell"
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allTeacherClasses.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let cell = classTableView.dequeueReusableCellWithIdentifier("ClassCell") as! UITableViewCell
    
    let row = indexPath.row
    
    cell.textLabel?.text = allTeacherClasses[row].classTitle

    return cell
  }

  // handles segueing to show the view for an individual classroom
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let row = indexPath.row
    let selectedCell = allTeacherClasses[row]
    let selectedCellClassId = selectedCell.classId
    
    currentClassId = selectedCellClassId
    currentClassName = selectedCell.classTitle
    
    performSegueWithIdentifier("showTeacherStudentsView", sender: nil)
    
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.Delete) {
      let row = Int(indexPath.row)
      let classToDelete = allTeacherClasses[row]
      
      showDeleteConfirmationAlert(classToDelete.classTitle, classId: classToDelete.classId, row: row)
      
    }
  }
  
  func removeClass(classNameToRemove: String, row: Int) {
    allTeacherClasses.removeAtIndex(row)
    self.classTableView.reloadData()
  }
  
  
  func showDeleteConfirmationAlert(className: String, classId: String, row: Int){
    
    
    var deleteConfirmationAlert = UIAlertController(title: "Delete Class", message: "Are you sure you want to delete the \"\(className)\" class? All data will be lost!!", preferredStyle: UIAlertControllerStyle.Alert)
    
    deleteConfirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))


    let deleteAction = UIAlertAction(
      title: "Delete \(className) class",
      style: UIAlertActionStyle.Default,
      handler: { (action: UIAlertAction!) -> Void in
        self.deleteClassFromServer(className, classId: classId, row: row)
      }
    )
    
    deleteConfirmationAlert.addAction(deleteAction)
    
    
    
    presentViewController(deleteConfirmationAlert, animated: true, completion: nil)
    
  }

  // MARK: - Firebase Class Retrieval
  
  func getAllClassesFromServer() {
    let firebaseTeacherClassesRef =
      firebaseTeacherRootRef
        .childByAppendingPath(currentUserId)
        .childByAppendingPath("classes/")
    
    addFirebaseReferenceToCollection(firebaseTeacherClassesRef)
    
    firebaseTeacherClassesRef.observeEventType(.Value, withBlock: { snapshot in
      for classFromServer in snapshot.children.allObjects as! [FDataSnapshot] {
        let newTeacherClass = TeacherClass(snap: classFromServer)
        addNewTeacherClass(newTeacherClass)
      }
      // after adding the new classes to the classes array, reload the table
      self.classTableView.reloadData()
      
      }, withCancelBlock: { error in
        println(error.description)
    })
    
  }
  
  
  // MARK: - Firebase Class Sending
  
  func sendClassToServer(className: String) {

    if let currentUserId = userDefaults.stringForKey(currentUserIdKey) {


      
      // prepare data to send to teacher section of database

      let firebaseTeacherClassRef =
        firebaseTeacherRootRef
          .childByAppendingPath(currentUserId)
          .childByAppendingPath("classes/")
          .childByAutoId()
      

      let newClassIdKey = firebaseTeacherClassRef.key
      
      let firebaseClassBehaviorRef =
        firebaseClassRootRef
          .childByAppendingPath(newClassIdKey)
          .childByAppendingPath("info/")
          .childByAppendingPath("behavior/")
      
      let firebaseClassRootWithClassKey =
        firebaseClassRootRef
          .childByAppendingPath(newClassIdKey)
          .childByAppendingPath("info/")
      
      let firebaseTeacherBehaviorRef =
        firebaseTeacherRootRef
          .childByAppendingPath(currentUserId)
          .childByAppendingPath("classes/")
          .childByAppendingPath(newClassIdKey)
          .childByAppendingPath("behavior")

      
      let classInfoForTeacher = ["classTitle": className, "teacherId": currentUserId, "classId": newClassIdKey]
      let classInfoForClassRoot = ["classId": newClassIdKey, "classTitle": className, "teacherId": currentUserId]
      
      
      // add the class to the teacher section
      firebaseTeacherClassRef.setValue(classInfoForTeacher)
      
      // add the class to the classes section
      firebaseClassRootWithClassKey.setValue(classInfoForClassRoot)
      
      // add the default behaviors in the class root
      firebaseClassBehaviorRef.setValue(defaultBehaviors)
      
      // add the default behaviors to the teacher section
      firebaseTeacherBehaviorRef.setValue(defaultBehaviors)

      
    }
    else {
      println("ERROR: trying to send class to server without userID in user defaults")
    }
    
  }
  
  // MARK: - Firebase Class Deleting
  
  
  func deleteClassFromServer(className: String, classId: String, row: Int) {
    let firebaseDeleteClassRef = firebaseClassRootRef.childByAppendingPath(classId).childByAppendingPath("info/")
    
    firebaseDeleteClassRef.removeValue()
    
    let firebaseTeacherUserRootRef = firebaseTeacherRootRef.childByAppendingPath(currentUserId)
    let firebaseDeleteClassTeacherRef = firebaseTeacherUserRootRef.childByAppendingPath("classes/").childByAppendingPath(classId)
    
    firebaseDeleteClassTeacherRef.removeValue()
    
  }
  
  
// MARK: - Firebase Listeners
  
  func setupDeleteListener() {
    let firebaseAllClassesRef =
      firebaseTeacherRootRef
        .childByAppendingPath(currentUserId)
        .childByAppendingPath("classes/")
    
    addFirebaseReferenceToCollection(firebaseAllClassesRef)
    
    firebaseAllClassesRef.observeEventType(.ChildRemoved, withBlock: { snapshot in
      println("DELETED \(snapshot.value)")
      emptyAllTeacherClassesLocally()
      self.getAllClassesFromServer()
    })
  }
  
  func addFirebaseReferenceToCollection(newRef: Firebase) {
    allFirebaseListenerRefs.append(newRef)
  }
  
  // called on viewWillDisappear to remove every listener
  func removeAllFirebaseListeners() {
    for listener in allFirebaseListenerRefs {
      listener.removeAllObservers()
    }
    allFirebaseListenerRefs.removeAll()
  }
  
}
