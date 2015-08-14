
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
          println("There was an error creating account\(authError)")
          self.handleErrorMessage(authError)
        } else {
          self.checkLoginCredentials(username, password: password)
        }
    })
  }
  
  func createServerDemoClass(userId: String) {
    
    let request = prepareRequest(userId)
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in
        if error != nil {
          println("error=\(error)")
          return
        }
        
        println("response = \(response)")
        
        let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
        println("responseString = \(responseString)")
    }
    task.resume()
    
  }
  
  func prepareRequest(userId: String) -> NSMutableURLRequest {
    let serverUrl = NSURL(string: "http://wwww.class-companion.com/api/teacher/demo")
    let request = NSMutableURLRequest(URL:serverUrl!)
    // prepares key-value pair
    let newUserIdPostData: String = "teacherId=\(userId)"
    
    request.HTTPMethod = "POST";
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    request.HTTPBody = newUserIdPostData.dataUsingEncoding(NSUTF8StringEncoding)

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
  
  func checkLoginCredentials(username: String, password: String){

    firebaseRef.authUser(username, password: password,
      withCompletionBlock: { authError, authData in
        if authError != nil {
          self.statusLabel.text = "Invalid login credentials"
          self.handleErrorMessage(authError)
        } else {
          let userId = authData.uid
          self.setLoggedInUserId(userId)
          self.createServerDemoClass(userId)
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

