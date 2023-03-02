//
//  SequencerPlayController.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/27.
//

import UIKit
import AudioKit
import AVFAudio

class SequencerPlayController: UIViewController {
    @IBOutlet weak var tempoL: UILabel!
    
    let engine = AudioEngine()
    let drums = MIDISampler(name: "Drums")
    let sequencer = AppleSequencer(fromURL: Bundle.main.url(forResource: "4tracks", withExtension: "mid")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        engine.output = Mixer(drums)
        do {
            let beatUrl = Bundle.main.url(forResource: "Amber Beat 01", withExtension: "caf")
            let beatFile = try AVAudioFile(forReading: beatUrl!)

            let saxUrl = Bundle.main.url(forResource: "Against Time Sax Sample", withExtension: "caf")
            let saxFile = try AVAudioFile(forReading: saxUrl!)

            let stringUrl = Bundle.main.url(forResource: "Against Time Staccato Strings", withExtension: "caf")
            let stringFile = try AVAudioFile(forReading: stringUrl!)

            let keysUrl = Bundle.main.url(forResource: "Against Time Keys", withExtension: "caf")
            let keysFile = try AVAudioFile(forReading: keysUrl!)

            let pianoUrl = Bundle.main.url(forResource: "Against Time Piano", withExtension: "caf")
            let pianoFile = try AVAudioFile(forReading: pianoUrl!)


            try drums.loadAudioFiles([beatFile,
                                      saxFile,
                                      stringFile,
                                      keysFile,
                                      pianoFile])

        } catch {
            Log("Files Didn't Load")
        }
        sequencer.clearRange(start: Duration(beats: 0), duration: Duration(beats: 100))
        sequencer.debug()
        sequencer.setGlobalMIDIOutput(drums.midiIn)
        sequencer.enableLooping(Duration(beats: 8))
        sequencer.setTempo(150)
        
        do {
            try engine.start()
            
        } catch let err {
            Log(err) }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        engine.stop()
    }
    @IBAction func TempoChange(_ sender: UISlider) {
        sequencer.setTempo(Double(sender.value))
        tempoL.text = String(format: "Tempo:%.1f", sender.value)
    }
    
    @IBAction func startSequcen(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            sequencer.play()
        }else{
            sequencer.stop()
        }
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        sequencer.tracks[0].add(noteNumber: 61, velocity: 120, position: Duration(beats: 0), duration: Duration(beats: 8.0))
    }
    
}
