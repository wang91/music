//
//  TrackView.swift
//  Music
//
//  Created by YouKe Wang on 2023/2/22.
//

import SwiftUI
import AudioKit
import AudioKitUI

struct TrackView: View {
    @StateObject var viewModel = MIDITrackViewModel()
    @State var fileURL: URL? = Bundle.main.url(forResource: "Demo", withExtension: "mid")
    @State var bankName: String = "Electric_Piano"
    @State var isPlaying = false
    var segmentArr =  ["Electric_Piano","Grand_Piano","Violin","Accordion"]
    @State private var index:Int = 0
    var body: some View {
        VStack {
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
                if let fileURL = fileURL {
                    viewModel.loadSequencerFile(fileURL: fileURL, bankName:segmentArr[index])
                }
            })
        }
        .padding()
        .onAppear(perform: {
            viewModel.startEngine()
            if let fileURL = fileURL {
                viewModel.loadSequencerFile(fileURL: fileURL, bankName: "Electric_Piano")
            }
        })
        .onTapGesture {
            isPlaying.toggle()
        }
        .onChange(of: isPlaying, perform: { newValue in
            if newValue == true {
                viewModel.play()
            } else {
                viewModel.stop()
            }
        })
        .onDisappear(perform: {
            viewModel.stop()
            viewModel.stopEngine()
        })
        .environmentObject(viewModel)
    }
}

struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        TrackView()
    }
}
