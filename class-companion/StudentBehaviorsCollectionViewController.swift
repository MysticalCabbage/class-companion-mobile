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
      
      setupCellSpacing()
      setupBackgroundTile()
      getAllBehaviorsFromServer()
    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


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
    
    // if the value of the behavior is positive
    if (behaviorValue > 0) {
      // add a "+" to the label before the number
      cell.behaviorValueLabel.text = "+" + behaviorValueString
      cell.behaviorValueLabel.textColor = UIColor.blueColor()
    } else {
      cell.behaviorValueLabel.textColor = UIColor.redColor()

    }
    
    return cell
  }
  
  override func viewWillDisappear(animated: Bool) {
    removeAllFirebaseListeners()
  }
  
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
    
    var cell = collectionView.cellForItemAtIndexPath(indexPath)!

    let row = indexPath.row
    
    let behaviorPoints = allBehaviors[row].behaviorValue
    let behaviorName = allBehaviors[row].behaviorTitle
    
    updateBehaviorPoints(behaviorPoints)
    
    updateBehaviorList(behaviorName)
    
    // dismiss the modal
    self.dismissViewControllerAnimated(true, completion: {});
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSize(width: 90, height: 90) // The size of one cell
  }
  
  @IBAction func addBehaviorButton(sender: UIBarButtonItem) {
    addBehaviorAlert()
  }
  // MARK: - Add Behavior
  
  func addBehaviorAlert() {
    var alertController:UIAlertController?
    
    alertController = UIAlertController(title: "Behavior",
      message: "Enter the behavior to make below",
      preferredStyle: .Alert)
    
    alertController!.addTextFieldWithConfigurationHandler(
      {(nameTextField: UITextField!) in
        nameTextField.placeholder = "Behavior Name"
        nameTextField.autocapitalizationType = UITextAutocapitalizationType.Words
        nameTextField.becomeFirstResponder()
    })
    
    alertController!.addTextFieldWithConfigurationHandler(
      {(valueTextField: UITextField!) in
        valueTextField.placeholder = "value ex) 4 ex) -2"
        valueTextField.becomeFirstResponder()
    })
    
    let submitAction = UIAlertAction(
      title: "Make Behavior",
      style: UIAlertActionStyle.Default,
      handler: {[weak self]
        (paramAction:UIAlertAction!) in
        if let textFields = alertController?.textFields{
          let theTextFields = textFields as! [UITextField]
          let behaviorName = theTextFields[0].text
          let behaviorValue = theTextFields[1].text
          if let behaviorValueInt = behaviorValue.toInt() {
            self!.sendBehaviorToServer(behaviorName, newBehaviorValue: behaviorValueInt)
          } else {
            theTextFields[1].text = ""
          }
        }
      })
    
    let cancelAction = UIAlertAction(
      title: "Cancel",
      style: UIAlertActionStyle.Cancel,
      handler: nil
    )

    
    alertController?.addAction(submitAction)
    alertController?.addAction(cancelAction)
    
    
    self.presentViewController(alertController!,
      animated: true,
      completion: nil)
  }
  
  func sendBehaviorToServer(newBehaviorName: String, newBehaviorValue: Int) {
    println("new behavior name \(newBehaviorName) value \(newBehaviorValue)")
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
    firebaseClassBehaviorRef.queryOrderedByValue().observeSingleEventOfType(.Value, withBlock: { snapshot in
      // reverse the query result to sort the data in descending order by behavior value
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
    // TODO: Implement creating new behaviors
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
  
  // Mark: - Layout
  
  func setupBackgroundTile() {
    let image = UIImage(named: "handmade-paper.png")!
    let scaled = UIImage(CGImage: image.CGImage, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    self.view.backgroundColor = UIColor(patternImage: scaled!)
  }
  
  func setupCellSpacing() {
    let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top:10,left:10,bottom:10,right:10)
    layout.minimumInteritemSpacing = 5
    layout.minimumLineSpacing = 10
    self.collectionView!.collectionViewLayout = layout
  }

  
}

