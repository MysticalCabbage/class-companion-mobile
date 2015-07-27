//
//  BehaviorCollectionViewCell.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/18/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class BehaviorCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var behaviorNameLabel: UILabel!
  @IBOutlet weak var behaviorValueLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupBackgroundTile()
  }
  
  func setupBackgroundTile() {
    self.layer.borderWidth = 2
    self.layer.borderColor = UIColor.blackColor().CGColor
  }

}
