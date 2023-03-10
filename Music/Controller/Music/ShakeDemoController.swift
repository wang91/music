//
//  ShakeDemoController.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/15.
//

import UIKit
import AudioKit
import AVFAudio
import AVFAudio.AVAudioSequencer

class ShakeDemoController: UIViewController, UITableViewDelegate, UITableViewDataSource, ShakeInfoCellDelegate, ShakeTopCellDelegate {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var volumeNum: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    // data
    var playerArr:[(index:Int,player:MultiSegmentAudioPlayer)] = []
    var contentArr:[ShakeModel] = []
    // 记录每一列最大播放时间
    var timeArr:[(index:Int,duration:Double)] = []
    // 默认时间
    var defaultTime:Double = 19.8
    // 播放的总时间
    var totalTime:Double = 0.0
    var currentIndex:Int = 0
    var currentRow:Int = 0
    var timer:Timer?
    var count:Int = 0
    var totalLine:Int = 8
    // name:类型名称
    // fileName:文件存放名称
    // color:颜色
    // type:资源类型1是工程本地，2是APP本地，3是网络资源
    var popContentArr:[(name:String,fileName:String,color:UIColor,type:Int)] = [
        ("e_piano_11","e_piano_1_01.mp3",.white,1),
         ("e_piano_12","e_piano_1_02.mp3",.blue,1),
         ("e_piano_13","e_piano_1_03.mp3",.orange,1),
        
        ("piano_11","piano_11.mp3",.red,1),
        ("piano_12","piano_12.mp3",.blue,1),
        ("piano_13","piano_13.mp3",.orange,1),
        ("piano_14","piano_14.mp3",.yellow,1),
        ("piano_15","piano_15.mp3",.green,1),
        ("piano_16","piano_16.mp3",.yellow,1),
        ("piano_17","piano_17.mp3",.red,1),
        ("piano_18","piano_18.mp3",.green,1),
        ("piano_19","piano_19.mp3",.blue,1),
        ("piano_20","piano_20.mp3",.purple,1),
        
         ("Bass_11","Bass01.mp3",.green,1),
        ("Bass_12","Bass02.mp3",.white,1),
        ("Bass_13","Bass03.mp3",.red,1),
        ("Bass_14","Bass04.mp3",.orange,1),
        
        ("Bell_11","Bell01.mp3",.purple,1),
        ("Bell_12","Bell02.mp3",.yellow,1),
        
        ("egt1_1","egt1_01.mp3",.red,1),
        
        ("egt3_11","egt3_11.mp3",.orange,1),
        ("egt3_12","egt3_12.mp3",.white,1),
        ("egt3_13","egt3_13.mp3",.green,1),
        ("egt3_21","egt3_21.mp3",.red,1),
        ("egt3_22","egt3_22.mp3",.blue,1),
        ("egt3_23","egt3_23.mp3",.yellow,1),
        
        ("meta2_1","meta2_1.mp3",.red,1),
        ("meta2_2","meta2_2.mp3",.yellow,1),
        ("meta2_3","meta2_3.mp3",.orange,1),
        
        ("meta2_11","meta2_11.mp3",.blue,1),
        ("meta2_12","meta2_12.mp3",.purple,1),
        ("meta2_13","meta2_13.mp3",.red,1),
    
        
        
        ("violin_1","violin_1.mp3",.red,1),
        ("violin_3","violin_3.mp3",.blue,1),
        ("violin_21","violin_21.mp3",.red,1),
        ("violin_22","violin_22.mp3",.yellow,1),
        ("violin_23","violin_23.mp3",.red,1),
        
    ]
    var modelArr:[(name:String,fileName:String,color:UIColor,type:Int)] = []
//    var popContentArr:[(name:String,fileName:String,color:UIColor,type:Int)]=[("段落1","BeatDrum.mp3",.red,1),("吉他1","青花瓷-段落1-吉他.mp3",.white,1),("马林巴琴1","青花瓷-段落1-马林巴琴.mp3",.blue,1),("女声1","青花瓷-段落1-女声.mp3",.yellow,1),("小提琴1","青花瓷-段落1-小提琴.mp3",.purple,1),("长笛1","青花瓷-段落1-长笛.mp3",.green,1),("钢琴2","青花瓷-段落2-钢琴.mp3",.red,1),("吉他2","青花瓷-段落2-吉他.mp3",.white,1),("马林巴琴2","青花瓷-段落2-马林巴琴.mp3",.blue,1),("小提琴2","青花瓷-段落2-小提琴.mp3",.purple,1),("长笛2","青花瓷-段落2-长笛.mp3",.green,1)]
    //("Piano","Electric Piano.caf",.yellow,1)
    @IBOutlet weak var timeL: UILabel!
    
    
    var sliderView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 4.0
        view.layer.masksToBounds = true
        return view
    }()
    
    var isPlaying:Bool = false {
        didSet {
            playBtn.isSelected = isPlaying
            if isPlaying {
                if playerArr.count == 0 {
                    isPlaying = false
                    return
                }
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
                
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
                let orix = 92.0 - 8.0
                sliderView.frame = CGRect(x: orix, y: topView.frame.origin.y + 40.0, width: 8.0, height: JKSScreenHeight - topView.frame.origin.y - 40.0 - 60)
            }
        }
    }
    let engine = AudioEngine()
    var mixer:Mixer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configViews()
        addContentData()
        setIndexMaxDuration()
        initPlayers()
        
        
        engine.output = mixer
        rewind()
        
        let orix = 92.0 - 8.0
        self.sliderView.frame = CGRect(x: orix, y: 90 + 40.0, width: 8.0, height: JKSScreenHeight - topView.frame.origin.y - 40.0 - 60)
        self.view.addSubview(self.sliderView)
        
        self.view.bringSubviewToFront(self.volumeView)
//        var array = UserDefaults.getAllRecordMidFile()
//        JKprint(array)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//
//        let data = (name: "Beat", fileName: "beat.aiff", color: UIColor(red: CGFloat(arc4random()%220) / 255.0, green: CGFloat(arc4random()%220) / 255.0, blue: CGFloat(arc4random()%220) / 255.0, alpha: 1.0), type: 1)
//        self.modelArr.append((data))
//        self.updateContentData(item: self.modelArr.last!)
//        self.addPlayer()
//        self.tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPlaying = false
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
    func addFile(fileName:String) {
        let data = (name: "mid", fileName: fileName, color: UIColor(red: CGFloat(arc4random()%220) / 255.0, green: CGFloat(arc4random()%220) / 255.0, blue: CGFloat(arc4random()%220) / 255.0, alpha: 1.0), type: 2)
        modelArr.append(data)
        self.tableView?.reloadData()
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
            for j in 0..<(totalLine-1) {
                let shake1 = ShakeModel()
                shake1.imageName = item.name
                shake1.color = item.color
                shake1.rowIndex = i
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
        }
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
    }
    func initPlayers() {
        playerArr.removeAll()
        for i in 0..<modelArr.count {
            let player = MultiSegmentAudioPlayer()
            playerArr.append((i,player))
        }
        mixer = Mixer()
        for item in playerArr {
            mixer.addInput(item.player)
        }
    }
    func addPlayer() {
        let player = MultiSegmentAudioPlayer()
        playerArr.append((playerArr.count,player))
        mixer.addInput(player)
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
    func updateIndexMaxDuration(row:Int,index:Int,status:Bool) {
        var array:[ShakeModel] = []
        for item in contentArr {
            if item.lineIndex == index {
                array.append(item)
            }
        }
        var time:Double = defaultTime
        for model in array {
//            if row > 1 && model.rowIndex > 1 {
//                if model.status && 2 * (model.avFile?.duration ?? 0.0) > time {
//                    time =  2 * (model.avFile?.duration ?? 0.0)
//                }
//            }else{
//                if model.status && model.avFile?.duration ?? 0.0 > time {
//
//                    time =  model.avFile?.duration ?? 0.0
//                }
//            }
            
        }
        JKprint("time = ",index,time)
        timeArr[index].duration = time
        totalTime = 0.0
        for model in timeArr {
            totalTime = totalTime + model.duration
        }
        JKprint("total time ==",totalTime)
    }
    //MARK: - Actions
    @objc func updateSlider() {
        count = count + 1
        if count >= Int(totalTime) * 2 {
            count = 0
            isPlaying = false
            timeL.text = "0.0s"
            currentIndex = 0
            return
        }
        timeL.text = String(format: "%.1fs", Float(count) / 2.0)
        let trump = getSliderLineSpeed()
        let min:Float = Float(42/trump.1/2.0)
        sliderView.frame.origin.x = sliderView.frame.origin.x + CGFloat(min)

    }
    func getSliderLineSpeed() -> (Int,Double) {
        let line:Int = Int((sliderView.frame.origin.x - 84.0) / 42.0)
        
        if line >= timeArr.count {
            return (0,defaultTime)
        }
        if currentIndex <= line {
            currentIndex = line
        }
        JKprint("line = = ",line,timeArr[currentIndex].duration)
        return (currentIndex,timeArr[currentIndex].duration)
    }
    @IBAction func startOrStopPlay(_ sender: UIButton) {
        isPlaying = !sender.isSelected
    }
    func getPlayerSegment(row:Int) ->[StreamableAudioSegment]{
        var segment = [StreamableAudioSegment]()
        for item in contentArr {
            if item.rowIndex == row {
                if item.status && item.avFile != nil {
                        let segment1 = ExampleSegment(audioFile:item.avFile!,playbackStartTime: confirmStartTime(line: item.lineIndex),fileStartTime: 0,fileEndTime: 20)
                        segment.append(segment1)
                }
            }
        }
        return segment
    }
    func confirmStartTime(line:Int) -> Double {
        var time:Double = 0.0
        for i in 0..<line {
            time = time + timeArr[i].duration
        }
        JKprint("start time = ",time,line)
        return time
    }
    //MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return modelArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 , let cell = tableView.dequeueReusableCell(withIdentifier: "ShakeTopCell") as? ShakeTopCell {
            cell.delegate = self
            return cell
        }
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
        if indexPath.section == 0 {
            return 40
        }
        return 50
    }
    func addNewMusic() {
        isPlaying = false
        let array = UserDefaults.getAllRecordMidFile()
        let alert = UIAlertController(title: "Choose", message: nil, preferredStyle: .actionSheet)
        for item in array {
            alert.addAction(UIAlertAction(title: item, style: .default, handler: { action in
                self.addFile(fileName: item)
                self.updateContentData(item: self.modelArr.last!)
                self.addPlayer()
                
                self.tableView.reloadData()
            }))
        }
        alert.addAction(UIAlertAction(title:"取消", style: .cancel))
        self.present(alert, animated: true)
    }
    func selectedButton(row: Int, index: Int, status: Bool) {
        let model = searchTargetModel(row: row, line: index)
        model.status = status
        updateIndexMaxDuration(row: row, index: index,status: status)
    }
    @IBAction func changePlayerVolume(_ sender: UISlider) {
        volumeNum.text = String(format: "%.1f", sender.value)
        let player = playerArr[currentRow].player
        player.volume = sender.value
    }
    func changeVolume(row: Int) {
        currentRow = row
        volumeView.isHidden = !volumeView.isHidden
        let player = playerArr[currentRow].player
        volumeSlider.value = player.volume
        volumeNum.text = String(format: "%.1f", player.volume)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        volumeView.isHidden = true
    }
    
    @IBAction func chooseLocalAudioFile(_ sender: UIButton) {
        isPlaying = false
        let alert = UIAlertController(title: "Choose", message: nil, preferredStyle: .actionSheet)
        for item in popContentArr {
            alert.addAction(UIAlertAction(title: item.name, style: .default, handler: { action in
                self.modelArr.append(item)
                self.updateContentData(item: self.modelArr.last!)
                self.addPlayer()
                
                self.tableView.reloadData()
            }))
        }
        alert.addAction(UIAlertAction(title:"取消", style: .cancel))
        self.present(alert, animated: true)
    }
    
    @IBAction func deleteItem(_ sender: UIButton) {
        isPlaying = false
        self.modelArr.remove(at: currentRow)
        self.playerArr.remove(at: currentRow)
        self.removeContent()
        volumeView.isHidden = true
    }
    func removeContent() {
        var array:[ShakeModel] = []
        for item in contentArr {
            if item.rowIndex != currentRow {
                array.append(item)
            }
        }
        for item in array {
            if item.rowIndex > currentRow {
                item.rowIndex = item.rowIndex - 1
            }
        }
        contentArr = NSArray(array: array) as! [ShakeModel]
        self.tableView.reloadData()
    }
}
