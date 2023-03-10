//
//  RootController.swift
//  MusicStudio
//
//  Created by YouKe Wang on 2023/2/8.
//

import UIKit
import SwiftUI
import AudioKit
import AVFAudio

class RootController: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    
    var dataArr:Array<String> = ["录制音频","播放MIDI文件","123"]
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "主页"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .white
        self.tableView.register(UINib(nibName: "RootCell", bundle: nil), forCellReuseIdentifier: "RootCell")
//        let settings = [AVSampleRateKey: NSNumber(value: Float(44100)),
//            AVFormatIDKey: NSNumber(value: Int(kAudioFormatLinearPCM)),
//            AVLinearPCMBitDepthKey: NSNumber(value: Int(16)),
//            AVNumberOfChannelsKey: NSNumber(value: Int(2)),
//            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.high.rawValue)]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RootCell") as? RootCell {
            cell.titleL.text = dataArr[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            recordAudio()
            break
        case 1:
            playMIDIFile()
            break
        case 2:
            playAudioFile()
            break
        default:
            break
        }
        
    }
    func recordAudio() {
        self.navigationController?.pushViewController(AudioKitRecordController(nibName: "AudioKitRecordController", bundle: nil), animated: true)
//        self.navigationController?.pushViewController(RecordController(nibName: "RecordController", bundle: nil), animated: true)
    }
    func playMIDIFile() {
        let trackView = UIHostingController(rootView: TrackView())
        trackView.view.backgroundColor = .white
        trackView.rootView.dismiss = {
//            trackView.navigationController?.popViewController(animated: true)
            JKprint("swift UI dismiss")
//            let controller = MusicPlayController(nibName: "MusicPlayController", bundle: nil)
//            controller.fileName = Const.copyMIDIWavToFolder(file: file)
//            self.navigationController?.pushViewController(controller, animated: true)
            let controller = ShakeDemoController(nibName: "ShakeDemoController", bundle: nil)
//            controller.addFile(fileName: Const.copyMIDIWavToFolder(file: file,midiFileName: "QingHuaCi",instrName: bankName))
            self.navigationController?.pushViewController(controller, animated: true)
        }
        trackView.rootView.recordSucces = { (_ file,_ bankName) in
            JKprint("record success",file.url.absoluteString as Any)
            
            let controller = ShakeDemoController(nibName: "ShakeDemoController", bundle: nil)
            let fileUrl = Const.copyMIDIWavToFolder(fileUrl: file.url,midiFileName: "QingHuaCi",instrName: bankName)
            controller.addFile(fileName: fileUrl)
            self.navigationController?.pushViewController(controller, animated: true)
            var array = UserDefaults.getAllRecordMidFile()
            array.append(fileUrl)
            UserDefaults.saveAllRecordMidFile(array)
        }
        self.navigationController?.pushViewController(trackView, animated: true)
    }
    func playAudioFile() {
        let audioVC = UIHostingController(rootView: AudioSampler())
        self.navigationController?.pushViewController(audioVC, animated: true)
    }
//    func exportMP3(){
//
//        let lame = ExtAudioConverter()
//
//        let filename = UUID().uuidString + ".mp3"
//        //此处一定要用fileURLWithPath
//        let mixPutUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
//        let file = Bundle.main.url(forResource: "QingHuaCiElectric_Piano1678264566", withExtension: "caf")
//
//        lame.inputFilePath = file!.path
//        lame.outputFilePath = mixPutUrl.path
//        lame.outputFormatID = kAudioFormatMPEGLayer3
////        lame.outputSampleRate = 8000;
////        lame.outputNumberChannels = 1;
//        lame.outputBitDepth = BitDepth_16;
//        lame.outputFileType = kAudioFileMP3Type;
//        #if DEBUG
//        JKprint("lame.inputFilePath:\(lame.inputFilePath)")
//        JKprint("lame.outputFilePath:\(lame.outputFilePath)")
//        #endif
//
//        if lame.convert() {
//            JKprint("Export to mp3 Done!")
//        }
//    }
}
extension UserDefaults {
    /// 保存所有录制的音频文件
    static func saveAllRecordMidFile(_ array: [String]) {
        UserDefaults.standard.set(array, forKey: "AllRecordMidFile")
    }
    /// 查询所有录制的音频文件
    static func getAllRecordMidFile() ->Array<String>{
        let array = UserDefaults.standard.array(forKey: "AllRecordMidFile")
        guard let result = array as? Array<String> else {
            return []
        }
        return result
    }
}
