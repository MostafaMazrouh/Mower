//
//  MowerTests.swift
//  MowerTests
//
//  Created by Mostafa Mazrouh on 2024-10-30.
//

import Testing
@testable import Mower

class MowerInteractorMock: MowerRepo {
    
    func connect() async -> Bool {
        return true
    }
    
    func operate(operation: Mower.Operation) async -> Bool {
        return true
    }
}

struct MowerTests {
    
    @Test("Test connectivity to mower") func example() async throws {
        let mowerInteractor = MowerInteractorMock()
        let mowerVM = MowerVM(mowerInteractor: mowerInteractor)
        await mowerVM.connectToMower()
        #expect(mowerVM.mowerStatus == .stopped)
    }

}
