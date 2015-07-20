//
//  StudentBehaviorsCollectionViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/18/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

let reuseIdentifier = "behaviorActionCell"

class StudentBehaviorsCollectionViewController: UICollectionViewController {
  
  let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)


    override func viewDidLoad() {
      super.viewDidLoad()
      self.title = "\(currentStudentName!)'s Behavior"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
      
      getAllBehaviorsFromServer()
      
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

  @IBAction func cancelAssignBehavior(sender: UIBarButtonItem) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return allBehaviors.count
      return 10
    }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    // 3
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BehaviorCollectionViewCell
    
    // Configure the cell
    
    let diceRoll = Int(arc4random_uniform(2))
    
    var debugBehaviorName: String
    var debugBehaviorValue: String
    
    if (diceRoll == 0) {
      debugBehaviorName = "Raising Hand"
      debugBehaviorValue = "1"
    } else {
      debugBehaviorName = "Forgot homework"
      debugBehaviorValue = "-1"
    }
    
    cell.behaviorNameLabel.text = debugBehaviorName
    cell.behaviorValueLabel.text = debugBehaviorValue
    
    return cell
  }
  
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
    
    var cell = collectionView.cellForItemAtIndexPath(indexPath)!
//    cell.backgroundColor = UIColor.magentaColor()
//    let behaviorValue = cell.behaviorValueLabel.text
    
    updateBehaviorPoints("1")
    
    // TODO: dismiss the modal
    
  }
  
  // MARK: - Firebase Update Behavior Points
  
  func updateBehaviorPoints(behaviorValueToAdd: String) {
    
    
    let firebaseStudentBehaviorRef =
    firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("students/")
      .childByAppendingPath(currentStudentId)
      .childByAppendingPath("behaviorTotal/")
    
    let behaviorValueToAddInt = behaviorValueToAdd.toInt()
    
    
    firebaseStudentBehaviorRef.runTransactionBlock({
      (currentData:FMutableData!) in
      
      if let behaviorValue = currentData.value as? Int {
        currentData.value = behaviorValue + behaviorValueToAddInt!
      } else {
        currentData.value = 1
      }
      
      return FTransactionResult.successWithValue(currentData)
    })
    
  }
  
  // MARK: - Firebase Get All Behaviors
  
  func getAllBehaviorsFromServer() {
    let firebaseClassBehaviorRef =
      firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("info/")
      .childByAppendingPath("behavior/")
    
    firebaseClassBehaviorRef.observeEventType(.Value, withBlock: { snapshot in
      for behaviorFromServer in snapshot.children.allObjects as! [FDataSnapshot] {
      //        println("STUDENT FROM SERVER IS \(studentFromServer)")
        let newBehavior = Behavior(snap: behaviorFromServer)
        addNewBehavior(newBehavior)
        println(allBehaviors)
      }
    // after adding the new behaviors to the behaviors array, reload the collection
    self.collectionView!.reloadData()
    
    }, withCancelBlock: { error in
    println(error.description)
    })
  }
  
  // Mark: - Firebase Send New Behavior
  
  func sendNewBehaviorToServer(behaviorName: String, behaviorValue: Int) {
    
  }
  
  
  
  


    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */


}
