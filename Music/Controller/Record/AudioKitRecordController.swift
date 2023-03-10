//
//  AudioKitRecordController.swift
//  Music
//  使用audioKit的录音框架
//  Created by YouKe Wang on 2023/3/9.
//

import UIKit
import AudioKit
import AudioKitEX
import SwiftUI
import AVFAudio

class AudioKitRecordController: UIViewController {

    @IBOutlet weak var duration: UILabel!

    @IBOutlet weak var btnRecord: UIButton!
    var recordTimer: Timer?
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var titmeL: UILabel!
    @IBOutlet weak var totalL: UILabel!
    
    let engine = AudioEngine()
    var recorder: NodeRecorder?
    let player = AudioPlayer()
    var silencer: Fader?
    let mixer = Mixer()
    
    var isPlaying:Bool = false {
        didSet {
            playBtn.isSelected = isPlaying
            if isPlaying {
                if let file = recorder?.audioFile {
                    player.file = file
                    player.play()
                    recordTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
                }
            } else {
                stopTimer()
                player.stop()
            }
        }
    }
    var isRecording:Bool = false {
        didSet {
            btnRecord.isSelected = isRecording
            if isRecording {
                do {
                    try recorder?.record()
                    recordTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
                } catch let err {
                    JKprint(err)
                }
            } else {
                stopTimer()
                recorder?.stop()
                totalL.text = String(format: "%.1fs", recorder?.audioFile?.duration ?? "0.0")
                duration.text = "0.0 / 180s"
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initEngine()
        duration.text = "0.0 / 180s"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startEngine()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopEngine()
    }
    func initEngine() {
        guard let input = engine.input else {
            fatalError()
        }

        do {
            recorder = try NodeRecorder(node: input)
            
            
        } catch let err {
            fatalError("\(err)")
        }
        let silencer = Fader(input, gain: 0)
        self.silencer = silencer
        mixer.addInput(silencer)
        mixer.addInput(player)
        engine.output = mixer
    }
    func startEngine() {
        do {
            try engine.start()
        } catch {
            
        }
    }
    func stopEngine() {
        engine.stop()
    }
    func stopTimer() {
        if ((recordTimer?.isValid) != nil) {
            recordTimer?.invalidate()
        }
    }
    // MARK: - 更新进度条
    @objc func updateSlider() {
        if isRecording {
            self.duration.text = "\(recorder?.recordedDuration ?? 0.0) / \(180)s"
        }
        if isPlaying {
            sliderView.value = Float(player.getCurrentTime() / player.duration)
            titmeL.text = String(format: "%.1fs", player.getCurrentTime())
            if player.getCurrentTime() >= player.duration {
                isPlaying = false
            }
        }
        
    }
    @IBAction func startRecord(_ sender: UIButton) {
        isRecording = !sender.isSelected
    }
    
    @IBAction func startPlay(_ sender: UIButton) {
        isPlaying = !sender.isSelected
    }
    
    @IBAction func nextStep(_ sender: UIButton) {
        if let file = recorder?.audioFile?.url {
            

            JKToast.showDefault()
            NetworkManager.netWork.uploadAudio(url: "", file: file, name: "file") { result in
                JKToast.hideDefault()
                try! AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers])
                if let url = result as? URL {
                    print("midi 文件地址", url.absoluteString)
                    let trackView = UIHostingController(rootView: TrackView(fileURL: url))
                    trackView.view.backgroundColor = .white
                    trackView.rootView.dismiss = {
            
                        let controller = MusicPlayController(nibName: "MusicPlayController", bundle: nil)
                        self.navigationController?.pushViewController(controller, animated: true)

                    }
                    trackView.rootView.recordSucces = { (_ file, _ bankName) in
                        JKprint("midi name",url.deletingPathExtension().lastPathComponent)
                        
                        self.convertAudio(file: file, name: url.deletingPathExtension().lastPathComponent,bankName: bankName)
                        
                    }
                    self.navigationController?.pushViewController(trackView, animated: true)
                }
            } fail: { error in
                JKToast.hideDefault()
            }
        }
    }
    func convertAudio(file:AVAudioFile,name:String,bankName:String) {
        Const.converAudioFormate(file: file.url, completionHandle: { result, fileUrl in
            if result {
                // 存储到指定位置
               let fileUrl = Const.copyMIDIWavToFolder(fileUrl: fileUrl!,midiFileName: name,instrName: bankName)
        
                // 文件名保存到缓存
                JKprint(fileUrl)
                var array = UserDefaults.getAllRecordMidFile()
                array.append(fileUrl)
                UserDefaults.saveAllRecordMidFile(array)
            }
        })

    }
}
