//
//  MusicPlayController.swift
//  Music
//
//  Created by YouKe Wang on 2023/3/7.
//

import UIKit
import AudioKit
import AVFAudio

class MusicPlayController: UIViewController, UITableViewDelegate, UITableViewDataSource, ShakeInfoCellDelegate {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var timeL: UILabel!
    
    @IBOutlet weak var addTrack: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var volumeNum: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    
    var currentRow:Int = 0
    var timer:Timer?
    var count:Int = 0
    var totalLine:Int = 8
    // 播放的总时间
    var totalTime:Double = 0.0
    // 默认时间
    var defaultTime:Double = 20.0
    
    var modelArr:[(name:String,fileName:String,color:UIColor,type:Int)] = []
    var popContentArr:[(name:String,fileName:String,color:UIColor,type:Int)] = [
        ("e_piano_11","e_piano_1_01.mp3",.white,1),
         ("e_piano_12","e_piano_1_02.mp3",.blue,1),
         ("e_piano_13","e_piano_1_03.mp3",.orange,1),
        
        ("piano_11","piano_11.mp3",.red,1),
        ("piano_12","piano_12.mp3",.blue,1),
        ("piano_13","piano_13.mp3",.orange,1),
        ("piano_14","piano_14.mp3",.yellow,1)]
   
    var sliderView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 4.0
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 84.0, y: 90 + 40.0, width: 8.0, height: 550.0)
        return view
    }()
    
    var isPlaying:Bool = false {
        didSet {
            playBtn.isSelected = isPlaying
            if isPlaying {
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
                sequencer.play()
                for track in sequencer.tracks {
                    if totalTime < track.length {
                        totalTime = track.length
                    }
                }
                JKprint("total time = ", totalTime)
            }else{
                sequencer.setTime(0)
                sequencer.stop()
                timeL.text = "0.0s"
                if ((timer?.isValid) != nil) {
                    timer?.invalidate()
                    count = 0
                }
                let orix = 84.0
                sliderView.frame = CGRect(x: orix, y: topView.frame.origin.y + 40.0, width: 8.0, height: 550.0)
            }
        }
    }
    // 记录每一列最大播放时间
    var timeArr:[(index:Int,duration:Double)] = []
    
    let engine = AudioEngine()
    var mixer:Mixer!
    var sequencer: AppleSequencer = AppleSequencer(filename: "Single")
    // data
    var playerArr:[(index:Int,player:MIDISampler)] = []
    var contentArr:[ShakeModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mixer = Mixer()
        
        engine.output = mixer
        
        engineStart()
        volumeSlider.maximumValue = 2.0
        volumeSlider.minimumValue = 0.0
        
        sequencer.addMIDIFileTracks("4tracks")
        sequencer.addMIDIFileTracks("4tracks")
        sequencer.setTempo(120)
        setIndexMaxDuration()
        
        configViews()
        self.view.addSubview(self.sliderView)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPlaying = false
        engineStop()
    }
    func engineStop() {
        engine.pause()
    }
    func engineStart() {
        do {
            try engine.start()
        } catch {
            JKprint("AudioKit did not start! \(error)")
        }
    }
    func addFile(fileName:String) {
        let data = (name: "Record", fileName: fileName, color: UIColor(red: CGFloat(arc4random()%220) / 255.0, green: CGFloat(arc4random()%220) / 255.0, blue: CGFloat(arc4random()%220) / 255.0, alpha: 1.0), type: 2)
        modelArr.append(data)
        
        addPlayer(item: data)
        updateContentData(item: data)
    }
    
    func addPlayer(item:(name:String,fileName:String,color:UIColor,type:Int)) {
        let sampler = MIDISampler(name: item.name)
        playerArr.append((index: playerArr.count, player: sampler))
        mixer.addInput(sampler)
        if sequencer.trackCount >= playerArr.count {
            sequencer.tracks[playerArr.count - 1].setMIDIOutput(sampler.midiIn)
        }else{

        }
        updateContentData(item: item)
    }
    func updateContentData(item:(name:String,fileName:String,color:UIColor,type:Int)) {
        for j in 0..<(totalLine-1) {
            let shake1 = ShakeModel()
            shake1.imageName = item.name
            shake1.color = item.color
            shake1.rowIndex = modelArr.count - 1
            shake1.lineIndex = j
            shake1.status = false
            if item.type == 1 {
                if let url1 = Bundle.main.url(forResource: item.fileName, withExtension: nil),
                   let file1 = try? AVAudioFile(forReading: url1) {
                    shake1.avFile = file1
                }
            }
            if item.type == 2 {
                if let url1 = Const.getMIDIWavRecord(fileName: item.fileName),
                   let file1 = try? AVAudioFile(forReading: url1) {
                    shake1.avFile = file1
                }
            }
            contentArr.append(shake1)
        }
        self.tableView.reloadData()
    }
    //MARK: - init
    func configViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ShakeTopCell", bundle: nil), forCellReuseIdentifier: "ShakeTopCell")
        tableView.register(UINib(nibName: "ShakeInfoCell", bundle: nil), forCellReuseIdentifier: "ShakeInfoCell")
    }
    func searchTargetModel(row:Int,line:Int) -> ShakeModel {
        for item in contentArr {
            if item.rowIndex == row && item.lineIndex == line {
                return item
            }
        }
        return ShakeModel()
    }
    // 预置每一列最大播放时间
    func setIndexMaxDuration() {
        timeArr.removeAll()
        for i in 0..<7 {
            timeArr.append((index: i, duration: defaultTime))
        }
        
    }
    //MARK: - Actions
    @objc func updateSlider() {
        count = count + 1
        if count >= Int(totalTime) * 2 {
            count = 0
            isPlaying = false
            timeL.text = "0.0s"
            
            return
        }
        timeL.text = String(format: "%.1fs", Float(count) / 2.0)
        let trump = defaultTime
        let min:Float = Float(42/trump/2.0)
        sliderView.frame.origin.x = sliderView.frame.origin.x + CGFloat(min)

    }
    //MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ShakeInfoCell") as? ShakeInfoCell {
            cell.tag = indexPath.row
            cell.delegate = self
            var array:[ShakeModel] = []
            for item in contentArr {
                if item.rowIndex == indexPath.row {
                    array.append(item)
                }
            }
            cell.config(data: array, index: indexPath.row)
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    @IBAction func startOrStopPlay(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isPlaying = sender.isSelected
    }
    func selectedButton(row: Int, index: Int, status: Bool) {
        let model = searchTargetModel(row: row, line: index)
        model.status = status
        if status {
            let player = playerArr[row].player
            do {
                try player.loadAudioFile(model.avFile!)
                JKprint("file url = ",model.avFile!.url.absoluteString)
            } catch let error {
                JKprint("加载音频文件",error.localizedDescription)
            }
            sequencer.tracks[row].add(noteNumber: 60, velocity: 120, position: Duration(beats: Double(index) * defaultTime * 2 ,tempo: 120), duration: Duration(beats: defaultTime * 2 ,tempo: 120))
        }else{
            sequencer.tracks[row].clearRange(start: Duration(beats: 0), duration: Duration(beats: defaultTime))
        }
        
    }
    @IBAction func addMusicTrack(_ sender: UIButton) {
        isPlaying = false
        let array = UserDefaults.getAllRecordMidFile()
        let alert = UIAlertController(title: "Choose", message: nil, preferredStyle: .actionSheet)
        for item in array {
            alert.addAction(UIAlertAction(title: item, style: .default, handler: { action in
                self.addFile(fileName: item)
                
                self.tableView.reloadData()
            }))
        }
        alert.addAction(UIAlertAction(title:"取消", style: .cancel))
        self.present(alert, animated: true)
        
    }
    @IBAction func changePlayerVolume(_ sender: UISlider) {
        volumeNum.text = String(format: "%.1f", sender.value)
        let player = playerArr[currentRow]
        player.player.volume = sender.value
    }
    func changeVolume(row: Int) {
        currentRow = row
        volumeView.isHidden = !volumeView.isHidden
        let player = playerArr[row]
        JKprint("volume =",player.player.volume)
        volumeSlider.value = player.player.volume
        volumeNum.text = String(format: "%.1f", player.player.volume)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        volumeView.isHidden = true
    }
    @IBAction func chooseAudio(_ sender: UIButton) {
        isPlaying = false
        let alert = UIAlertController(title: "Choose", message: nil, preferredStyle: .actionSheet)
        for item in popContentArr {
            alert.addAction(UIAlertAction(title: item.name, style: .default, handler: { action in
                self.modelArr.append(item)
                self.addPlayer(item: item)
                self.updateContentData(item: item)
            }))
        }
        alert.addAction(UIAlertAction(title:"取消", style: .cancel))
        self.present(alert, animated: true)
    }
}
