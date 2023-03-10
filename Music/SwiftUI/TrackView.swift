//
//  TrackView.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/22.
//

import SwiftUI
import AudioKit
import AudioKitUI
import AVFAudio

struct TrackView: View {
    @StateObject var viewModel = MIDITrackViewModel()
    @State var fileURL: URL?  = Bundle.main.url(forResource: "QingHuaCi", withExtension: "mid")
    @State var bankName: String = "Electric_Piano"
    @State var isPlaying = false
    var segmentArr =  ["Electric_Piano","BangDi","Nylon Guitar", "Guzheng","Pipa","Tenor_Sax","Flute"]
    @State private var index:Int = 0
    @State var tempo:Float = 120
    
    
    @State var timeText: String = "0.00"
    @State var isPause: Bool = false
    @State var isStart: Bool = false
    @State private var startTime = Date()
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var dismiss: (() -> Void)?
    var recordSucces:((_ file:AVAudioFile,_ bankName:String) -> Void)?
    
    var body: some View {
        VStack {
            Button("编曲") {
                self.dismiss?()
            }
            GeometryReader { geometry in
                ScrollView {
                    if let fileURL = fileURL {
                        ForEach(
                            MIDIFile(url: fileURL).tracks.indices, id: \.self
                        ) { number in
                            MIDITrackView(fileURL: $fileURL,
                                          trackNumber: number,
                                          trackWidth: geometry.size.width,
                                          trackHeight: 200.0)
                                .background(Color.primary)
                                .cornerRadius(10.0)
                        }
                    }
                }
            }
            Picker("WAVEFORM", selection: $index) {
                ForEach(0..<segmentArr.count,id:\.self){ index in
                    Text(segmentArr[index]).tag(index)
                }
            }.accentColor(.red)
            .onChange(of: index, perform: { newValue in
                print("选择",newValue)
                bankName = segmentArr[index]
                if let fileURL = fileURL {
                    viewModel.loadSequencerFile(fileURL: fileURL, bankName:segmentArr[index])
                }
            })
            HStack {
                Text("Tempo:").font(.caption).foregroundColor(Color.black)
                Text(String(format: "%0.1f", tempo)).font(.caption).foregroundColor(Color.black)
                    .frame(width: 60.0, alignment: .leading)
                Slider(value: $tempo,
                       in: 60.0...300.0,onEditingChanged: { result in
                    viewModel.tempo = tempo
                })
                .accentColor(Color.red)
                .foregroundColor(Color.orange)
            }
            Spacer()
            Text(timeText)
                        .font(.system(size: 48))
                        .padding(.horizontal)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .onReceive(timer) { _ in
                            if self.isStart {
                                timeText = String(format: "%.2f", Date().timeIntervalSince(self.startTime))
                                if Float(timeText) ?? 0.0 >= 20.0 {
                                    isPlaying = false
                                    viewModel.isRecording = false
                                    self.timer.upstream.connect().cancel()
                                    if viewModel.audioFile != nil {
                                        self.recordSucces?(viewModel.audioFile!, bankName)
                                    }
                                    self.isPause = true
                                    self.stopTimer()
                                }
                            }
                       }
            Spacer()
            Text(viewModel.isRecording ? "Stop Play" : "Play")
                .foregroundColor(.blue)
                .onTapGesture {
                    if viewModel.isRecording {
//                        if Float(timeText) ?? 0.0 < 20 {
//                            return
//                        }
                        isPlaying = false
                        viewModel.isRecording = false
                        self.timer.upstream.connect().cancel()
//                        if viewModel.audioFile != nil {
//                            self.dismiss?(viewModel.audioFile!)
//                        }
                        self.isPause = true
                        self.stopTimer()
                    }else{
                        if isPlaying {
                            isPlaying = false
                            if let fileURL = fileURL {
                                viewModel.loadSequencerFile(fileURL: fileURL, bankName:bankName)
                            }
                        }
                        isPlaying = true
                        viewModel.isRecording = true
                        
                        self.isStart = true
                        timeText = "0.00"
                        startTime = Date()
                        self.startTimer()
                    }
            }
        }
        .padding()
        .onAppear(perform: {
            viewModel.startEngine()
            if let fileURL = fileURL {
                viewModel.loadSequencerFile(fileURL: fileURL, bankName: bankName)
            }
        })
        .onTapGesture {
//            isPlaying.toggle()
        }
        .onChange(of: isPlaying, perform: { newValue in
            if newValue == true {
                viewModel.play()
            } else {
                viewModel.stop()
            }
        })
        .onDisappear(perform: {
            self.stopTimer()
            viewModel.stop()
            viewModel.stopEngine()
        })
        .environmentObject(viewModel)
    }
    // 开始计时方法
    func startTimer() {
        timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    }
    // 停止计时方法
    func stopTimer() {
        timer.upstream.connect().cancel()
    }
}

//struct TrackView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackView()
//    }
//}

