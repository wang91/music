//
//  ShakeDemoController.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/15.
//

import UIKit
import AudioKit
import AVFAudio

class ShakeDemoController: UIViewController, UITableViewDelegate, UITableViewDataSource, ShakeInfoCellDelegate {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    // data
    var playerArr:[(index:Int,player:MultiSegmentAudioPlayer)] = []
    var contentArr:[ShakeModel] = []
    
    // Recorded playback
    var tape:AVAudioFile!
    var recorder:NodeRecorder!
    
    var timer:Timer?
    var count:Int = 0
    
    var duration:Float = 6.5
    var modelArr:[(name:String,color:UIColor)] = [("Amber Beat 01.caf",.white),("Against Time Sax Sample.caf",.blue),("Against Time Staccato Strings.caf",.orange),("Against Time Keys.caf",.green),("Against Time Piano.caf",.red)]
    @IBOutlet weak var timeL: UILabel!
    
    
    var sliderView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    var isPlaying:Bool = false {
        didSet {
            playBtn.isSelected = isPlaying
            if isPlaying {
                timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
                for i in 0..<playerArr.count {
                    let play = playerArr[i]
                    let segment1 = self.getPlayerSegment(row: i)
                    play.player.playSegments(audioSegments: segment1)
                }
            }else{
                for item in playerArr {
                    item.player.stop()
                }
                if ((timer?.isValid) != nil) {
                    timer?.invalidate()
                    count = 0
                    timeL.text = "0.0s"
                }
                let orix = 52.0 - 8.0
                sliderView.frame = CGRect(x: orix, y: topView.frame.origin.y + 40.0, width: 10.0, height: 550.0)
            }
        }
    }
    let engine = AudioEngine()
    var mixer:Mixer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configViews()
        addContentData()
        
        mixer = Mixer()
        for item in playerArr {
            mixer.addInput(item.player)
        }
        
        engine.output = mixer
        rewind()
        
        let orix = 52.0 - 8.0
        self.sliderView.frame = CGRect(x: orix, y: 90 + 40.0, width: 10.0, height: 550.0)
        self.view.addSubview(self.sliderView)
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

    //MARK: - init
    func configViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ShakeTopCell", bundle: nil), forCellReuseIdentifier: "ShakeTopCell")
        tableView.register(UINib(nibName: "ShakeInfoCell", bundle: nil), forCellReuseIdentifier: "ShakeInfoCell")
    }
    func addContentData() {
        contentArr.removeAll()
        for i in 0..<modelArr.count {
            let item = modelArr[i]
            let shake1 = ShakeModel()
            shake1.imageName = ""
            shake1.color = item.color
            shake1.rowIndex = i
            for j in 0..<7 {
                shake1.selet.append((j,false))
            }
            contentArr.append(shake1)
        }
        
        for i in 0..<contentArr.count {
            let player = MultiSegmentAudioPlayer()
            playerArr.append((i,player))
        }
        
    }
    @objc func updateSlider() {
        count = count + 1
        if count >= Int(duration) * 7 * 20 {
            count = 0
            isPlaying = false
            timeL.text = "0.0s"
            return
        }
        timeL.text = String(format: "%.1fs", Float(count) / 20.0)
        let min:Float = 40/duration/20.0
        let orix = 52.0 - 8.0
        sliderView.frame = CGRect(x: orix + CGFloat(Float(count) * min), y: topView.frame.origin.y + 40.0, width: 10, height: 550)
    }
    //MARK: - Actions
    @IBAction func startOrStopRecord(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if isPlaying {
            isPlaying = false
        }
        isPlaying = sender.isSelected
        if sender.isSelected {
            
            do {
                self.recorder = try NodeRecorder(node: self.mixer)
                self.tape = self.recorder.audioFile
                try self.recorder.reset()
                try self.recorder.record()
            } catch {
                
            }
        }else{
            if self.recorder != nil {
                self.recorder.stop()
                let controller = MusicResultController(nibName: "MusicResultController", bundle: nil)
                controller.recordFile = self.recorder.audioFile
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @IBAction func startOrStopPlay(_ sender: UIButton) {
        isPlaying = !sender.isSelected
    }
    func getPlayerSegment(row:Int) ->[StreamableAudioSegment]{
        var segment = [StreamableAudioSegment]()
        for item in contentArr {
            if item.rowIndex == row {
                let model = modelArr[item.rowIndex]
                guard let url1 = Bundle.main.url(forResource: model.name, withExtension: nil),
                      let file1 = try? AVAudioFile(forReading: url1)
                else {
                    JKprint("Didn't get test file1")
                    return segment
                }
                for fileIndex in item.selet {
                    if fileIndex.status {
                        let segment1 = ExampleSegment(audioFile:file1,playbackStartTime: Double(fileIndex.index) * Double(file1.duration))
                        segment.append(segment1)
//                        if row == 0 {
//                            let segment2 = ExampleSegment(audioFile:file1,playbackStartTime: Double(duration)/2.0)
//                            segment.append(segment2)
//                        }
                    }
                }
            }
        }
        return segment
    }
    //MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return contentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 , let cell = tableView.dequeueReusableCell(withIdentifier: "ShakeTopCell") as? ShakeTopCell {
            
            return cell
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ShakeInfoCell") as? ShakeInfoCell {
            cell.tag = indexPath.row
            cell.delegate = self
            cell.config(data: contentArr[indexPath.row], index: indexPath.row)
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 40
        }
        return 50
    }
    func selectedButton(row: Int, index: Int, status: Bool) {
        let model = contentArr[row]
        model.selet[index].status = status
        
    }
}
