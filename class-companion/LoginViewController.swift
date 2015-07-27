
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
        
      }
    }
  }
  
  
  func goToTeacherDashboardView () {
    self.performSegueWithIdentifier("showTeacherDashboard", sender: self)
  }
  

  
  // MARK: -Firebase Auth
  
  // sends the user to safari to signup for an account
  @IBAction func signupButton(sender: UIButton) {
    
    if let webAppUrl = NSURL(string: "http://class-companion.com") {
      UIApplication.sharedApplication().openURL(webAppUrl)
    }
    
//  Disabled in-app signup due to missing fields for title, firstname, lastname, etc.
//    if let username = usernameField.text {
//      if let password = passwordField.text {
//        
//        createFirebaseUser(username, password: password)
//        
//      }
//    }
  }
  // This feature is not currently being used due to lack of
  // dedicated signup page to handle all user account fields
  func createFirebaseUser (username: String, password: String) {

    firebaseRef.createUser(username, password: password,
      withValueCompletionBlock: { authError, result in
        if authError != nil {
          println("There was an error creating account\(authError)")
          self.handleErrorMessage(authError)
        } else {
          self.checkLoginCredentials(username, password: password)
        }
    })
  }
  
  
  // handles error messages from the firebase auth server
  func handleErrorMessage(authError: NSError) {
    let status = statusLabel
    
    if let errorCode = FAuthenticationError(rawValue: authError.code) {
      switch (errorCode) {
      case .UserDoesNotExist:
        status.text = "User does not exist";
      case .InvalidEmail:
        status.text = "Invalid email format";
      case .InvalidPassword:
        status.text = "Password is incorrect";
      case .EmailTaken:
        status.text = "Email is already taken";
      case .NetworkError:
        status.text = "Network error, try again";
      default:
        status.text = "Login/Signup error, try again";
      }
    }
  }
  
  func checkLoginCredentials(username: String, password: String){

    firebaseRef.authUser(username, password: password,
      withCompletionBlock: { authError, authData in
        if authError != nil {
          self.statusLabel.text = "Invalid login credentials"
          self.handleErrorMessage(authError)
        } else {
          let userId = authData.uid
          self.setLoggedInUserId(userId)
          self.goToTeacherDashboardView()
        }
    })
    
  }
  
  func setLoggedInUserId(userId: String) {
    
    currentUserId = userId
    
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

