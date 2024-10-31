//
//  MowerIntent.swift
//  Mower
//
//  Created by Mostafa Mazrouh on 2024-10-31.
//

import AppIntents
import CoreBluetooth

struct MowerShortcut: AppShortcutsProvider {
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartMowerIntent(),
            phrases: ["Start Mower"],
            shortTitle: "Start Mower",
            systemImageName: "button.programmable.square.fill"
        )
    }
}


// Define the intent to start the mower
struct StartMowerIntent: AppIntent {
    
    // The display name of the intent, which shows in Siri and Shortcuts
    static var title: LocalizedStringResource = "Start Mower"
    
    // Suggested invocation phrase
    static var suggestedInvocationPhrase: String = "Start the mower"
    
    // Initialize Bluetooth device (assuming you have a shared MowerDevice instance)
    private var mowerInteractor = MowerInteractor.shared

    // Perform the action when the intent is invoked
    func perform() async throws -> some IntentResult {
        // Attempt to start the mower
        var message = ""
        if await mowerInteractor.operate(operation: .start) {
            message = "Mower is running now.."
        } else {
            message = "Something went wrong, please try again."
        }
        
        // Return a success response to indicate the action completed
        return .result(
            value: message
        )
    }
}

