//
//  MIDIPlayCell.swift
//  Music
//
//  Created by YouKe Wang on 2023/3/5.
//

import UIKit
import Foundation

class MIDIPlayCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var sliderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func config(text:String) {
        name.text = text
        sliderView.backgroundColor = UIColor(red: CGFloat(arc4random()%220) / 255.0, green: CGFloat(arc4random()%220) / 255.0, blue: CGFloat(arc4random()%220) / 255.0, alpha: 1.0)
    }
}
