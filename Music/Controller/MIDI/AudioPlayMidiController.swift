//
//  AudioPlayMidiController.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/23.
//

import UIKit
import SwiftUI

class AudioPlayMidiController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        let midiURL = Bundle.main.url(forResource: "zhou", withExtension: "mid")
        let trackView = UIHostingController(rootView: TrackView())
        trackView.view.backgroundColor = .white
        trackView.view.frame = CGRect(x: 0, y: 200, width: JKSScreenWidth, height: 600)
        self.view.addSubview(trackView.view)
        self.view.isUserInteractionEnabled = true
    }


   

}
