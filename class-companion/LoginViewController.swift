
//
//  LoginViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/14/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  
  let userDefaults = NSUserDefaults.standardUserDefaults()
  let usernameKeyConstant = "usernameKey"
  let userIsAuthenticatedConstant = "userLoggedIn"

  override func viewDidLoad() {
    super.viewDidLoad()
    
    handleUserAlreadyLoggedIn()
      

  }
  

  
  
  @IBOutlet weak var usernameField: UITextField!
  

  @IBOutlet weak var passwordField: UITextField!
  
  
  @IBOutlet weak var statusLabel: UILabel!
  
  @IBAction func loginButton() {
    if let username = usernameField.text {
      if let password = passwordField.text {
//        println("username is \(username) password is \(password)")
        let loginResult = checkLoginCredentials(username, password: password)
        if loginResult {
          userDefaults.setObject(true, forKey: userIsAuthenticatedConstant)
          goToTeacherDashboardView()
        } else {
          statusLabel.text = "Invalid login credentials"
        }
      }
    }
  }
  
  func handleUserAlreadyLoggedIn (){
    if let userLoggedIn = userDefaults.stringForKey(userIsAuthenticatedConstant) {
      println("Is the user already logged in? \(userLoggedIn)")
      goToTeacherDashboardView()
    } else {
      println("User is not logged in")
    }
  }
  
  func goToTeacherDashboardView () {
    self.performSegueWithIdentifier("showTeacherDashboard", sender: self)
  }
  
  func checkLoginCredentials(username: String, password: String) -> Bool {
    
    if username == "Username" && password == "Password" {
      return true
    } else {
      return false
    }
    
  }
  

}
