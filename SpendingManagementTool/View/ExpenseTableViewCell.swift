//
//  ExpenseTableViewCell.swift
//  SpendingManagementTool
//
//  Created by Fazal on 13/05/2021.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var labelOccurence: UILabel!
    @IBOutlet weak var labelDueDate: UILabel!
    @IBOutlet weak var labelReminder: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
