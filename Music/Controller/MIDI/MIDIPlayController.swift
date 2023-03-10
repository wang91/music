//
//  MIDIPlayController.swift
//  Music
//
//  Created by YouKe Wang on 2023/3/5.
//

import UIKit
import AudioKit
import SoundpipeAudioKit

class MIDIPlayController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var addTrack: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var timeL: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let origin = MIDISampler(name:"origin")
    var originInstrumet:String = ""
    var contentArr:[(name:String,sampler:MIDISampler)] = []
    
    var engine = AudioEngine()
    private var sequencer: AppleSequencer!
    private var mixer = Mixer()
    private var arpeggioSynthesizer = MIDISampler(name: "Arpeggio")
    private var padSynthesizer = MIDISampler(name: "Pad")
    private var bassSynthesizer = MIDISampler(name: "Bass")
    private var drumKit = MIDISampler(name: "Drums")
    private var filter: MoogLadder?
    
    var target:[String] = ["Arpeggio","Drums","Bass","Pad"]
    
    var isPlaying:Bool = false {
        didSet{
            isPlaying ? sequencer.play():sequencer.stop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        do {
//            try origin.loadInstrument(url: NSURL(fileURLWithPath: originInstrumet) as URL)
//        } catch {
//            JKprint("")
//        }
//        contentArr.append((name: "origin", sampler: origin))
       
        initEngine()
        for name in target {
            do {
                switch name {
                case "Arpeggio":
                    if let fileURL = Bundle.main.url(forResource: "Sounds/Sampler Instruments/sawPiano1", withExtension: "exs") {
                        try arpeggioSynthesizer.loadInstrument(url: fileURL)
                    } else {
                        Log("Could not find file")
                    }
                case "pad":
                    if let fileURL = Bundle.main.url(forResource: "Sounds/Sampler Instruments/sawPad1", withExtension: "exs") {
                        try padSynthesizer.loadInstrument(url: fileURL)
                    } else {
                        Log("Could not find file")
                    }
                case "bass":
                    if let fileURL = Bundle.main.url(forResource: "Sounds/Sampler Instruments/sqrTone1", withExtension: "exs") {
                        try bassSynthesizer.loadInstrument(url: fileURL)
                    } else {
                        Log("Could not find file")
                    }
                default:
                    if let fileURL = Bundle.main.url(forResource: "Sounds/Sampler Instruments/drumSimp", withExtension: "exs") {
                        try drumKit.loadInstrument(url: fileURL)
                    } else {
                        Log("Could not find file")
                    }
                }
            } catch let err {
                JKprint("Could not load instrument",err.localizedDescription)
            }
        }
        tableView.register(UINib(nibName: "MIDIPlayCell", bundle: nil), forCellReuseIdentifier: "MIDIPlayCell")
    }
    func initEngine() {
        arpeggioSynthesizer.volume = 0.0
        bassSynthesizer.volume = 0.0
        padSynthesizer.volume = 0.0
        drumKit.volume = 0.0
        mixer = Mixer(arpeggioSynthesizer,bassSynthesizer,padSynthesizer,drumKit)
        for item in contentArr {
            item.sampler.volume = 1.0
        }
        filter = MoogLadder(mixer)
        filter?.cutoffFrequency = 20000
        engine.output = filter
        
        start()
        
        sequencer = AppleSequencer(fromURL: Bundle.main.url(forResource: "Demo", withExtension: "mid")!)
        sequencer.enableLooping()
        sequencer.setTempo(120)
        sequencer.setLength(Duration(beats: 16))
        sequencer.tracks[1].setMIDIOutput(arpeggioSynthesizer.midiIn)
        sequencer.tracks[2].setMIDIOutput(bassSynthesizer.midiIn)
        sequencer.tracks[3].setMIDIOutput(padSynthesizer.midiIn)
        sequencer.tracks[4].setMIDIOutput(drumKit.midiIn)
        
    }
    func loadFileToTrack() {
//        for index in 0..<contentArr.count {
//            let item = contentArr[index]
//            // 设置输出
//            sequencer.tracks[index + 1].setMIDIOutput(item.sampler.midiIn)
//        }
    }
    func start() {
        do {
            try engine.start()
        } catch {
            JKprint("AudioKit did not start!")
        }
    }
    func stop() {
        engine.stop()
    }
    //MARK: - Actions
    @IBAction func addTrackForMIDI(_ sender: UIButton) {
        let alert = UIAlertController(title: "选择Template", message: nil, preferredStyle: .actionSheet)
        for item in target {
            alert.addAction(UIAlertAction(title: item, style: .default, handler: { action in
                self.contentArr.append((name: item, sampler: self.findTargetSampler(name: item)))
                self.tableView.reloadData()
                self.initEngine()
                self.loadFileToTrack()
            }))
        }
        alert.addAction(UIAlertAction(title:"取消", style: .cancel))
        self.present(alert, animated: true)
    }
    func findTargetSampler(name:String) -> MIDISampler {
        switch name {
        case "Bass":
            return bassSynthesizer
        case "Pad":
            return padSynthesizer
        case "Arpeggio":
            return arpeggioSynthesizer
        default:
            return drumKit
        }
    }
    @IBAction func recordMIDIToAudio(_ sender: UIButton) {
        
    }
    
    @IBAction func playMIDIFile(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isPlaying = sender.isSelected
    }
    //MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MIDIPlayCell") as? MIDIPlayCell {
            cell.config(text: contentArr[indexPath.row].name)
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func selectedButton(row: Int, index: Int, status: Bool) {
        
    }
   

}
