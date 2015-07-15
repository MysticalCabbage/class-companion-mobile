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
      
      // TEST DATA FOR TEACHER CLASSES
      let class1 = TeacherClass(className: "English")
      addNewTeacherClass(class1)
      let class2 = TeacherClass(className: "Geography")
      addNewTeacherClass(class2)
      let class3 = TeacherClass(className: "Writing")
      addNewTeacherClass(class3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  @IBOutlet var classTableView: TeacherClassesUITableView!
  
  let testClasses = ["English", "Geography", "Writing"]
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
    
    println(allTeacherClasses[row])
    cell.textLabel?.text = allTeacherClasses[row].className

    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let row = indexPath.row
    println(testClasses[row])
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
