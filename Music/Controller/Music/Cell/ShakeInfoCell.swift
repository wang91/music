//
//  ShakeInfoCell.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/16.
//

import UIKit
protocol ShakeInfoCellDelegate:NSObjectProtocol {
    func selectedButton(row:Int,index:Int,status:Bool)
    func changeVolume(row:Int)
}
class ShakeInfoCell: UITableViewCell {
    
    var model:ShakeModel = ShakeModel()
    weak var delegate:ShakeInfoCellDelegate?
    
    @IBOutlet weak var BtnTitle: UIButton!
    
    @IBOutlet weak var butonView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func config(data:[ShakeModel],index:Int) {
        model = data[0]
        self.tag = index
        BtnTitle.setTitle(model.imageName, for: .normal)
        
        for sub in butonView.subviews {
            if sub.isKind(of: UIButton.self), let btn = sub as? UIButton {
                btn.isSelected = data[btn.tag].status
                if btn.isSelected {
                    btn.backgroundColor = data[0].color
                }else{
                    btn.backgroundColor = .darkGray
                }
            }
        }
    }
    @IBAction func changeButtonStatus(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.backgroundColor = model.color
        }else{
            sender.backgroundColor = .darkGray
        }
        delegate?.selectedButton(row: self.tag, index: sender.tag, status: sender.isSelected)
    }
    
    @IBAction func changeVolume(_ sender: UIButton) {
        delegate?.changeVolume(row: self.tag)
    }
    
}
