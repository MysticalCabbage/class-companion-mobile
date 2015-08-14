
//
//  LoginViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/14/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
  

  override func viewDidLoad() {
    super.viewDidLoad()

    self.passwordField.delegate = self
    self.usernameField.delegate  = self
  }
  

  
  
  @IBOutlet weak var usernameField: UITextField!
  

  @IBOutlet weak var passwordField: UITextField!
  
  
  @IBOutlet weak var statusLabel: UILabel!
  
  // when pressing enter on a keyboard
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    // hide the keyboard
    textField.resignFirstResponder()
    // try and log in with the current username/password field
    loginButton()
    return true;
  }
  // when a user touches on the screen
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    // dismiss the keyboard
    self.view.endEditing(true)
  }
  
  @IBAction func loginButton() {
    if let username = usernameField.text {
      if let password = passwordField.text {
        checkLoginCredentials(username, password: password, isNewUser: false)
      }
    }
  }
  
  
  func goToTeacherDashboardView () {
    self.performSegueWithIdentifier("showTeacherDashboard", sender: self)
  }
  

  
  // MARK: -Firebase Auth
  
  // sends the user to safari to signup for an account
  @IBAction func signupButton(sender: UIButton) {
  
    if let username = usernameField.text {
      if let password = passwordField.text {
        
        createFirebaseUser(username, password: password)
      }
    }

  }

  func createFirebaseUser (username: String, password: String) {

    firebaseRef.createUser(username, password: password,
      withValueCompletionBlock: { authError, result in
        if authError != nil {
          println("There was an error creating account \(authError)")
          self.handleErrorMessage(authError)
        } else {
          self.checkLoginCredentials(username, password: password, isNewUser: true)
        }
    })
  }
  
  // creates the demo class when a new user is made
  func createServerDemoClass(userId: String) {
    
    let request = prepareRequest(userId)
    
    // prepare task object for the POST request
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in
        if error != nil {
          println("demo class creation POST request error: \(error)")
          return
        }
    }
    // start the task to create the demo class
    task.resume()
  }
  
  // prepares the request for the demo class creation
  func prepareRequest(userId: String) -> NSMutableURLRequest {
    // api call url
    let serverUrl = NSURL(string: "http://wwww.class-companion.com/api/teacher/demo")
    // creates request type
    let request = NSMutableURLRequest(URL:serverUrl!)
    // prepares key-value pair
    let newUserIdPostData: String = "teacherId=\(userId)"
    // sets the key value pair as a json
    request.HTTPBody = newUserIdPostData.dataUsingEncoding(NSUTF8StringEncoding)
    request.HTTPMethod = "POST";

    return request
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
  
  func checkLoginCredentials(username: String, password: String, isNewUser: Bool){

    firebaseRef.authUser(username, password: password,
      withCompletionBlock: { authError, authData in
        if authError != nil {
          self.statusLabel.text = "Invalid login credentials"
          self.handleErrorMessage(authError)
        } else {
          let userId = authData.uid
          self.setLoggedInUserId(userId)
          self.goToTeacherDashboardView()
          if isNewUser {
            self.createServerDemoClass(userId)
          }
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
                      "firstName": "",
                      "lastName": "",
                      "prefix": "",
                      "uid": currentUserId
                      ]
    
    firebaseInfoPath.setValue(teacherInfo)
    
  }
  
  func userSuccessfullyLoggedIn() {
    goToTeacherDashboardView()
  }

  

}

