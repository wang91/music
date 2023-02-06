//
//  ViewController.swift
//  MusicStudio
//
//  Created by YouKe Wang on 2023/2/6.
//

import UIKit

class ViewController: UIViewController {

    var dataSet:[(index:Int,status:Bool,source:String)] = []
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var addtTrackBtn: UIButton!
    
    @IBOutlet weak var trackOneView: UIView!
    
    @IBOutlet weak var trackTwoView: UIView!
    
    @IBOutlet weak var sliderView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSet.removeAll()
        for i in 0..<8 {
            dataSet.append((index: i, status: false, source: ""))
        }
        
    }


    @IBAction func addTrackAction(_ sender: UIButton) {
        print("添加新轨道")
    }
    
    @IBAction func playOrStop(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func changeButtonStatus(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            dataSet[sender.tag].status = true
            if sender.tag < 4 {
                sender.backgroundColor = .red
            }else{
                sender.backgroundColor = .blue
            }
            
        }else{
            dataSet[sender.tag].status = false
            sender.backgroundColor = UIColor.darkGray
        }
    }
    
}

