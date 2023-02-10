//
//  RootController.swift
//  MusicStudio
//
//  Created by YouKe Wang on 2023/2/8.
//

import UIKit

class RootController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }

    @IBAction func recordAudio(_ sender: UIButton) {
        self.navigationController?.pushViewController(RecordController(nibName: "RecordController", bundle: nil), animated: true)
    }
    
    @IBAction func playMIDI(_ sender: UIButton) {
        self.navigationController?.pushViewController(MIDIPlayController(nibName: "MIDIPlayController", bundle: nil), animated: true)
    }
    @IBAction func playMusic(_ sender: UIButton) {
        self.navigationController?.pushViewController(MusicController(nibName: "MusicController", bundle: nil), animated: true)
    }
}
