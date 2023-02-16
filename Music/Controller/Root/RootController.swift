//
//  RootController.swift
//  MusicStudio
//
//  Created by YouKe Wang on 2023/2/8.
//

import UIKit

class RootController: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    
    var dataArr:Array<String> = ["音乐编辑","录制音频","播放MIDI"]
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "主页"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "RootCell", bundle: nil), forCellReuseIdentifier: "RootCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RootCell") as? RootCell {
            cell.titleL.text = dataArr[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            playMusic()
            break
        case 1:
            recordAudio()
            break
        case 2:
            playMIDI()
            break
        default:
            break
        }
    }
    func recordAudio() {
        self.navigationController?.pushViewController(RecordController(nibName: "RecordController", bundle: nil), animated: true)
    }
    
    func playMIDI() {
        self.navigationController?.pushViewController(MIDIPlayController(nibName: "MIDIPlayController", bundle: nil), animated: true)
    }
    func playMusic() {
        self.navigationController?.pushViewController(ShakeDemoController(nibName: "ShakeDemoController", bundle: nil), animated: true)
//        self.navigationController?.pushViewController(MusicController(nibName: "MusicController", bundle: nil), animated: true)
    }
}
