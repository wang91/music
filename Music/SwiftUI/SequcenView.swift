//
//  SequcenView.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/27.
//

import SwiftUI
import AudioKit
import Keyboard
import AVFAudio

struct SequcenView: View {
    
    let engine = AudioEngine()
    let drums = MIDISampler(name: "Drums")
    let sequencer = AppleSequencer(fromURL: Bundle.main.url(forResource: "4tracks", withExtension: "mid")!)

    @State var tempo: Float = 120 {
        didSet {
            sequencer.setTempo(BPM(tempo))
        }
    }

    @State var isPlaying = false {
        didSet {
            isPlaying ? sequencer.play() : sequencer.stop()
        }
    }
    init() {
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
        sequencer.setTempo(Double(tempo))
//        engine.output = drums
//        do {
//            let bassDrumURL = Bundle.main.url(forResource:("bass_drum_C1.wav"),withExtension: nil)
//            let bassDrumFile = try AVAudioFile(forReading: bassDrumURL!)
//            let clapURL = Bundle.main.url(forResource:("clap_D#1.wav"),withExtension: nil)
//            let clapFile = try AVAudioFile(forReading: clapURL!)
//            let closedHiHatURL = Bundle.main.url(forResource:("closed_hi_hat_F#1.wav"),withExtension: nil)
//            let closedHiHatFile = try AVAudioFile(forReading: closedHiHatURL!)
//            let hiTomURL = Bundle.main.url(forResource:("hi_tom_D2.wav"),withExtension: nil)
//            let hiTomFile = try AVAudioFile(forReading: hiTomURL!)
//            let loTomURL = Bundle.main.url(forResource:("lo_tom_F1.wav"),withExtension: nil)
//            let loTomFile = try AVAudioFile(forReading: loTomURL!)
//            let midTomURL = Bundle.main.url(forResource:("mid_tom_B1.wav"),withExtension: nil)
//            let midTomFile = try AVAudioFile(forReading: midTomURL!)
//            let openHiHatURL = Bundle.main.url(forResource:("open_hi_hat_A#1.wav"),withExtension: nil)
//            let openHiHatFile = try AVAudioFile(forReading: openHiHatURL!)
//            let snareDrumURL = Bundle.main.url(forResource:("snare_D1.wav"),withExtension: nil)
//            let snareDrumFile = try AVAudioFile(forReading: snareDrumURL!)
//
//            try drums.loadAudioFiles([bassDrumFile,
//                                      clapFile,
//                                      closedHiHatFile,
//                                      hiTomFile,
//                                      loTomFile,
//                                      midTomFile,
//                                      openHiHatFile,
//                                      snareDrumFile])
//
//        } catch {
//            Log("Files Didn't Load")
//        }
//        sequencer.clearRange(start: Duration(beats: 0), duration: Duration(beats: 100))
//        sequencer.debug()
//        sequencer.setGlobalMIDIOutput(drums.midiIn)
//        sequencer.enableLooping(Duration(beats: 4))
//        sequencer.setTempo(150)
    }
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Text(isPlaying ? "Stop" : "Start")
                .foregroundColor(.blue)
                .onTapGesture {
                isPlaying.toggle()
            }
            HStack{
                Text("Tempo:").font(.caption).foregroundColor(Color.black)
                Text(String(format: "%0.1f", tempo)).font(.caption).foregroundColor(Color.black)
                    .frame(width: 60.0, alignment: .leading)
            }
            Slider(value: $tempo,in: 60 ... 300)
            Spacer()
            Keyboard(layout: .piano(pitchRange: Pitch(50)...Pitch(70)),noteOn: noteOn(pitch:point:),noteOff: noteOff)
        }
        .onAppear {
            start()
        }
        .onDisappear {
            stop()
        }
    }
    func noteOn(pitch: Pitch, point: CGPoint) {
        print("note on \(pitch)")
        sequencer.tracks[0].add(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: 120, position: Duration(beats: 2), duration: Duration(beats: 1.0))
    }

    func noteOff(pitch: Pitch) {
        print("note off \(pitch)")
        sequencer.tracks[0].clearNote(MIDINoteNumber(pitch.midiNoteNumber))
    }
    func start() {
        do {
            try engine.start()
            
        } catch let err {
            Log(err) }
    }
    func stop() {
        engine.stop()
    }
}


