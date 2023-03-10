//
//  RecordController.swift
//  MusicStudio
//
//  Created by YouKe Wang on 2023/2/8.
//

import UIKit
import AudioRecorder
import SwiftCommonTools2
import AVFAudio
import SwiftUI

class RecordController: UIViewController, AudioRecorderDelegate {

    @IBOutlet weak var duration: UILabel!
    private var audioRecorder: AudioRecorder?

    @IBOutlet weak var btnRecord: UIButton!
    private var recordFile:AVAudioFile?
    private var recordPlayer:AVAudioPlayer?
    var recordTimer: Timer?
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var titmeL: UILabel!
    @IBOutlet weak var totalL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        duration.text = "0 / 180s"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func record(_ sender: UIButton) {
        if audioRecorder == nil {
            guard let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
                return
            }
            let voiceDir = URL(fileURLWithPath: docPath)
            let audioRecorder = AudioRecorder(voiceDirectory: voiceDir, maxDuration: 180)
            audioRecorder.delegate = self
            self.audioRecorder = audioRecorder
        }
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            sender.setTitle("Record", for: .normal)
            return
        }
        do {
            try audioRecorder?.record(voiceName: UUID().uuidString)
            sender.setTitle("Stop Record", for: .normal)
        } catch(let error) {
            Log.e("录制出错 \(error)")
        }
    }
    
    func onAudoRecorderStatusChanged(_ recorder: AudioRecorder, _ status: AudioRecorderStatus) {
        switch status {
        case .recording(let time, let duration):
            Log.i("录制中，时间变化 time = \(time), duration = \(duration)")
            self.duration.text = "\(time) / \(duration)s"
        case .powerChanged(let power):
            Log.i("音量大小变化……", power)
        case .pause:
            Log.i("音频录制暂停了……")
        case .stop:
            Log.i("录制的音频路径：", recorder.voiceURL ?? "")
            totalL.text = String(format: "%.1fs", Float(recorder.duration ?? 0))
            do {
                try recordFile = AVAudioFile(forReading: recorder.voiceURL!)
                recordPlayer = try AVAudioPlayer.init(contentsOf: recordFile!.url)
                recordPlayer?.prepareToPlay()
            } catch {
                Log.i("Error loading recording file.")
            }
        }
    }
//MARK: - 播放录音
    @IBAction func playOrStopRecord(_ sender: UIButton) {
        if audioRecorder?.isRecording == true {
            JKToast.showToast(title: "正在录制音频")
            return
        }
        if recordFile == nil || recordPlayer == nil {
            print("Didn't get test file1")
            JKToast.showToast(title: "请先录制音频")
            return
        }
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.recordPlayer?.play()
            recordTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        }else{
            if ((recordTimer?.isValid) != nil) {
                recordTimer?.invalidate()
            }
            self.recordPlayer?.stop()
            titmeL.text = "0.0s"
            sliderView.value = 0.0
        }
    }
    // MARK: - 更新进度条
    @objc func updateSlider() {
       
        if recordPlayer == nil {
            return
        }
        sliderView.value = Float(recordPlayer!.currentTime / recordPlayer!.duration)
        titmeL.text = String(format: "%.1fs", Float(recordPlayer!.currentTime))
        if recordPlayer!.duration - recordPlayer!.currentTime < 0.05 {
            if ((recordTimer?.isValid) != nil) {
                recordTimer?.invalidate()
            }
            self.recordPlayer?.stop()
            playBtn.isSelected = false
            recordPlayer?.currentTime = 0
            titmeL.text = "0.0s"
            sliderView.value = 0.0
        }
    }
    @IBAction func convertAudioToMIDI(_ sender: UIButton) {
        if audioRecorder?.isRecording == true {
            JKToast.showToast(title: "正在录制音频")
            return
        }
        guard let url1 = recordFile?.url else {
            JKprint("Didn't get test file1")
            JKToast.showToast(title: "请先录制音频")
            return
        }
        JKToast.showDefault()
        NetworkManager.netWork.uploadAudio(url: "", file: url1, name: "file") { result in
            JKToast.hideDefault()
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.sharedInstance().category, options: .defaultToSpeaker)
 
            if let url = result as? URL {
                print("midi 文件地址", url.absoluteString)
                let trackView = UIHostingController(rootView: TrackView(fileURL: url))
                trackView.view.backgroundColor = .white
                trackView.rootView.dismiss = {
        
                    let controller = ShakeDemoController(nibName: "ShakeDemoController", bundle: nil)
                    self.navigationController?.pushViewController(controller, animated: true)

                }
                trackView.rootView.recordSucces = { (_ file, _ bankName) in
                    JKprint("midi name",url.deletingPathExtension().lastPathComponent)
                    // 存储到指定位置
                    let fileUrl = Const.copyMIDIWavToFolder(fileUrl: file.url,midiFileName: url.deletingPathExtension().lastPathComponent,instrName: bankName)
            
                    // 文件名保存到缓存
                    JKprint(fileUrl)
                    var array = UserDefaults.getAllRecordMidFile()
                    array.append(fileUrl)
                    UserDefaults.saveAllRecordMidFile(array)
                    
                    
                }
                self.navigationController?.pushViewController(trackView, animated: true)
            }
        } fail: { error in
            JKToast.hideDefault()
        }
    }
}
