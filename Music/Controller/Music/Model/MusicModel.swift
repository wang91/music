//
//  MusicModel.swift
//  Music
//
//  Created by YouKe Wang on 2023/3/7.
//

import UIKit
import AVFAudio

class MusicModel: NSObject {
    var name:String = ""
    var color:UIColor = .darkGray
    var rowIndex:Int = 0//行
    var avFile:AVAudioFile?
    var lineIndex:Int = 0//列
    var status:Bool = false
}
