//
//  DealMIDIFileController.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/28.
//

import UIKit
import AudioKit
import AVFAudio
import SwiftUI

class DealMIDIFileController: UIViewController {

    var midiURL:URL = Bundle.main.url(forResource: "export", withExtension: "mid")!
    var sampler: MIDISampler = MIDISampler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sequence = try! MIKMIDISequence(fileAt: midiURL)
        
        for track in sequence.tracks {
            JKprint(track.events.count)
            var array = track.events
            array.removeAll()
            for i in 0..<track.events.count {
                let event = track.events[i]
                if event.eventType.rawValue != 15 {
                    array.append(event)
                }
            }
            array.append(MIKMIDINoteEvent.init(timeStamp: array.last?.timeStamp ?? 20, note: 80, velocity: 120, duration: 0.2, channel: 1))
            array.append(MIKMIDINoteEvent.init(timeStamp: array.last?.timeStamp ?? 20 + 0.1, note: 78, velocity: 120, duration: 0.2, channel: 1))
            array.append(MIKMIDINoteEvent.init(timeStamp: array.last?.timeStamp ?? 20 + 0.1, note: 77, velocity: 120, duration: 0.2, channel: 1))
            array.append(MIKMIDINoteEvent.init(timeStamp: array.last?.timeStamp ?? 20 + 0.1, note: 73, velocity: 120, duration: 0.2, channel: 1))
            array.append(MIKMIDINoteEvent.init(timeStamp: array.last?.timeStamp ?? 20 + 0.1, note: 70, velocity: 120, duration: 0.2, channel: 1))
            track.events = array
            JKprint(track.events.count,array.count)
        }
        let fm = FileManager.default
        var toUrl = Const.HOSTED_MIDI_FOLDER
        let downloadedFile = UUID().uuidString + ".mid"
        
        // Create SoundLibrary folder if not exists
        if !fm.fileExists(atPath: toUrl!.path){
            do {
                try fm.createDirectory(at: toUrl!, withIntermediateDirectories: true, attributes: nil)
                JKprint("Folder created:\(String(describing: toUrl?.lastPathComponent))")
            } catch let err {
                JKprint("ERROR: create 'SoundLibrary' in 'Application Support' folder, detail:\(err)")
            }
        }else{
            JKprint("Sound library folder exists.")
        }
        toUrl?.appendPathComponent(downloadedFile)
        do {
            try sequence.write(to: toUrl!)
            JKprint("写入成功",toUrl?.absoluteString as Any)

            
            let trackView = UIHostingController(rootView: TrackView(fileURL: toUrl!))
            trackView.view.backgroundColor = .white
            self.navigationController?.pushViewController(trackView, animated: true)
        }catch let error {
            JKprint("写入错误",toUrl?.absoluteString as Any,error.localizedDescription)
        }
        
    }
    
    func play() {
        
    }
    

}
