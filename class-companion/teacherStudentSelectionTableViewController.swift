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
    self.title = "\(currentClassName!) Selection"
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
      
      
      if let groupNumber = selectedStudent.groupNumber where numberOfStudentGroups > 1 {
        println("group number is \(groupNumber)")
        cell.groupNumberLabel.text = "Group \(groupNumber)"
      } else {
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
//    divideStudentsIntoGroups(2)
    makeGroupsAlert()
  }
  
  func makeGroupsAlert() {
    var alertController:UIAlertController?
    
    alertController = UIAlertController(title: "Make Groups",
      message: "Enter the number of groups below",
      preferredStyle: .Alert)
    
    alertController!.addTextFieldWithConfigurationHandler(
      {(textField: UITextField!) in
        textField.placeholder = "Number of Groups"
        textField.autocapitalizationType = UITextAutocapitalizationType.Words
    })
    
    let submitAction = UIAlertAction(
      title: "Make Groups",
      style: UIAlertActionStyle.Default,
      handler: {[weak self]
        (paramAction:UIAlertAction!) in
        if let textFields = alertController?.textFields{
          let theTextFields = textFields as! [UITextField]
          let enteredText = theTextFields[0].text
          let numberOfGroupsToMake = enteredText.toInt()
          self!.divideStudentsIntoGroups(numberOfGroupsToMake!)
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
  
  var numberOfStudentGroups = 1

  // Mark: - Divide Into Groups
  
  func divideStudentsIntoGroups(numberOfGroupsToMake: Int) {
    
    var allStudentGroups = Dictionary<Int, Array<TeacherStudent>>()
    var currentGroupIndex = 1
    
    var shuffledStudents = allTeacherStudents
    
    shuffledStudents.shuffle()
    
    for student in shuffledStudents {
      if allStudentGroups[currentGroupIndex] == nil {
        allStudentGroups[currentGroupIndex] = [TeacherStudent]()
      }
      allStudentGroups[currentGroupIndex]!.append(student)
      if currentGroupIndex < numberOfGroupsToMake {
        currentGroupIndex++
      } else {
        currentGroupIndex = 1
      }
    }
    
    assignGroupToStudentModels(allStudentGroups)
    
    numberOfStudentGroups = numberOfGroupsToMake
    
    
  }
  
  func assignGroupToStudentModels(groupedStudentsArray: Dictionary<Int, Array<TeacherStudent>>) {
    
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
  
  // MARK: - Firebase Student Selection Listener
  
  func listenForStudentSelection() {
    let firebaseSelectionRef =
    firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("selection/")
    
    firebaseSelectionRef.observeEventType(.ChildChanged, withBlock: { snapshot in
      
      let serverStudentId = snapshot.value as! String
      
      if let selectedStudentIndex = getIndexByStudentId(serverStudentId) {
        self.setStudentAsSelected(selectedStudentIndex)
      }
      
    })
    
  }
  

  
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
