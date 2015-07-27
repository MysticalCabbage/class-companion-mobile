//
//  StudentBehaviorsCollectionViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/18/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

let reuseIdentifier = "behaviorActionCell"

class StudentBehaviorsCollectionViewController: UICollectionViewController, UICollectionViewDelegate {
  
  var allFirebaseListenerRefs = [Firebase]()

    override func viewDidLoad() {
      super.viewDidLoad()
      self.navigationItem.title = "\(currentStudentName!)'s Behavior"
      

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
      setupCellInsets()
      setupBackgroundTile()
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
        return allBehaviors.count
    }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! BehaviorCollectionViewCell
    
    let row = indexPath.row
    let behaviorName = allBehaviors[row].behaviorTitle
    let behaviorValue = allBehaviors[row].behaviorValue
    var behaviorValueString = String(behaviorValue)
    
    cell.behaviorNameLabel.text = behaviorName
    
    cell.behaviorValueLabel.text = behaviorValueString
    
    if (behaviorValue > 0) {
      cell.behaviorValueLabel.text = "+" + behaviorValueString
      cell.behaviorValueLabel.textColor = UIColor.greenColor()
    } else {
      cell.behaviorValueLabel.textColor = UIColor.redColor()

    }
    
    return cell
  }
  
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
    
    var cell = collectionView.cellForItemAtIndexPath(indexPath)!

    let row = indexPath.row
    
    let behaviorPoints = allBehaviors[row].behaviorValue
    let behaviorName = allBehaviors[row].behaviorTitle
    
    updateBehaviorPoints(behaviorPoints)
    
    updateBehaviorList(behaviorName)
    // TODO: dismiss the modal
    
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSize(width: 90, height: 90) // The size of one cell
  }
  
  // MARK: - Firebase Update Behavior Points
  
  func updateBehaviorPoints(behaviorValueToAddOrSubtract: Int) {
    
    
    let firebaseStudentBehaviorRef =
    firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("students/")
      .childByAppendingPath(currentStudentId)
      .childByAppendingPath("behaviorTotal/")
    
    
    firebaseStudentBehaviorRef.runTransactionBlock({
      (currentData:FMutableData!) in
      
      if let behaviorValue = currentData.value as? Int {
        currentData.value = behaviorValue + behaviorValueToAddOrSubtract
      } else {
        currentData.value = 1
      }
      
      return FTransactionResult.successWithValue(currentData)
    })
    
  }
  
  func updateBehaviorList(behaviorNameToAppend: String) {
    let firebaseStudentBehaviorListRef =
    firebaseClassRootRef
      .childByAppendingPath(currentClassId)
      .childByAppendingPath("students/")
      .childByAppendingPath(currentStudentId)
      .childByAppendingPath("behavior/")
      .childByAppendingPath(behaviorNameToAppend)
    
    firebaseStudentBehaviorListRef.runTransactionBlock({
      (currentData:FMutableData!) in
      
      if let currentBehaviorCount = currentData.value as? Int {
        currentData.value = currentBehaviorCount + 1
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
    
    addFirebaseReferenceToCollection(firebaseClassBehaviorRef)
    
    // retrieve all behaviors in ascending order with respect to behavior value
    firebaseClassBehaviorRef.queryOrderedByValue().observeEventType(.Value, withBlock: { snapshot in
      // we reverse the query result to sort the data in descending order by behavior value
      for behaviorFromServer in reverse(snapshot.children.allObjects as! [FDataSnapshot]) {
        let newBehavior = Behavior(snap: behaviorFromServer)
        addNewBehavior(newBehavior)
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
  
  func addFirebaseReferenceToCollection(newRef: Firebase) {
    allFirebaseListenerRefs.append(newRef)
  }
  
  // called on viewWillDisappear to remove every listener
  func removeAllFirebaseListeners() {
    for listener in allFirebaseListenerRefs {
      listener.removeAllObservers()
    }
  }
  
  func setupBackgroundTile() {
    let image = UIImage(named: "handmade-paper.png")!
    let scaled = UIImage(CGImage: image.CGImage, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    
    self.view.backgroundColor = UIColor(patternImage: scaled!)
  }
  
  
  
  func setupCellInsets() {
    let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top:10,left:10,bottom:10,right:10)
    layout.minimumInteritemSpacing = 5
//    layout.minimumLineSpacing = 10
    
    self.collectionView!.collectionViewLayout = layout
  }

  
}

