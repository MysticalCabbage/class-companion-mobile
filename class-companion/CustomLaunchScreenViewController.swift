//
//  CustomLaunchScreenViewController.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/26/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class CustomLaunchScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.view.backgroundColor = UIColor(patternImage: UIImage(named: "8-bit-background.png")!)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
