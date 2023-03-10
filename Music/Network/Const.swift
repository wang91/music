//
//  Const.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/22.
//

import Foundation
import AVFAudio
import AVFoundation
import AudioKit

class Const:NSObject {
    // record sound folder
    static let HOSTED_SOUND_FOLDER = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last?.appendingPathComponent("sound")
    // midi folder
    static let HOSTED_MIDI_FOLDER = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last?.appendingPathComponent("midi")
    // midiRecord folder
    static let HOSTED_MIDIWAV_FOLDER = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last?.appendingPathComponent("midiWav")
    
    static func getMIDIWavRecord(fileName:String) -> URL? {
        let fm = FileManager.default
        var toUrl = Const.HOSTED_MIDIWAV_FOLDER
        let downloadedFile = fileName
        toUrl?.appendPathComponent(downloadedFile)
        if fm.fileExists(atPath: toUrl!.path) {
            JKprint("File exists:\(String(describing: toUrl?.absoluteString))")
            return toUrl
//            return URL(fileURLWithPath: toUrl!.path)
        }
        return nil
    }
    static func getMIDIWavRecordLocal(fileName:String) -> URL? {
        let fm = FileManager.default
        var toUrl = Const.HOSTED_MIDIWAV_FOLDER
        let downloadedFile = fileName
        toUrl?.appendPathComponent(downloadedFile)
        if fm.fileExists(atPath: toUrl!.path) {
            JKprint("File exists:\(String(describing: toUrl?.absoluteString))")
//            return toUrl
            return URL(fileURLWithPath: toUrl!.path)
        }
        return nil
    }
    static func copyMIDIWavToFolder(fileUrl:URL,midiFileName:String,instrName:String) -> String{
        
        
        let fm = FileManager.default
        var toUrl = Const.HOSTED_MIDIWAV_FOLDER
        // midi的名字+乐器的名字+当前时间
//        let date = Date(timeIntervalSinceNow: 0)
//        let timeInterval:TimeInterval = date.timeIntervalSince1970
//        let timeString = String(format: "%.0f", timeInterval)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        let timeString = dateFormatter.string(from: Date())
        
        let downloadedFile = midiFileName + instrName + timeString + ".wav"
        
        // Create SoundLibrary folder if not exists
        if !fm.fileExists(atPath: toUrl!.path){
            do {
                try fm.createDirectory(at: toUrl!, withIntermediateDirectories: true, attributes: nil)
                JKprint("Folder created:\(String(describing: toUrl?.lastPathComponent))")
            } catch let err {
                JKprint("ERROR: create 'SoundLibrary' in 'Application Support' folder, detail:\(err)")
                return downloadedFile
            }
        }else{
            JKprint("Sound library folder exists.")
        }
        toUrl?.appendPathComponent(downloadedFile)
        if fm.fileExists(atPath: toUrl!.path) {
            JKprint("File exists:\(String(describing: toUrl?.path))")
            do {
                try fm.removeItem(at: toUrl!)
            }catch let err {
                JKprint("ERROR: removing file \(err)")
                return ""
            }
        }
        // Move to Sound Library folder
        do {
            try fm.moveItem(at: fileUrl, to: toUrl!)
            JKprint("Sound library moved to: \(String(describing: toUrl))")
            return downloadedFile
        }catch let err {
            JKprint("ERROR: Move downloaded file:\(err)")
            return ""
        }
        
       
    }
    
    static func mixAudio(originAudio: URL, completionHandle: @escaping (_ result: Bool,_ fileUrl: URL?) -> Void) {
        let asset = AVAsset(url: URL.init(fileURLWithPath: originAudio.path))
        
        let filename = UUID().uuidString + ".m4a"
        //此处一定要用fileURLWithPath
        let mixPutUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
        exportSession!.outputURL = mixPutUrl
        exportSession!.outputFileType = .m4a
        exportSession!.shouldOptimizeForNetworkUse = true
        exportSession?.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async {
                switch exportSession!.status {
                case .failed:
                    JKprint(" 混音导出-------- fail \(exportSession!.error.debugDescription)")
                    
                case .cancelled:
                    JKprint(" 混音导出 ----- 取消")
                    
                case .completed:
                    JKprint(" 混音导出 ----- 成功",mixPutUrl.absoluteString)
                    
                default:
                    JKprint("混音导出 ---- 未知问题")
                }
            }
        })
    }
    static func converAudioFormate(file:URL,completionHandle: @escaping (_ result: Bool,_ fileUrl: URL?) -> Void) {
        
//        let settings = [AVSampleRateKey: NSNumber(value: Float(44100)),
//            AVFormatIDKey: NSNumber(value: Int(kAudioFormatMPEGLayer3)),
//            AVLinearPCMBitDepthKey: NSNumber(value: Int(16)),
//            AVNumberOfChannelsKey: NSNumber(value: Int(2)),
//            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.high.rawValue)]
        
        let tmpUrl = NSTemporaryDirectory()
        let outPurStr = "\(tmpUrl)\(file.deletingPathExtension().lastPathComponent).wav"
        let outPutUrl = URL(fileURLWithPath: outPurStr)
        
        var options = FormatConverter.Options()

        // any options left nil will adopt the value of the input file
        options.format = .wav
        options.sampleRate = 44100
        options.bitDepth = 16
        options.channels = 2
        
        let formatConverter = FormatConverter(inputURL: file, outputURL: outPutUrl,options: options)
        formatConverter.start { error in
            if error == nil {
                JKprint(outPutUrl)
                completionHandle(true, outPutUrl)
            }else{
                JKprint(error?.localizedDescription as Any)
                completionHandle(false, nil)
            }
        }
        
//        do {
//            let outputAudioFile = try AVAudioFile.init(forWriting: outPutUrl, settings: settings, commonFormat: AVAudioCommonFormat.pcmFormatInt16, interleaved: true)
//
//        } catch let error {
//            JKprint("Convert audio error:",error.localizedDescription)
//        }
        

        
    }
}
