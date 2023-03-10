//
//  RecordMIDIController.swift
//  Music
//  使用系统方法播放midi文件及加载SF2文件
//  Created by YouKe Wang on 2023/2/22.
//

import UIKit
import AudioKit
import AVFAudio

import SwiftUI

class RecordMIDIController: UIViewController {

    @IBOutlet weak var SF2View: UIView!
    @IBOutlet weak var SF2Btn: UIButton!
    @IBOutlet weak var SF2Name: UILabel!
    
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var currentL: UILabel!
    @IBOutlet weak var totalL: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var midiURL:URL!
    var bankName:String = "Bassoon"
    
    var timer:Timer?
    
    var bankArr:Array<String> = ["Bassoon","Accordion","Clarinet","Guitar Harmonics","MT-32 Drum Kit","Shannai","Violin","Rock Piano","Cyberpunk","Electric_Piano","Grand_Piano"]
    
    var engine = AVAudioEngine()
    var sampler = AVAudioUnitSampler()
    var sequencer = AVAudioSequencer()
    var duration:Double = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        initAudio()
    }
    func addSubViews() {
        let trackView = UIHostingController(rootView: TrackView(fileURL: midiURL))
        trackView.view.backgroundColor = .white
        trackView.view.frame = CGRect(x: 0, y: 200, width: JKSScreenWidth, height: 300)
        self.view.addSubview(trackView.view)
    }
    func initAudio() {
        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        sequencer = AVAudioSequencer()
        sequencer.rate = 0.8
        engine.attach(sampler)
        // 节点 node 的 bus 0 是输出，
        // bus 1 是输入
        let outputHWFormat = engine.outputNode.outputFormat(forBus: 0)
        engine.connect(sampler, to: engine.mainMixerNode, format: outputHWFormat)

        // 载入资源
        guard let bankURL = Bundle.main.url(forResource: self.bankName, withExtension: "sf2") else {
            fatalError("\(self.bankName).sf2 file not found.")
        }
        
        do {
            try
                self.sampler.loadSoundBankInstrument(at: bankURL,
                    program: 0,
                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                    bankLSB: UInt8(kAUSampler_DefaultBankLSB))
            try engine.start()
        } catch {
            print(error)
        }
            
        sequencer = AVAudioSequencer(audioEngine: engine)
        do {
            try sequencer.load(from: self.midiURL,options: .smf_ChannelsToTracks)
            print("loaded \(String(describing: midiURL))")
        } catch {
            fatalError("something screwed up while loading midi file \n \(error)")
        }
        // 指定每个track的dest AudioUnit
        for track in sequencer.tracks {
            track.destinationAudioUnit = self.sampler
        }
        duration = sequencer.tracks.first?.lengthInSeconds ?? 10.0

        self.totalL.text = String(format: "%.1fs", duration)
    }
    @IBAction func playmidi(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            
            sequencer.prepareToPlay()
            do {
                
                try sequencer.start()
                timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
            } catch {
                print("\(error)")
            }
        }else{
            stopPlay()
        }
    }
    func stopPlay() {
        sequencer.stop()
        timer?.invalidate()
        self.currentL.text = "0.0s"
        self.playBtn.isSelected = false
    }
    @objc func updateSlider() {
//        JKprint(sequencer.currentPositionInSeconds,duration)
        self.slider.setValue(Float(sequencer.currentPositionInSeconds/duration), animated: true)
        self.currentL.text = String(format: "%.1fs", sequencer.currentPositionInSeconds)
        if sequencer.currentPositionInSeconds >= duration {
            stopPlay()
        }
    }
    @IBAction func chooseSoundfile(_ sender: UIButton) {
        let alert = UIAlertController(title: "选择SF2", message: nil, preferredStyle: .actionSheet)
        for item in bankArr {
            alert.addAction(UIAlertAction(title: item, style: .default, handler: { action in
                guard let _ = Bundle.main.url(forResource: item, withExtension: "sf2") else {
                    fatalError("\"sf2\" file not found.")
                }
                self.SF2Name.text = item
                self.bankName = item
                self.initAudio()
                
            }))
        }
        alert.addAction(UIAlertAction(title:"取消", style: .cancel))
        self.present(alert, animated: true)
        
    }
}
