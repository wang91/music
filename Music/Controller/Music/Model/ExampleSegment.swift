//
//  ExampleSegment.swift
//  Music
//
//  Created by YouKe Wang on 2023/3/3.
//

import UIKit
import AudioKit
import AVFAudio

class ExampleSegment: StreamableAudioSegment {
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


