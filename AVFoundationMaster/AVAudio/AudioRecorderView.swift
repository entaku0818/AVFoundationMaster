//
//  AudioRecorderView.swift
//  AVFoundationMaster
//
//  Created by 遠藤拓弥 on 2024/09/08.
//

import SwiftUI
import AVFoundation

struct AudioRecorderView: View {
    @StateObject private var recorderManager = AudioRecorderManager()
    @State private var recordings: [URL] = []
    @State private var selectedRecording: URL?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false

    var body: some View {
        NavigationView {
            VStack {
                recordingControls
                recordingsList
            }
            .navigationTitle("Audio Recorder")
            .onAppear(perform: loadRecordings)
        }
    }

    private var recordingControls: some View {
        VStack {
            Text(timeString(from: recorderManager.recordingTime))
                .font(.largeTitle)
                .padding()

            Button(action: toggleRecording) {
                Image(systemName: recorderManager.isRecording ? "stop.circle.fill" : "record.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .foregroundColor(recorderManager.isRecording ? .red : .blue)
            }
            .padding()
        }
    }

    private var recordingsList: some View {
        List {
            ForEach(recordings, id: \.self) { recording in
                HStack {
                    Text(recording.lastPathComponent)
                    Spacer()
                    Button(action: { playRecording(url: recording) }) {
                        Image(systemName: (isPlaying && selectedRecording == recording) ? "pause.circle" : "play.circle")
                    }
                }
            }
            .onDelete(perform: deleteRecordings)
        }
    }

    private func toggleRecording() {
        if recorderManager.isRecording {
            recorderManager.stopRecording()
            loadRecordings()
        } else {
            recorderManager.startRecording()
        }
    }

    private func loadRecordings() {
        recordings = recorderManager.getRecordings().sorted(by: { $0.lastPathComponent > $1.lastPathComponent })
    }

    private func deleteRecordings(at offsets: IndexSet) {
        for index in offsets {
            let recordingToDelete = recordings[index]
            recorderManager.deleteRecording(at: recordingToDelete)
        }
        loadRecordings()
    }

    private func playRecording(url: URL) {
        if selectedRecording == url && isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                selectedRecording = url
                isPlaying = true
            } catch {
                print("Failed to play recording: \(error)")
            }
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct AudioRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRecorderView()
    }
}
