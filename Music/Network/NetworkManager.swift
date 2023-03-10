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
//    var baseUrl = "http://127.0.0.1:5000/convert"
    var baseUrl = "http://10.249.148.252:5001/convert"
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
            mdata.append(file, withName: name, fileName: "audio.wav",mimeType: "wav")
        }, to: baseUrl).responseJSON { (response) in
            JKprint(response.data as Any)

            if let data = response.data {
                let url = self.creatTmpMIDIFileUrl()
                do {
                    try data.write(to: url)
                   let fileuRL = self.filterMIDIFile(target: url)
                    success(fileuRL as Any)
                } catch {
                    print("midi write failed.")
                    let errorTip = NSError.init(domain: "error", code: 500, userInfo: nil)
                    fail(errorTip)
                }
                
            }else{
                let errorTip = NSError.init(domain: "error", code: 500, userInfo: nil)
                fail(errorTip)
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
    // 创建临时MIDI文件路径
    func creatTmpMIDIFileUrl() -> URL {
        let fm = FileManager.default
        
        let downloadedFile = UUID().uuidString + ".mid"
        var toUrl = fm.temporaryDirectory.appendingPathComponent(downloadedFile)
        JKprint("临时地址 == ",toUrl as Any)
        return toUrl
    }
    // 创建最终MIDI文件路径
    func creatMIDIFileUrl() -> URL {
        let fm = FileManager.default
        var toUrl = Const.HOSTED_MIDI_FOLDER
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        let timeString = dateFormatter.string(from: Date())
        // 用当前时间作为mid文件名称
        let downloadedFile = timeString + ".mid"
        
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
        return toUrl!
    }
    func filterMIDIFile(target:URL) ->URL?{

        guard let sequence = try? MIKMIDISequence(fileAt: target) else {
            return nil
        }
        for track in sequence.tracks {
            var array = track.events
            array.removeAll()
            for i in 0..<track.events.count {
                let event = track.events[i]
                if event.eventType.rawValue != 15 {
                    array.append(event)
                }
            }
            track.events = array
        }
        let url = self.creatMIDIFileUrl()
        do {
            try sequence.write(to: url)
            JKprint("写入成功",url.absoluteString as Any)
            return url
        }catch let error {
            JKprint("写入错误",url.absoluteString as Any,error.localizedDescription)
            return nil
        }
        
    }
}
