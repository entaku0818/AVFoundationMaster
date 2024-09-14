//
//  AudioSession.swift
//  AVFoundationMaster
//
//  Created by 遠藤拓弥 on 2024/09/14.
//

import Foundation
import SwiftUI

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

 
