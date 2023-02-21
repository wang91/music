//
//  MIDIPlayController.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/10.
//

import UIKit
import AudioKit
import AVFoundation

class MIDIPlayController: UIViewController {

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
    
    var midiUrl:URL?
    var bankUrl:URL?
    
    var timer:Timer?
    
    var bankArr:Array<String> = ["Bassoon","Accordion","Clarinet","Guitar Harmonics","MT-32 Drum Kit","Shannai","Violin","Rock Piano"]
    var midiArr:Array<String> = ["sand-1","ntbldmtn","sibeliusGMajor"]
    var midiPlayer:AVMIDIPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let bankURL = Bundle.main.url(forResource: "Bassoon", withExtension: "sf2") else {
            fatalError("\"sibeliusGMajor.mid\" file not found.")
        }
        self.bankUrl = bankURL
        guard let midiFileURL = Bundle.main.url(forResource: "sand-1", withExtension: "mid") else {
            fatalError("\"sibeliusGMajor.mid\" file not found.")
        }
        self.midiUrl = midiFileURL
        createAVMIDIPlayerFromMIDIFIle()
    }

    
    func createAVMIDIPlayerFromMIDIFIle() {
            
        guard let midiFileURL = self.midiUrl else {
            fatalError("\"sibeliusGMajor.mid\" file not found.")
        }
        
        guard let bankURL = self.bankUrl else {
            fatalError("\"GeneralUser GS MuseScore v1.442.sf2\" file not found.")
        }
        
        do {
            try self.midiPlayer = AVMIDIPlayer(contentsOf: midiFileURL, soundBankURL: bankURL)
            Log("created midi player with sound bank url \(bankURL)")
        } catch let error as NSError {
            Log("Error \(error.localizedDescription)")
        }
        
        self.midiPlayer.prepareToPlay()
        self.midiPlayer.rate = 1.0 // default
        
        Log("Duration: \(midiPlayer.duration)")
        self.totalL.text = String(format: "%.1fs", midiPlayer.duration)
    }
    @IBAction func playmidi(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
            self.midiPlayer.play({
                Log("finished")
                DispatchQueue.main.async {
                    self.midiPlayer.currentPosition = 0
                    self.currentL.text = "0.0s"
                    self.slider.value = 0.0
                    self.timer?.invalidate()
                }
            })
        }else{
            if midiPlayer.isPlaying {
                midiPlayer.stop()
                self.timer?.invalidate()
            }
        }
    }
    @objc func updateSlider() {
        self.slider.setValue(Float(midiPlayer.currentPosition/midiPlayer.duration), animated: true)
        self.currentL.text = String(format: "%.1fs", midiPlayer.currentPosition)
    }
    @IBAction func chooseSoundfile(_ sender: UIButton) {
        let alert = UIAlertController(title: "选择SF2", message: nil, preferredStyle: .actionSheet)
        for item in bankArr {
            alert.addAction(UIAlertAction(title: item, style: .default, handler: { action in
                guard let bankURL = Bundle.main.url(forResource: item, withExtension: "sf2") else {
                    fatalError("\"sf2\" file not found.")
                }
                self.SF2Name.text = item
                self.bankUrl = bankURL
                self.createAVMIDIPlayerFromMIDIFIle()
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
                self.midiUrl = bankURL
                self.createAVMIDIPlayerFromMIDIFIle()
            }))
        }
        alert.addAction(UIAlertAction(title:"取消", style: .cancel))
        self.present(alert, animated: true)
    }
    

}
