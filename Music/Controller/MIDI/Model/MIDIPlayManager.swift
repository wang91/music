//
//  MIDIPlayManager.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/17.
//

import UIKit
import AudioKit

class MIDIPlayManager: NSObject {

    private var sequencer: AppleSequencer!
    private var mixer = Mixer()
    var engine = AudioEngine()
    private var drumKit = MIDISampler(name: "Drums")
    
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
}
