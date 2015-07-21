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

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Potentially incomplete method implementation.
//        // Return the number of sections.
//        return 0
//    }
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
      let cell = tableView.dequeueReusableCellWithIdentifier("teacherStudentSelectionCell", forIndexPath: indexPath) as! UITableViewCell

      let row = indexPath.row
      
      
      
      cell.textLabel?.text = allTeacherStudents[row].studentTitle
      cell.detailTextLabel?.text = ""
      
      
      return cell
    }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let row = indexPath.row
    let selectedStudent = allTeacherStudents[row]
   
    
    
  }
  
  // MARK: - Buttons
  
  @IBAction func randomSelectionButton(sender: UIBarButtonItem){
   
      setRandomStudentAsSelected()
  }
  
  // MARK: - Random Selection
  func getRandomRowIndex() -> Int {
    let randomRowIndex = Int(arc4random_uniform(UInt32(allTeacherStudents.count)))
    
    return randomRowIndex
  }
  
  // stores the previously selected student index
  // used for removing the "Selected!" message from the detail
  var previousRandomSelectionRowIndex: Int?
  
  func setRandomStudentAsSelected() {
    // if we have randomly selected before
    if let previousRowIndex = previousRandomSelectionRowIndex {
      // set the old random selection detail to a blank message
      setRowDetailMessage(previousRowIndex, withMessage: "")
    }
    let randomRowIndex = getRandomRowIndex()
    setRowDetailMessage(randomRowIndex, withMessage: "Selected!")
    previousRandomSelectionRowIndex = randomRowIndex
  }
  
  func setRowDetailMessage(atRowIndex: Int, withMessage: String) {
    let cellToEditIndexPath = NSIndexPath(forRow: atRowIndex, inSection: 0)
    
    let cellToEdit = tableView.cellForRowAtIndexPath(cellToEditIndexPath)
    
    cellToEdit!.detailTextLabel?.text = withMessage
    
    
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
