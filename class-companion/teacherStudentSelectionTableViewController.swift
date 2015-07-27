//
//  teacherStudentSelectionTableViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/21/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class teacherStudentSelectionTableViewController: TeacherStudentsTableViewController {

  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      // Setup Listeners
      listenForStudentSelection()
      listenForStudentGroups()
      

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return 0
//    }

  override func setUpNavBarTitle() {
    self.navigationItem.title = "\(currentClassName!) Selection"
  }
  
  
  // MARK: - Table logic
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
      let cell = tableView.dequeueReusableCellWithIdentifier("teacherStudentSelectionCell", forIndexPath: indexPath) as! teacherStudentSelectionTableViewCell

      let currentRow = indexPath.row
      
      let selectedStudent = allTeacherStudents[currentRow]
      
      cell.studentNameLabel.text = selectedStudent.studentTitle
      
      if selectedStudent.currentlySelected {
        cell.selectionStatusLabel.text = "Selected!"
      } else {
        cell.selectionStatusLabel.text = ""
      }
      
      // if there is currently more than one student group
      if currentNumberOfStudentGroups > 1 {
        // if the student has a group number
        if let groupNumber = selectedStudent.groupNumber {
          // display that group number
          cell.groupNumberLabel.text = "Group \(groupNumber)"
        } // else if the student does not have a group number on the model
        else {
          // display group 1
          cell.groupNumberLabel.text = "Group 1"
        }
      } // else if there is only 1 student group (which means there are no groups)
      else {
        // display an empty label
        cell.groupNumberLabel.text = ""
      }
  
      return cell
    }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let row = indexPath.row
    
    setStudentAsSelected(row)
   
  }
  
  /*
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return numberOfTableSections
  }
  */

  
  // MARK: - Buttons
  
  @IBAction func randomSelectionButton(sender: UIBarButtonItem){
      let randomIndex = getRandomIndex(allTeacherStudents)
      setStudentAsSelected(randomIndex)
  }
  
  @IBAction func groupSelectionButton(sender: UIBarButtonItem) {
    showMakeGroupsAlert()
  }
  
  // MARK: - Make Groups Alert
  
  func showMakeGroupsAlert() {
    var alertController:UIAlertController?
    
    alertController = UIAlertController(title: "Groups",
      message: "Enter the number of groups to make below",
      preferredStyle: .Alert)
    
    alertController!.addTextFieldWithConfigurationHandler(
      {(textField: UITextField!) in
        textField.placeholder = "Number of Groups"
        textField.autocapitalizationType = UITextAutocapitalizationType.Words
        textField.becomeFirstResponder()
    })
    
    let submitAction = UIAlertAction(
      title: "Make Groups",
      style: UIAlertActionStyle.Default,
      handler: {[weak self]
        (paramAction:UIAlertAction!) in
        if let textFields = alertController?.textFields{
          let theTextFields = textFields as! [UITextField]
          let enteredText = theTextFields[0].text
          
          if let numberOfGroupsToMake = enteredText.toInt() {
            self!.divideStudentsIntoGroups(numberOfGroupsToMake)
          } else {
            theTextFields[0].text = ""
          }
        }
      })
    
    let cancelAction = UIAlertAction(
      title: "Cancel",
      style: UIAlertActionStyle.Cancel,
      handler: nil
    )
    
    let removeGroups = UIAlertAction(
      title: "Remove Groups",
      style: UIAlertActionStyle.Default,
      handler: {[weak self]
        (paramAction:UIAlertAction!) in
        self!.divideStudentsIntoGroups(1)
    })
    
    alertController?.addAction(cancelAction)
    alertController?.addAction(submitAction)
    alertController?.addAction(removeGroups)
    
    self.presentViewController(alertController!,
      animated: true,
      completion: nil)
    
  }
  
  var currentNumberOfStudentGroups = 1

  // Mark: - Divide Into Groups
  
  func divideStudentsIntoGroups(numberOfGroupsToMake: Int) {
    
    var allStudentGroups = Dictionary<String, Array<TeacherStudent>>()
    var currentGroupIndex = 1
    
    var shuffledStudents = allTeacherStudents
    // randomly shuffle the students so the groups are distributed randomly
    shuffledStudents.shuffle()
    
    for student in shuffledStudents {
      // set all students to not currently selected to prevent selection from persisting after creating a group
      student.currentlySelected = false
      // get the current group index as a string
      let currentGroupIndexString = String(currentGroupIndex)
      // if the bucket for the current group index in allStudentGroups does not exist
      if allStudentGroups[currentGroupIndexString] == nil {
        // create an empty bucket at the current group index
        allStudentGroups[currentGroupIndexString] = [TeacherStudent]()
      }
      // add the current student to the corresponding group index
      allStudentGroups[currentGroupIndexString]!.append(student)
      // if there are more group indexes
      if currentGroupIndex < numberOfGroupsToMake {
        // increase the group index counter
        currentGroupIndex++
      } // else if this is the highest number group index
      else {
        // reset the group index to 1
        // note we reset to 1 instead of 0, so the groups start with "Group 1"
        currentGroupIndex = 1
      }
    }
    
    assignGroupToStudentModels(allStudentGroups)
    
    currentNumberOfStudentGroups = numberOfGroupsToMake
    
    sendGroupsInfo(allStudentGroups)
  }
  
  func assignGroupToStudentModels(groupedStudentsArray: Dictionary<String, Array<TeacherStudent>>) {
    
    for (group, students) in groupedStudentsArray {
      for student in students {
        assignStudentModelToGroup(student.studentId, group)
      }
    }
  
    tableView.reloadData()
    
  }
  
  
  // MARK: - Select Student
 
  // stores the previously selected student index
  // used for removing the "Selected!" message from the detail
  var previousSelectionRow: Int?
  
  func setStudentAsSelected(selectedStudentIndex: Int) {
    // if we previously set a student selection
    if let previousSelectionIndex = previousSelectionRow {
      // set the previous student model's selection status to false
      allTeacherStudents[previousSelectionIndex].currentlySelected = false
      // get the index path for the previous random selection
      let previousCellIndexPath = NSIndexPath(forRow: previousSelectionIndex, inSection: 0)
      // reload the random path selection
      self.tableView.reloadRowsAtIndexPaths([previousCellIndexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    allTeacherStudents[selectedStudentIndex].currentlySelected = true
    
    let cellToEditIndexPath = NSIndexPath(forRow: selectedStudentIndex, inSection: 0)
    
    self.tableView.reloadRowsAtIndexPaths([cellToEditIndexPath], withRowAnimation: UITableViewRowAnimation.None)
    
    self.tableView.selectRowAtIndexPath(cellToEditIndexPath, animated: true, scrollPosition: .Middle);
    
    previousSelectionRow = selectedStudentIndex
    
    sendSelectedStudent(allTeacherStudents[selectedStudentIndex])
  }
  

  
  // MARK: - Firebase Send Student Selection Info
  
  func sendSelectedStudent(selectedStudent: TeacherStudent) {
    let studentId = selectedStudent.studentId
    
    let firebaseSelectionRef =
    firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("selection/")
      .childByAppendingPath("currentSelection")
    
    
    firebaseSelectionRef.setValue(studentId)
    
  
  }
  
  // MARK: - Firebase Send Group Info
  
  func sendGroupsInfo(allStudentGroups: Dictionary<String, Array<TeacherStudent>>) {
    let firebaseGroupRef =
    firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("groups/")

    var studentIdsAndGroups = [String: String]()
    
    for (group, studentList) in allStudentGroups {
      for student in studentList {
        studentIdsAndGroups[student.studentId] = student.groupNumber
      }
    }
    
    firebaseGroupRef.setValue(studentIdsAndGroups)

  }
  
  // MARK: - Firebase Student Selection Listener
  
  func listenForStudentSelection() {
    let firebaseSelectionRef =
    firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("selection/")
    
    addFirebaseReferenceToCollection(firebaseSelectionRef)
    
    firebaseSelectionRef.observeEventType(.ChildChanged, withBlock: { snapshot in
      
      let serverStudentId = snapshot.value as! String
      
      if let selectedStudentIndex = getIndexByStudentId(serverStudentId) {
        self.setStudentAsSelected(selectedStudentIndex)
      }
      
    })
    
  }
  
  // MARK: - Firebase Student Groups Listener
  func listenForStudentGroups() {
    let firebaseGroupsRef =
    firebaseClassRootRef
      .childByAppendingPath(currentClassId)
    // observe the current class root for changes
    
    addFirebaseReferenceToCollection(firebaseGroupsRef)
    
    firebaseGroupsRef.observeEventType(.Value, withBlock: { snapshot in
      // set the default number of groups to 1
      var numberOfGroupsOnServer = 1
      // for each student in the groups path
      for studentInfo in snapshot.childSnapshotForPath("groups").children.allObjects as! [FDataSnapshot] {
        let studentIdFromServer = studentInfo.key
        // if the student has a group number
        if let studentGroupFromServer = studentInfo.value as? String {
          // assign that group to the local student model
          assignStudentModelToGroup(studentIdFromServer, studentGroupFromServer)
          // if the current group number is the highest seen so far, store it
          numberOfGroupsOnServer = max(numberOfGroupsOnServer, studentGroupFromServer.toInt()!)
        }
      }
      // rearrange the local array of students to match the groups
      sortTeacherStudentsByGroupNumber()
      // set the local current number of groups to the highest number of groups found the on the server
      self.currentNumberOfStudentGroups = numberOfGroupsOnServer
      // reload the table to display the new group data
      self.tableView.reloadData()

    })
    
  }
  

  

}
