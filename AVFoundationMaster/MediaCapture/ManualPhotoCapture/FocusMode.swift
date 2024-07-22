//
//  FocusMode.swift
//  
//  
//  Created by Naoya Maeda on 2024/07/21
//  
//

enum FocusMode: String, CaseIterable, Identifiable {
    case autoFocus = "AutoFocus"
    case continuous = "Continuous"
    case locked = "Locked"

    var id: String { rawValue }
}
