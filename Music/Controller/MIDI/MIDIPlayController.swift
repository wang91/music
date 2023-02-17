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
    
    
    var midiPlayer:AVMIDIPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        createAVMIDIPlayerFromMIDIFIle()
    }

    
    func createAVMIDIPlayerFromMIDIFIle() {
            
        guard let midiFileURL = Bundle.main.url(forResource: "sand-1", withExtension: "mid") else {
            fatalError("\"sibeliusGMajor.mid\" file not found.")
        }
        
        guard let bankURL = Bundle.main.url(forResource: "Cyberpunk", withExtension: "sf2") else {
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
        
    }
    @IBAction func chooseMIDIFile(_ sender: UIButton) {
        
    }
    

}
