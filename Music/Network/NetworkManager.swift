//
//  NetworkManager.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/22.
//

import UIKit
import Alamofire
import SwiftCommonTools2

typealias SuccessBlock = (_ result: Any) -> Void
typealias Fail = (_ error: NSError) -> Void

class NetworkManager: NSObject {
    
    static let netWork = NetworkManager()
    
    var baseUrl = "http://10.249.149.153:5001/convert"
    //MARK:- post请求
    func postNetwork(url:String,params:[String:Any]?,_ needToast:Bool = false,success:@escaping  SuccessBlock,fail:@escaping Fail){
        
        AF.request(baseUrl, method: .post, parameters:params, encoding: JSONEncoding.default, headers:configHeader()).responseJSON { (response) in
            print(response.value as Any)
            switch response.result {
                
            case .success(_):
                success(response.value as Any)
                break
            case .failure(_):
                if  let error = response.error as NSError?{
                    let errorTip = NSError.init(domain: "error", code: error.code, userInfo: nil)
                    fail(errorTip)
                }
                break
            }
        }
    }
    //MARK:- 上传音频
    func uploadAudio(url:String,file:URL,name:String,success:@escaping SuccessBlock,fail:@escaping Fail){
        AF.upload(multipartFormData: { mdata in
            mdata.append(file, withName: name, fileName: "sand-1.wav",mimeType: "wav")
        }, to: baseUrl).responseJSON { (response) in
            print(response.response as Any,response.data as Any)
            if let data = response.data {
                let fm = FileManager.default
                var toUrl = Const.HOSTED_MIDI_FOLDER
                let downloadedFile = "download" + ".midi"
                
                // Create SoundLibrary folder if not exists
                if !fm.fileExists(atPath: toUrl!.path){
                    do {
                        try fm.createDirectory(at: toUrl!, withIntermediateDirectories: true, attributes: nil)
                        print("Folder created:\(String(describing: toUrl?.lastPathComponent))")
                    } catch let err {
                        print("ERROR: create 'SoundLibrary' in 'Application Support' folder, detail:\(err)")
                    }
                }else{
                    print("Sound library folder exists.")
                }
                toUrl?.appendPathComponent(downloadedFile)
                do {
                    try data.write(to: toUrl!)
                } catch {
                    print("midi write failed.")
                }
                
            }
            switch response.result {
                
            case .success(_):
                success(response.value as Any)
                break
            case .failure(_):
                if  let error = response.error as NSError?{
                    let errorTip = NSError.init(domain: "error", code: error.code, userInfo: nil)
                    fail(errorTip)
                }
                break
            }
        }
    }
    //MARK:- 设置header
    func configHeader() -> HTTPHeaders{
        var header = HTTPHeaders.init()
        
        header.add(name: "platform", value: "iOS")
        
        header.add(name: "system_version", value: UIDevice.current.systemVersion)
//        JKprint("🔑🔑🔑🔑accessToken:\(JKUserManager.accessToken())")
        header.add(name: "Content-Type", value: "multipart/form-data")
        
        return header
    }
}
