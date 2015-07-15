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

        // Do any additional setup after loading the view.
    }
  
  @IBOutlet weak var usernameField: UITextField!
  

  @IBOutlet weak var passwordField: UITextField!
  
  
  @IBAction func loginButton() {
    if let username = usernameField.text {
      if let password = passwordField.text {
        println("username is \(username) password is \(password)")
      }
    }
  }

}
