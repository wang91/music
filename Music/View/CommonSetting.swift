//
//  CommonSetting.swift
//  JamKoo
//
//  Created by youke on 2020/8/12.
//  Copyright © 2020 XieLulu. All rights reserved.
//

import Foundation
//屏幕宽度
let JKWidth = (UIScreen.main.bounds.width > UIScreen.main.bounds.height) ? UIScreen.main.bounds.width:UIScreen.main.bounds.height
//屏幕高度
let JKHeight = (UIScreen.main.bounds.width < UIScreen.main.bounds.height) ? UIScreen.main.bounds.width:UIScreen.main.bounds.height

var JKDeviceOrientation:UIDeviceOrientation{
    return UIDevice.current.orientation
}
var JKInterfaceOrientation:UIInterfaceOrientation = .portrait
//动态获取宽度，横竖屏
var JKSScreenWidth: CGFloat {
    return UIScreen.main.bounds.size.width
}
//动态获取高度，横竖屏
var JKSScreenHeight: CGFloat {
    return UIScreen.main.bounds.size.height
}

/// iPhone设备
let isIPhone = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone ? true : false)
/// iPad设备
let isIPad = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? true : false)

// iPhone X,iPhone Xs,iPhone 11 Pro,iPhone 12 mini
let JK_iPhoneXs = __CGSizeEqualToSize(CGSize.init(width: 375.0, height: 812.0), UIScreen.main.bounds.size)
// iPhone XR,iPhone XS Max,iPhone 11,iPhone 11 Pro Max
let JK_iPhoneXR = __CGSizeEqualToSize(CGSize.init(width: 414.0, height: 896.0), UIScreen.main.bounds.size)
// iPhone 12,iPhone 12 Pro
let JK_iPhone12 = __CGSizeEqualToSize(CGSize.init(width: 390.0, height: 844.0), UIScreen.main.bounds.size)
// iPhone 12 MAX
let JK_iPhone12MAX = __CGSizeEqualToSize(CGSize.init(width: 428.0, height: 926.0), UIScreen.main.bounds.size)
// iPhone X以上系列
let JK_iPhoneX = !isIPad && (JKHeight >= 375 && JKWidth >= 812)

// System Status bar height.
let JK_statusBarHeight:CGFloat =  0

var JK_Top_Safe_Height:CGFloat {
    if JK_iPhone12 || JK_iPhone12MAX {
        return 47
    }
    if JK_iPhoneX {
        return 44
    }
    return 0
}



let keyWindow = UIApplication.shared.mainAppWindow()
let kAppdelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate




public func JKprint(_ items: Any...,
                  separator: String = " ",
                 terminator: String = "\n",
                 _ file:String = #file,
                 _ function:String = #function,
                 _ line:Int = #line){
    #if DEBUG
    var longStr:String = ""
    for value in items{
        var stringRepresentation:String = ""
        if let valuea = value as? CustomStringConvertible{
            stringRepresentation = valuea.description
        }else if let valuee = value as? CustomDebugStringConvertible{
            stringRepresentation = valuee.debugDescription
        }else if let valuec = value as? LosslessStringConvertible{
            stringRepresentation = valuec.description
        } else{//            fatalError("glog only work for values that conform to CustomStringConvertible or CustomDebugStringConvertible")
            //            print(objct)
        }
        longStr = longStr + " " + stringRepresentation
    }
    
    let gFormatter = DateFormatter()
    gFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss:SSS"
    let timeStamp = gFormatter.string(from: Date())
    let queue = Thread.isMainThread ? "UI":"BG"
    let fileUrl = NSURL(string: file)?.lastPathComponent ?? "Unknown file"
    
    if longStr.count > items.count{
        print("JK \(timeStamp) {\(queue)} \(fileUrl) ---> \(function) [#\(line)]: \(longStr)")
    }else{
        print("JK \(timeStamp) {\(queue)} \(fileUrl) ---> \(function) [#\(line)]: \(items)")
    }
    #endif
    
}
