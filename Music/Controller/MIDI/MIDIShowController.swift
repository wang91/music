//
//  MIDIShowController.swift
//  Music
//
//  Created by YouKe Wang on 2023/3/2.
//

import UIKit
import MIDIPianoRollView
import AudioKit

class MIDIShowController: UIViewController {

    @IBOutlet weak var SF2View: UIView!
    @IBOutlet weak var SF2Btn: UIButton!
    @IBOutlet weak var SF2Name: UILabel!
    
    @IBOutlet weak var MIDIView: UIView!
    @IBOutlet weak var MIDIBtn: UILabel!
    @IBOutlet weak var MIDIName: UILabel!
    
    @IBOutlet weak var pianoView: MIDIPianoRollView!
    
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var currentL: UILabel!
    @IBOutlet weak var totalL: UILabel!
    @IBOutlet weak var playSlider: UISlider!
    
    @IBOutlet weak var tempoView: UIView!
    @IBOutlet weak var tempoL: UILabel!
    @IBOutlet weak var tempoSlider: UISlider!
    
    let engine = AudioEngine()
    var sequencer: AppleSequencer = AppleSequencer()
    var sampler: MIDISampler = MIDISampler()
    var trackTimer: Timer = Timer()
    
    var midiFile:URL?
    var sf2File:URL?
    
    var bankArr:Array<String> = ["Bassoon","Accordion","Clarinet","Guitar Harmonics","MT-32 Drum Kit","Shannai","Violin","Electric_Piano","Standard","other"]
    var midiArr:Array<String> = ["sibeliusGMajor","other"]
    
    var notes: [MIDIPianoRollNote] = [
      MIDIPianoRollNote(
        midiNote: 60,
        velocity: 90,
        position: MIDIPianoRollPosition(bar: 0, beat: 0, subbeat: 0, cent: 0),
        duration: MIDIPianoRollPosition(bar: 0, beat: 2, subbeat: 0, cent: 0)),
      MIDIPianoRollNote(
        midiNote: 58,
        velocity: 90,
        position: MIDIPianoRollPosition(bar: 0, beat: 3, subbeat: 0, cent: 0),
        duration: MIDIPianoRollPosition(bar: 0, beat: 2, subbeat: 0, cent: 0)),
      MIDIPianoRollNote(
        midiNote: 60,
        velocity: 90,
        position: MIDIPianoRollPosition(bar: 1, beat: 3, subbeat: 3, cent: 0),
        duration: MIDIPianoRollPosition(bar: 0, beat: 4, subbeat: 2, cent: 0)),
      MIDIPianoRollNote(
        midiNote: 56,
        velocity: 90,
        position: MIDIPianoRollPosition(bar: 3, beat: 1, subbeat: 2, cent: 0),
        duration: MIDIPianoRollPosition(bar: 0, beat: 3, subbeat: 0, cent: 0)),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initPlayer()
        startEngine()
        initMIDIView()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPlay()
        stopEngine()
    }
    func initPlayer() {
        engine.output = Reverb(sampler, dryWetMix: 0.5)
    }
    func initMIDIView() {
        MIDIPianoRollView.GridLine.rowVertical.color = .lightGray
        MIDIPianoRollView.GridLine.rowVertical.width = 4
//        pianoView.pianoRollDelegate = self
        pianoView.keys = .ranged(60...80)
        pianoView.notes = notes
        pianoView.bars = .fixed(10) // 4-bars
        pianoView.maxZoomLevel = .thirtysecondNotes
        pianoView.measureLayer.backgroundColor = .white
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
    func startPlay() {
        
        sequencer.play()
        trackTimer = Timer(timeInterval: 0.01, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        RunLoop.main.add(trackTimer, forMode: .common)
    }
    func stopPlay() {
        sequencer.stop()
        sequencer.setTime(0)
        trackTimer.invalidate()
    }
    @objc func update() {
        trackTimer.invalidate()
        startPlay()
    }
    open func loadMIDIFile() {
        guard let midiName = midiFile else {
            return
        }
        sequencer.loadMIDIFile(fromURL: midiName)
        sequencer.setGlobalMIDIOutput(sampler.midiIn)
        sequencer.setTime(0)
    }
    open func loadSF2File() {
        guard let sf2Name = sf2File else {
            JKprint("load sf2 error")
            return
        }
        do {
            try sampler.loadInstrument(url: sf2Name)
        } catch {
            JKprint("SF2 load error",sf2Name.absoluteString)
        }
    }
    func midiFileToNoteData() {
        guard let midi = midiFile else {
            JKprint("load midi error")
            return
        }
        notes.removeAll()
        let sequence = try! MIKMIDISequence(fileAt: midi)
        var i = 0 , j = 0
        for track in sequence.tracks {
            for event in track.notes {
                
                JKprint("duration ==", event.note,event.duration, event.channel,i%4,j)
                notes.append(MIDIPianoRollNote(midiNote: event.note, velocity: event.velocity, position: MIDIPianoRollPosition(bar: Int(j), beat: Int(i%4), subbeat: 0, cent: 0), duration: MIDIPianoRollPosition(bar: 0, beat: Int(1), subbeat: 0, cent: 0)))
                i = i + 1
                j = j + 1
            }
        }
        pianoView.notes = notes
    }
    @IBAction func chooseSF2File(_ sender: UIButton) {
        let alert = UIAlertController(title: "选择SF2", message: nil, preferredStyle: .actionSheet)
        for item in bankArr {
            alert.addAction(UIAlertAction(title: item, style: .default, handler: { action in
                guard let bankURL = Bundle.main.url(forResource: item, withExtension: "sf2") else {
                    JKprint("\"sf2\" file not found.")
                    return
                }
                if item != "other" {
                    self.SF2Name.text = item
                    self.sf2File = bankURL
                    self.loadSF2File()
                }
            }))
        }
        alert.addAction(UIAlertAction(title:"取消", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @IBAction func chooseMIDIFile(_ sender: UIButton) {
        let alert = UIAlertController(title: "选择MIDI File", message: nil, preferredStyle: .actionSheet)
        for item in midiArr {
            alert.addAction(UIAlertAction(title: item, style: .default, handler: { action in
                guard let midiURL = Bundle.main.url(forResource: item, withExtension: "mid") else {
                    JKprint("\"mid\" file not found.")
                    return
                }
                if item != "other" {
                    self.MIDIName.text = item
                    self.midiFile = midiURL
                    self.loadMIDIFile()
                    //解析midi
                    self.midiFileToNoteData()
                }
                
            }))
        }
        alert.addAction(UIAlertAction(title:"取消", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @IBAction func playMIDI(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            startPlay()
        }else{
            stopPlay()
        }
        
    }
    @IBAction func tempoChanged(_ sender: UISlider) {
        tempoL.text = String(format: "%.0f", sender.value)
        sequencer.setTempo(BPM(sender.value))
    }
    
}
