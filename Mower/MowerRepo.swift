//
//  MowerRepo.swift
//  Mower
//
//  Created by Mostafa Mazrouh on 2024-10-30.
//

import Foundation

enum MowerStatus: String {
    case disconnected
    case connecting
    case connected
    case running
    case paused
    case resumed
    case stopped
}

enum Operation {
    case start
    case stop
    case pause
    case resume
}

protocol MowerRepo {
    func connect() async -> Bool
    func operate(operation: Operation) async -> Bool
}
