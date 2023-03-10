//
//  AudioSampler.swift
//  Music
//
//  Created by YouKe Wang on 2023/3/7.
//

import SwiftUI
import Keyboard
import Tonic
import AudioKit
import AVFAudio

struct AudioSampler: View {
    
    ///  键盘发声
    func noteOn(pitch: Tonic.Pitch, point _: CGPoint) {
        print(pitch.midiNoteNumber)
        drums.play(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: 120, channel: 0)
    }
    ///  不发声
    func noteOff(pitch: Tonic.Pitch) {
        drums.stop(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), channel: 0)
    }
    func loadAudioFile(file:URL) {
        do {
            try drums.loadAudioFile(AVAudioFile(forReading: file))
        }catch {
            JKprint("加载音频文件出错")
        }
    }
    let engine = AudioEngine()
    let drums = MIDISampler(name: "Drums")
    let sequencer = AppleSequencer(fromURL: Bundle.main.url(forResource: "Demo", withExtension: "mid")!)
    
    var body: some View {
        Keyboard(layout: .piano(pitchRange: Pitch(50) ... Pitch(80)),noteOn: noteOn, noteOff: noteOff)
            .frame(height: 200)
            .onAppear(perform: {
                do {
                    try engine.start()
                    let file = Bundle.main.url(forResource: "Prismatica Beat 03", withExtension: "caf")
                    //file:///Users/youke/Library/Developer/CoreSimulator/Devices/397F1750-C37F-4053-AE90-8768B2183169/data/Containers/Data/Application/37C690A5-EADE-48AC-A0BC-A5CAFE75D7B2/Library/Application%20Support/midiWav/QingHuaCiElectric_Piano1678264566.caf
                    
//                    let file = Const.getMIDIWavRecord(fileName: "QingHuaCiElectric_Piano1678264566.caf")
//                    Const.mixAudio(originAudio: file!) { result, fileUrl in
//
//                    }
                    try drums.loadAudioFile(AVAudioFile(forReading: file! as URL))
                } catch {
                    
                }
            })
            .onTapGesture {
    //            isPlaying.toggle()
            }
            .onDisappear(perform: {
                engine.stop()
            })
    }
    public init() {
        engine.output = drums
    }
}

//struct AudioSampler_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioSampler()
//    }
//}
