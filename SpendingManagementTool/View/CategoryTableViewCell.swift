//
//  CategoryTableViewCell.swift
//  SpendingManagementTool
//
//  Created by Fazal on 13/05/2021.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var labelCategoryName: UILabel!
    @IBOutlet weak var labelCategoryBudget: UILabel!
    @IBOutlet weak var labelCategoryNotes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

