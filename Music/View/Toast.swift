//
//  Toast.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/22.
//

import Foundation

let ProgressHud = UnsafeRawPointer.init(bitPattern: "ProgressHud".hashValue)

class JKToast: NSObject {
    // default 菊花
    class func showDefault(_ auto:Bool = false){
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: UIApplication.shared.mainAppWindow()!, animated: true)
            hud.bezelView.style = .solidColor
            hud.bezelView.backgroundColor = UIColor(red: 19/255.0, green: 22/255.0, blue: 36/255.0, alpha: 0.72)
            hud.contentColor = .white
            hud.removeFromSuperViewOnHide = true
            hud.tag = 100
            if auto {
                hud.hide(animated: true, afterDelay: 20.0)
            }
        }
    }
    class func hideDefault(){
        DispatchQueue.main.async {
            let bool =  MBProgressHUD.hide(for: UIApplication.shared.mainAppWindow()!, animated: true)
            if !bool {
                let hud = UIApplication.shared.mainAppWindow()?.viewWithTag(100)
                if let toast = hud as? MBProgressHUD {
                    toast.hide(animated: true)
                }else{
                    print("hud error")
                }
            }
        }
    }
    // 纯文字
    class func showToast(title:String){
        if title.count == 0 {
            return
        }
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: keyWindow!, animated: true)
            hud.removeFromSuperViewOnHide = true
            hud.bezelView.style = .solidColor
            hud.bezelView.backgroundColor = UIColor(red: 19/255.0, green: 22/255.0, blue: 36/255.0, alpha: 0.72)
            hud.mode = .text
            hud.label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            hud.label.text = title
            hud.label.numberOfLines = 0
            hud.label.textColor = .white
            hud.hide(animated: true, afterDelay: 2.0)
        }
    }
    // 黑色菊花
    class func showBlack() {
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: UIApplication.shared.mainAppWindow()!, animated: true)
            hud.bezelView.style = .solidColor
            hud.bezelView.backgroundColor = UIColor(red: 19/255.0, green: 22/255.0, blue: 36/255.0, alpha: 0.72)
            hud.contentColor = .white
            hud.removeFromSuperViewOnHide = true
            hud.hide(animated: true, afterDelay: 5.0)
        }
    }
    class func showLoadingToast(title:String) {
        if title.count == 0 {
            return
        }
        let hud = objc_getAssociatedObject(keyWindow!, ProgressHud!) as? MBProgressHUD
        
        if ((hud?.superview) != nil) {
            return
        }
        DispatchQueue.main.async {
            let hud2 = MBProgressHUD.showAdded(to: keyWindow!, animated: true)
            hud2.removeFromSuperViewOnHide = true
            hud2.bezelView.style = .solidColor
            hud2.bezelView.backgroundColor = UIColor(red: 19/255.0, green: 22/255.0, blue: 36/255.0, alpha: 0.72)
            hud2.mode = .text
            hud2.label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            hud2.label.text = title
            hud2.label.textColor = .white
            objc_setAssociatedObject(keyWindow!, ProgressHud!, hud2, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
    }
    class func hideLoadingToast() {
        let hud = objc_getAssociatedObject(keyWindow!, ProgressHud!) as? MBProgressHUD
        if hud != nil {
            hud?.hide(animated: true)
        }
    }
}
