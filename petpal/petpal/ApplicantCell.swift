//
//  ApplicantCell.swift
//  petpal
//
//  Created by Owen Wong on 3/10/26.
//

import UIKit

class ApplicantCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    var acceptAction: (() -> Void)?
    var rejectAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func acceptTapped(_ sender: Any) {
        acceptAction?()
    }
    
    @IBAction func rejectTapped(_ sender: Any) {
        rejectAction?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
