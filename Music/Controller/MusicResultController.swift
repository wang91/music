//
//  MusicResultController.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/10.
//

import UIKit
import AVFAudio
import AudioKit

class MusicResultController: UIViewController {

    var recordFile:AVAudioFile!
    private var recordPlayer:AVAudioPlayer?
    var recordTimer: Timer?
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var titmeL: UILabel!
    @IBOutlet weak var totalL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            recordPlayer = try AVAudioPlayer.init(contentsOf: recordFile.url)
            recordPlayer?.prepareToPlay()
        } catch {
            print("Error loading recording file.")
        }
        totalL.text = String(format: "%.1fs", Float(recordPlayer!.currentTime))
    }
    @IBAction func playOrStopRecord(_ sender: UIButton) {
        if recordFile == nil || recordPlayer == nil {
            return
        }
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.recordPlayer?.play()
            recordTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        }else{
            if ((recordTimer?.isValid) != nil) {
                recordTimer?.invalidate()
            }
            self.recordPlayer?.stop()
            titmeL.text = "0.0s"
            sliderView.value = 0.0
        }
    }
    @objc func updateSlider() {
       
        if recordPlayer == nil {
            return
        }
        sliderView.value = Float(recordPlayer!.currentTime / recordPlayer!.duration)
        titmeL.text = String(format: "%.1fs", Float(recordPlayer!.currentTime))
        if recordPlayer!.duration - recordPlayer!.currentTime < 0.05 {
            if ((recordTimer?.isValid) != nil) {
                recordTimer?.invalidate()
            }
            self.recordPlayer?.stop()
            playBtn.isSelected = false
            recordPlayer?.currentTime = 0
            titmeL.text = "0.0s"
            sliderView.value = 0.0
        }
    }

    

}
