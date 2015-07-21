
//
//  LoginViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/14/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  

  override func viewDidLoad() {
    super.viewDidLoad()
    
//    handleUserAlreadyLoggedIn()
//    createFirebaseTestUser()
    
  }
  

  
  
  @IBOutlet weak var usernameField: UITextField!
  

  @IBOutlet weak var passwordField: UITextField!
  
  
  @IBOutlet weak var statusLabel: UILabel!
  
  @IBAction func logoutButton(sender: UIBarButtonItem) {
    userDefaults.setObject(false, forKey: userIsAuthenticatedConstant)
  }
  
  @IBAction func loginButton() {
    if let username = usernameField.text {
      if let password = passwordField.text {
        
        checkLoginCredentials(username, password: password)
        
//        let loginResult = checkLoginCredentials(username, password: password)
//        if loginResult {
//          userDefaults.setObject(true, forKey: userIsAuthenticatedConstant)
//          goToTeacherDashboardView()
//        } else {
//          statusLabel.text = "Invalid login credentials"
//        }
      }
    }
  }
  
  // DISABLED FOR NOW
  func handleUserAlreadyLoggedIn (){
    if let userLoggedIn = userDefaults.stringForKey(userIsAuthenticatedConstant) {
      if userLoggedIn == "1" {
        println("Is the user already logged in? \(userLoggedIn)")
        goToTeacherDashboardView()
      } else {
        println("User is not logged in, but they have credentials")
      }
    } else {
      println("User is not logged in")
    }
  }
  
  func goToTeacherDashboardView () {
    self.performSegueWithIdentifier("showTeacherDashboard", sender: self)
  }
  

  
  // MARK: -Firebase Auth
  
  
//  let firebaseRef = Firebase(url: "https://shining-fire-7845.firebaseIO.com")
  
  
  func createFirebaseTestUser () {
    
    
    firebaseRef.createUser("mysticalcabbage@mc.com", password: "password",
      withValueCompletionBlock: { error, result in
        if error != nil {
          println("There was an error creating account\(error)")
        } else {
          let uid = result["uid"] as? String
          println("Successfully created user account with uid: \(uid)")
        }
    })
  }
  
  func checkLoginCredentials(username: String, password: String){

    firebaseRef.authUser(username, password: password,
      withCompletionBlock: { error, authData in
        if authData == nil {
          self.statusLabel.text = "Invalid login credentials"
        } else {
          let userId = authData.uid
          self.setLoggedInUserId(userId)
          self.goToTeacherDashboardView()
        }
    })
    
  }
  
  func setLoggedInUserId(userId: String) {
    
    currentUserId = userId
    
//    userDefaults.setObject(userId, forKey: currentUserIdKey)
    
//    println("current user is \(currentUserId)")
    
    // FOR TESTING: automatically set the user to a teacher
    userDefaults.setObject("Teacher", forKey: "AccountType")
    
    // FOR TESTING: automatically add extra field values to firebase
    let firebaseInfoPath = firebaseTeacherRootRef.childByAppendingPath(currentUserId).childByAppendingPath("info")
    
    let teacherInfo = [
                      "email": usernameField.text,
                      "firstName": "Cabbage",
                      "lastName": "Mystical",
                      "prefix": "Sorcerer",
                      "uid": currentUserId
                      ]
    
    firebaseInfoPath.setValue(teacherInfo)
    
  }
  
  func userSuccessfullyLoggedIn() {
    goToTeacherDashboardView()
  }

  

}

