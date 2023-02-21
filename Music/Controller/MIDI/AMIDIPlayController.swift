//
//  AMIDIPlayController.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/21.
//

import UIKit
import AudioKit
import AVFAudio

class AMIDIPlayController: UIViewController {

    @IBOutlet weak var SF2View: UIView!
    @IBOutlet weak var SF2Btn: UIButton!
    @IBOutlet weak var SF2Name: UILabel!
    
    @IBOutlet weak var MIDIView: UIView!
    @IBOutlet weak var MIDIBtn: UIButton!
    @IBOutlet weak var MIDIName: UILabel!
    
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var currentL: UILabel!
    @IBOutlet weak var totalL: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var midiName:String = "Demo"
    var bankName:String = "Bassoon"
    
    var timer:Timer?
    
    var bankArr:Array<String> = ["Bassoon","Accordion","Clarinet","Guitar Harmonics","MT-32 Drum Kit","Shannai","Violin","Rock Piano","Cyberpunk"]
    var midiArr:Array<String> = ["Demo","sand-1","ntbldmtn","sibeliusGMajor"]
    
    var engine = AVAudioEngine()
    var sampler = AVAudioUnitSampler()
    var sequencer = AVAudioSequencer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAudio()
    }
    func initAudio() {
        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        sequencer = AVAudioSequencer()
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
        guard let fileURL = Bundle.main.url(forResource: self.midiName, withExtension: "mid") else {
            fatalError("\"sibeliusGMajor.mid\" file not found.")
        }

        do {
            try sequencer.load(from: fileURL,options: .smf_ChannelsToTracks)
            print("loaded \(fileURL)")
        } catch {
            fatalError("something screwed up while loading midi file \n \(error)")
        }
        // 指定每个track的dest AudioUnit
        for track in sequencer.tracks {
            track.destinationAudioUnit = self.sampler
        }


        
    }
    @IBAction func playmidi(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            
            sequencer.prepareToPlay()
            do {
                
                try sequencer.start()
            } catch {
                print("\(error)")
            }
        }else{
            sequencer.stop()
        }
    }
    @objc func updateSlider() {
        
        
    }
    @IBAction func chooseSoundfile(_ sender: UIButton) {
        let alert = UIAlertController(title: "选择SF2", message: nil, preferredStyle: .actionSheet)
        for item in bankArr {
            alert.addAction(UIAlertAction(title: item, style: .default, handler: { action in
                guard let bankURL = Bundle.main.url(forResource: item, withExtension: "sf2") else {
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
    @IBAction func chooseMIDIFile(_ sender: UIButton) {
        let alert = UIAlertController(title: "选择MIDI File", message: nil, preferredStyle: .actionSheet)
        for item in midiArr {
            alert.addAction(UIAlertAction(title: item, style: .default, handler: { action in
                guard let bankURL = Bundle.main.url(forResource: item, withExtension: "mid") else {
                    fatalError("\"sf2\" file not found.")
                }
                self.MIDIName.text = item
                self.midiName = item
                
                self.initAudio()
            }))
        }
        alert.addAction(UIAlertAction(title:"取消", style: .cancel))
        self.present(alert, animated: true)
    }
    


}
