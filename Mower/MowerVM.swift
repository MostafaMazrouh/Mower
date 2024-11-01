//
//  MowerVM.swift
//  Mower
//
//  Created by Mostafa Mazrouh on 2024-10-30.
//

import Foundation


@Observable
class MowerVM: ObservableObject {
    
    var mowerStatus: MowerStatus = .disconnected
    
    var mowerInteractor: MowerRepo
    
    init(mowerInteractor: MowerRepo) {
        self.mowerInteractor = mowerInteractor
    }
    
    // MARK: - Mower Control Methods
    
    func connectToMower() async {
        let isConnected = await mowerInteractor.connect()
        mowerStatus = isConnected ? .connected : .disconnected
    }
    
    func startMower() {
        Task {
            if await mowerInteractor.operate(operation: .start) {
                mowerStatus = .running
            }
        }
    }
    
    func stopMower() {
        Task {
            if await mowerInteractor.operate(operation: .stop) {
                mowerStatus = .stopped
            }
        }
    }
    
    func pauseMower() {
        Task {
            if await mowerInteractor.operate(operation: .pause) {
                mowerStatus = .paused
            }
        }
    }
    
    func resumeMower() {
        Task {
            if await mowerInteractor.operate(operation: .resume) {
                mowerStatus = .resumed
            }
        }
    }
}
