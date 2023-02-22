//
//  Const.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/22.
//

import Foundation

class Const:NSObject {
    // record sound folder
    static let HOSTED_SOUND_FOLDER = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last?.appendingPathComponent("sound")
    // midi folder
    static let HOSTED_MIDI_FOLDER = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last?.appendingPathComponent("midi")
}
