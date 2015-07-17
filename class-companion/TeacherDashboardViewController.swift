//
//  TeacherDashboardViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/14/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class TeacherDashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
      classTableView.delegate = self
      classTableView.dataSource = self
      
      // Deletes all classes currently in the array
      emptyAllTeacherClasses()
      
      // Gets all current class data from the server
      getAllClasses()
      
      // TEST DATA FOR TEACHER CLASSES
      let class1 = TeacherClass(className: "English")
//      addNewTeacherClass(class1)
      sendClassToServer(class1)
      let class2 = TeacherClass(className: "Geography")
//      addNewTeacherClass(class2)
      sendClassToServer(class2)
      let class3 = TeacherClass(className: "Writing")
//      addNewTeacherClass(class3)
      sendClassToServer(class3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
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
          let newClass = TeacherClass(className: enteredText)
          addNewTeacherClass(newClass)
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
    
    cell.textLabel?.text = allTeacherClasses[row].className

    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let row = indexPath.row
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.Delete) {
      let row = Int(indexPath.row)
      let classToDelete = allTeacherClasses[row]
      
      showDeleteConfirmationAlert(classToDelete.className, row: row)
      
    }
  }
  
  func removeClass(classNameToRemove: String, row: Int) {
    allTeacherClasses.removeAtIndex(row)
    self.classTableView.reloadData()
  }
  
  
  func showDeleteConfirmationAlert(className: String, row: Int){
    
    
    var deleteConfirmationAlert = UIAlertController(title: "Delete Class", message: "Are you sure you want to delete the \"\(className)\" class? All data will be lost!!", preferredStyle: UIAlertControllerStyle.Alert)
    
    deleteConfirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))

    
    deleteConfirmationAlert.addAction(UIAlertAction(title: "Delete \(className) class", style: .Default, handler: { (action: UIAlertAction!) in
      self.removeClass(className, row: row)
    }))
    
    
    
    presentViewController(deleteConfirmationAlert, animated: true, completion: nil)
    
  }
  
  // MARK: - Firebase Class Retrival
  
  func getAllClasses() {
    if let currentUserId = userDefaults.stringForKey(currentUserIdKey) {
      let firebaseTeacherClassesRef = firebaseRef.childByAppendingPath("teachers/")
      firebaseTeacherClassesRef.observeEventType(.Value, withBlock: { snapshot in
          println(snapshot.value)
        }, withCancelBlock: { error in
          println(error.description)
      })
    }
    
  }
  
  func sendClassToServer(classToSendToServer: TeacherClass) {
    let className = classToSendToServer.className
    
    if let currentUserId = userDefaults.stringForKey(currentUserIdKey) {
      let classInfoForTeacher = ["classTitle": className, "teacherId": currentUserId]
      
      let firebaseTeacherClassesRef = firebaseRef.childByAppendingPath("teachers/")
      let firebaseUserTeacherClassesRef = firebaseTeacherClassesRef.childByAppendingPath(currentUserId)
      let firebaseUserTeacherClassWithKeyRef = firebaseUserTeacherClassesRef.childByAutoId()
      
      firebaseUserTeacherClassWithKeyRef.setValue(classInfoForTeacher)
      
      let firebaseClassRootRef = firebaseRef.childByAppendingPath("classes/")
      let classIdKey = firebaseUserTeacherClassWithKeyRef.key
      
      
      
      let firebaseClassRootWithClassKey = firebaseClassRootRef.childByAppendingPath(classIdKey)
      
      let classInfoForClassRoot = ["classId": classIdKey, "classTitle": className, "teacherId": currentUserId]
      
      firebaseClassRootWithClassKey.setValue(classInfoForClassRoot)
      
      
      
    }
  }
  
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
