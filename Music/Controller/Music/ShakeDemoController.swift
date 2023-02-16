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
    
    var isPlaying:Bool = false {
        didSet {
            playBtn.isSelected = isPlaying
            if isPlaying {
                for i in 0..<playerArr.count {
                    let play = playerArr[i]
                    let segment1 = self.getPlayerSegment(row: i)
                    play.player.playSegments(audioSegments: segment1)
                }
            }else{
                for item in playerArr {
                    item.player.stop()
                }
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
        let shake1 = ShakeModel()
        shake1.imageName = ""
        shake1.color = .white
        shake1.rowIndex = 0
        for j in 0..<7 {
            shake1.selet.append((j,true))
        }
        contentArr.append(shake1)
        
        let shake2 = ShakeModel()
        shake2.imageName = ""
        shake2.color = .blue
        shake2.rowIndex = 1
        for j in 0..<7 {
            shake2.selet.append((j,true))
        }
        contentArr.append(shake2)
        
        let shake3 = ShakeModel()
        shake3.imageName = ""
        shake3.color = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        shake3.rowIndex = 2
        for j in 0..<7 {
            shake3.selet.append((j,true))
        }
        contentArr.append(shake3)
        
        let shake4 = ShakeModel()
        shake4.imageName = ""
        shake4.color = .yellow
        shake4.rowIndex = 3
        for j in 0..<7 {
            shake4.selet.append((j,false))
        }
        contentArr.append(shake4)
        
        let shake5 = ShakeModel()
        shake5.imageName = ""
        shake5.color = .yellow
        shake5.rowIndex = 4
        for j in 0..<7 {
            shake5.selet.append((j,false))
        }
        contentArr.append(shake5)
        
        let shake6 = ShakeModel()
        shake6.imageName = ""
        shake6.color = .yellow
        shake6.rowIndex = 5
        for j in 0..<7 {
            shake6.selet.append((j,false))
        }
        contentArr.append(shake6)
        
        let shake7 = ShakeModel()
        shake7.imageName = ""
        shake7.color = .yellow
        shake7.rowIndex = 6
        for j in 0..<7 {
            shake7.selet.append((j,false))
        }
        contentArr.append(shake7)
        
        let shake8 = ShakeModel()
        shake8.imageName = ""
        shake8.color = .yellow
        shake8.rowIndex = 7
        for j in 0..<7 {
            shake8.selet.append((j,false))
        }
        contentArr.append(shake8)
        
        let shake9 = ShakeModel()
        shake9.imageName = ""
        shake9.color = .green
        shake9.rowIndex = 8
        for j in 0..<7 {
            shake9.selet.append((j,false))
        }
        contentArr.append(shake9)
        
        for i in 0..<contentArr.count {
            let player = MultiSegmentAudioPlayer()
            playerArr.append((i,player))
        }
        
    }
    //MARK: - Actions
    @IBAction func startOrStopRecord(_ sender: UIButton) {
        
    }
    
    @IBAction func startOrStopPlay(_ sender: UIButton) {
        isPlaying = !sender.isSelected
    }
    func getPlayerSegment(row:Int) ->[StreamableAudioSegment]{
        var segment = [StreamableAudioSegment]()
        if row == 1 || row == 2 || row == 0 {
            return segment
        }
        for item in contentArr {
            if item.rowIndex == row {
                let url2 = Bundle.main.url(forResource: "shake-" + String(item.rowIndex), withExtension: "m4a")
                guard let url1 = Bundle.main.url(forResource: "shake-" + String(item.rowIndex), withExtension: "m4a"),
                      let file1 = try? AVAudioFile(forReading: url1)
                else {
                    print("Didn't get test file1")
                    return segment
                }
                for fileIndex in item.selet {
                    if fileIndex.status {
                        let segment1 = ExampleSegment(audioFile:file1,playbackStartTime: Double(fileIndex.index) * 19.0)
                        segment.append(segment1)
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
        return 9
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
        var model = contentArr[row]
        model.selet[index].status = status
        
    }
}
