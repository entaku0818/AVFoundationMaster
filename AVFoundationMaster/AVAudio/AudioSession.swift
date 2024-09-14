//
//  AudioSession.swift
//  AVFoundationMaster
//
//  Created by 遠藤拓弥 on 2024/09/14.
//

import Foundation
import SwiftUI
import AVFoundation

struct AudioSessionView: View {
    @StateObject private var audioSessionManager = AudioSessionManager()

     var body: some View {
             List {
                 Section(header: Text("ポート (Ports)")) {
                     ForEach(audioSessionManager.availablePorts, id: \.portName) { port in
                         Button(action: {
                             audioSessionManager.setPreferredInput(port: port)
                         }) {
                             HStack {
                                 Text(port.portName)
                                 Spacer()
                                 Text(port.portType.rawValue)
                                     .font(.caption)
                                     .foregroundColor(.secondary)
                             }
                         }
                     }
                 }

                 Section(header: Text("カテゴリ (Categories)")) {
                     ForEach(audioSessionManager.categories, id: \.self) { category in
                         Button(action: {
                             audioSessionManager.setCategory(category)
                         }) {
                             Text(category.rawValue)
                         }
                     }
                 }

                 Section(header: Text("モード (Modes)")) {
                     ForEach(audioSessionManager.modes, id: \.self) { mode in
                         Button(action: {
                             audioSessionManager.setMode(mode)
                         }) {
                             Text(mode.rawValue)
                         }
                     }
                 }

                 Section(header: Text("オプション (Options)")) {
                     ForEach(AudioSessionManager.OptionWrapper.allCases, id: \.self) { option in
                         Toggle(isOn: Binding(
                             get: { audioSessionManager.isOptionEnabled(option.option) },
                             set: { isOn in
                                 audioSessionManager.toggleOption(option.option, isOn: isOn)
                             }
                         )) {
                             Text(option.description)
                         }
                     }
                 }
             }
             .listStyle(GroupedListStyle())
             .navigationTitle("AudioSession Tester")
         .alert(item: $audioSessionManager.alertItem) { alertItem in
             Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
         }
     }
 }

 class AudioSessionManager: ObservableObject {
     private let audioSession = AVAudioSession.sharedInstance()

     @Published var availablePorts: [AVAudioSessionPortDescription] = []
     @Published var alertItem: AlertItem?

     private var enabledOptions: AVAudioSession.CategoryOptions = []

     let categories: [AVAudioSession.Category] = [.ambient, .soloAmbient, .playback, .record, .playAndRecord, .multiRoute]
     let modes: [AVAudioSession.Mode] = [.default, .voiceChat, .gameChat, .videoRecording, .measurement, .moviePlayback, .videoChat, .spokenAudio, .voicePrompt]

     enum OptionWrapper: CaseIterable {
         case mixWithOthers, duckOthers, interruptSpokenAudioAndMixWithOthers, allowBluetooth, allowBluetoothA2DP, allowAirPlay, defaultToSpeaker, overrideMutedMicrophoneInterruption

         var option: AVAudioSession.CategoryOptions {
             switch self {
             case .mixWithOthers: return .mixWithOthers
             case .duckOthers: return .duckOthers
             case .interruptSpokenAudioAndMixWithOthers: return .interruptSpokenAudioAndMixWithOthers
             case .allowBluetooth: return .allowBluetooth
             case .allowBluetoothA2DP: return .allowBluetoothA2DP
             case .allowAirPlay: return .allowAirPlay
             case .defaultToSpeaker: return .defaultToSpeaker
             case .overrideMutedMicrophoneInterruption: return .overrideMutedMicrophoneInterruption
             }
         }

         var description: String {
             switch self {
             case .mixWithOthers: return "Mix With Others"
             case .duckOthers: return "Duck Others"
             case .interruptSpokenAudioAndMixWithOthers: return "Interrupt Spoken Audio And Mix With Others"
             case .allowBluetooth: return "Allow Bluetooth"
             case .allowBluetoothA2DP: return "Allow Bluetooth A2DP"
             case .allowAirPlay: return "Allow AirPlay"
             case .defaultToSpeaker: return "Default To Speaker"
             case .overrideMutedMicrophoneInterruption: return "Override Muted Microphone Interruption"
             }
         }
     }

     init() {
         updateAvailablePorts()
     }

     func updateAvailablePorts() {
         availablePorts = audioSession.availableInputs ?? []
     }

     func setPreferredInput(port: AVAudioSessionPortDescription) {
         do {
             try audioSession.setPreferredInput(port)
             showAlert(title: "成功", message: "\(port.portName) が設定されました")
         } catch {
             showAlert(title: "エラー", message: "ポートの設定に失敗しました: \(error.localizedDescription)")
         }
     }

     func setCategory(_ category: AVAudioSession.Category) {
         do {
             try audioSession.setCategory(category, options: enabledOptions)
             showAlert(title: "成功", message: "\(category.rawValue) カテゴリが設定されました")
         } catch {
             showAlert(title: "エラー", message: "カテゴリの設定に失敗しました: \(error.localizedDescription)")
         }
     }

     func setMode(_ mode: AVAudioSession.Mode) {
         do {
             try audioSession.setMode(mode)
             showAlert(title: "成功", message: "\(mode.rawValue) モードが設定されました")
         } catch {
             showAlert(title: "エラー", message: "モードの設定に失敗しました: \(error.localizedDescription)")
         }
     }

     func isOptionEnabled(_ option: AVAudioSession.CategoryOptions) -> Bool {
         enabledOptions.contains(option)
     }

     func toggleOption(_ option: AVAudioSession.CategoryOptions, isOn: Bool) {
         if isOn {
             enabledOptions.insert(option)
         } else {
             enabledOptions.remove(option)
         }

         do {
             try audioSession.setCategory(audioSession.category, options: enabledOptions)
             showAlert(title: "成功", message: "オプションが更新されました")
         } catch {
             showAlert(title: "エラー", message: "オプションの設定に失敗しました: \(error.localizedDescription)")
         }
     }

     private func showAlert(title: String, message: String) {
         alertItem = AlertItem(title: title, message: message)
     }
 }

 struct AlertItem: Identifiable {
     let id = UUID()
     let title: String
     let message: String
 }
