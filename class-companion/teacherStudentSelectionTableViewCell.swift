//
//  teacherStudentSelectionTableViewCell.swift
//  class-companion
//
//  Created by Jonathan Davis on 7/21/15.
//  Copyright (c) 2015 Jonathan Davis. All rights reserved.
//

import UIKit

class teacherStudentSelectionTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  @IBOutlet weak var studentNameLabel: UILabel!
  @IBOutlet weak var groupNumberLabel: UILabel!
  @IBOutlet weak var selectionStatusLabel: UILabel!
  
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
