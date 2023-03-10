//
//  ShakeTopCell.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/15.
//

import UIKit
protocol ShakeTopCellDelegate:NSObjectProtocol {
    func addNewMusic()
}
class ShakeTopCell: UITableViewCell {

    weak var delegate:ShakeTopCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func addNewMusicTrack(_ sender: UIButton) {
        delegate?.addNewMusic()
    }
}
