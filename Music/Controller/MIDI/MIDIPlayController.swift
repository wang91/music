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

    private var sequencer: AppleSequencer!
    private var mixer = Mixer()
    var engine = AudioEngine()
    private var drumKit = MIDISampler(name: "Drums")
    var midiPlayer:AVMIDIPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAVMIDIPlayerFromMIDIFIle()
        
        
        
    }

    func audiKitPlayMIDI() {
        mixer = Mixer(drumKit)
        engine.output = mixer
        do {
            if let fileURL = Bundle.main.url(forResource: "drumSimp", withExtension: "exs") {
                try drumKit.loadInstrument(url: fileURL)
            } else {
                Log("Could not find file")
            }
//            if let fileURL = Bundle.main.url(forResource: "Cyberpunk", withExtension: "sf2") {
//                try drumKit.loadInstrument(url: fileURL)
//            } else {
//                Log("Could not find file")
//            }
        } catch {
            Log("A file was not found.")
        }
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start!")
        }

        sequencer = AppleSequencer(filename: "sand-1")
        sequencer.enableLooping()
        sequencer.tracks[0].setMIDIOutput(drumKit.midiIn)
        
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
    }
    @IBAction func playmidi(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
//            sequencer.play()
            self.midiPlayer.play({
                Log("finished")
                self.midiPlayer.currentPosition = 0
            })
        }else{
//            sequencer.stop()
            if midiPlayer.isPlaying {
                midiPlayer.stop()
            }
        }
    }
    

}
