//
//  TableViewCell.swift
//  Movies Database
//
//  Created by Alwin on 28/06/24.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var movieImage: UIImageView!
    @IBOutlet var movieYear: UILabel!
    @IBOutlet var movieLanguages: UILabel!
    @IBOutlet var movieTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


