//
//  MusicController.swift
//  MusicStudio
//
//  Created by YouKe Wang on 2023/2/8.
//

import UIKit
import AudioKit
import AVFAudio

class MusicController: UIViewController {

    
    @IBOutlet weak var oneL: UILabel!
    var dataSet:[(index:Int,status:Bool,source:String)] = []
        
        let engine = AudioEngine()
        let player = MultiSegmentAudioPlayer()
        let player2 = MultiSegmentAudioPlayer()
        
        var segments = [StreamableAudioSegment]()
        var segments2 = [StreamableAudioSegment]()
        
        var timer: Timer?
        var count:Int = 0
        var isPlaying:Bool = false {
            didSet {
                playBtn.isSelected = isPlaying
                if isPlaying {
                    timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
                    player.playSegments(audioSegments: segments)
                    player2.playSegments(audioSegments: segments2)
                }else{
                    if ((timer?.isValid) != nil) {
                        timer?.invalidate()
                    }
                    player.stop()
                    player2.stop()
                    let orix = topView.frame.origin.x + 40 + 60 + 30
                    sliderView.frame = CGRect(x: orix, y: topView.frame.origin.y, width: 10, height: 220)
                }
            }
        }
        
        @IBOutlet weak var playBtn: UIButton!
        @IBOutlet weak var topView: UIView!
        @IBOutlet weak var addtTrackBtn: UIButton!
        
        @IBOutlet weak var trackOneView: UIView!
        
        @IBOutlet weak var trackTwoView: UIView!
        
        @IBOutlet weak var sliderView: UIView!
        override func viewDidLoad() {
            super.viewDidLoad()
            
            dataSet.removeAll()
            for i in 0..<8 {
                dataSet.append((index: i, status: false, source: ""))
            }
            let mixer = Mixer(player,player2)
            engine.output = mixer
            rewind()
        }
       
        func stop() {
            engine.pause()
        }
        func rewind() {
            do {
                try engine.start()
            } catch {
                print("AudioKit did not start! \(error)")
            }
        }

        @IBAction func addTrackAction(_ sender: UIButton) {
            print("添加新轨道")
        }
        
        @IBAction func playOrStop(_ sender: UIButton) {
            isPlaying = !sender.isSelected
        }
        @objc func updateSlider() {
            count = count + 1
            if count >= 160 {
                count = 0
                isPlaying = false
                
                return
            }
            let min:Float = (395 - 130)/160.0
            let orix = topView.frame.origin.x + 40 + 60 + 30
            sliderView.frame = CGRect(x: orix + CGFloat(Float(count) * min), y: topView.frame.origin.y, width: 10, height: 220)
        }
        @IBAction func changeButtonStatus(_ sender: UIButton) {
            sender.isSelected = !sender.isSelected
            
            if sender.isSelected {
                dataSet[sender.tag].status = true
                if sender.tag < 4 {
                    sender.backgroundColor = .purple
                }else{
                    sender.backgroundColor = .orange
                }
            }else{
                dataSet[sender.tag].status = false
                sender.backgroundColor = UIColor.darkGray
            }
            updateSegements()
        }
        func updateSegements() {
            segments.removeAll()
            segments2.removeAll()
            for data in dataSet {
                if data.status {
                    if data.index < 4 {
                        guard let url1 = Bundle.main.url(forResource: "stage-" + String(data.index + 1), withExtension: "wav"),
                              let file1 = try? AVAudioFile(forReading: url1)
                        else {
                            print("Didn't get test file1")
                            return
                        }
                        let segment1 = ExampleSegment(audioFile:file1,playbackStartTime: Double(data.index) * 2.0)
                        segments.append(segment1)
                    }else{
                        guard let url1 = Bundle.main.url(forResource: "sand-" + String(data.index - 3), withExtension: "wav"),
                              let file1 = try? AVAudioFile(forReading: url1)
                        else {
                            print("Didn't get test file1")
                            return
                        }
                        let segment1 = ExampleSegment(audioFile:file1,playbackStartTime: Double(data.index - 4) * 2.0)
                        segments2.append(segment1)
                    }
                }
            }
        }
    }

    private class ExampleSegment: StreamableAudioSegment {
        var audioFile: AVAudioFile
        var playbackStartTime: TimeInterval = 0
        var fileStartTime: TimeInterval = 0
        var fileEndTime: TimeInterval
        var completionHandler: AVAudioNodeCompletionHandler?

        /// Segment starts at the beginning of file at zero reference time
        init(audioFile: AVAudioFile) {
            self.audioFile = audioFile
            fileEndTime = audioFile.duration
        }

        /// Segment starts some time into the file (past the starting location) at zero reference time
        init(audioFile: AVAudioFile, fileStartTime: TimeInterval) {
            self.audioFile = audioFile
            self.fileStartTime = fileStartTime
            fileEndTime = audioFile.duration
        }

        /// Segment starts at the beginning of file with an offset on the playback time (plays in future when reference time is 0)
        init(audioFile: AVAudioFile, playbackStartTime: TimeInterval) {
            self.audioFile = audioFile
            self.playbackStartTime = playbackStartTime
            fileEndTime = audioFile.duration
        }

        /// Segment starts some time into the file with an offset on the playback time (plays in future when reference time is 0)
        init(audioFile: AVAudioFile, playbackStartTime: TimeInterval, fileStartTime: TimeInterval) {
            self.audioFile = audioFile
            self.playbackStartTime = playbackStartTime
            self.fileStartTime = fileStartTime
            fileEndTime = audioFile.duration
        }

        /// Segment starts some time into the file with an offset on the playback time (plays in future when reference time is 0)
        /// and completes playback before the end of file
        init(audioFile: AVAudioFile, playbackStartTime: TimeInterval, fileStartTime: TimeInterval, fileEndTime: TimeInterval) {
            self.audioFile = audioFile
            self.playbackStartTime = playbackStartTime
            self.fileStartTime = fileStartTime
            self.fileEndTime = fileEndTime
        }
    }

