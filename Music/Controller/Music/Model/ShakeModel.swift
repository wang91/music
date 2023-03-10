//
//  ShakeModel.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/16.
//

import UIKit
import AVFAudio

class ShakeModel: NSObject {
    var imageName:String = ""
    var color:UIColor = .darkGray
    var rowIndex:Int = 0//行
    var avFile:AVAudioFile?
    var lineIndex:Int = 0//列
    var status:Bool = false
}
