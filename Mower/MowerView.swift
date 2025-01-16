//
//  MowerView.swift
//  Mower
//
//  Created by Mostafa Mazrouh on 2024-10-30.
//

import SwiftUI

struct MowerView: View {
    
    @State private var mowerVM = MowerVM(mowerInteractor: MowerInteractor())
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Mower Status: \(mowerVM.mowerStatus.description)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor((mowerVM.mowerStatus == .connected ||
                                      mowerVM.mowerStatus == .running) ? .green : .red)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    .animation(.easeInOut, value: mowerVM.mowerStatus)
                
                ActionButton(
                    title: "Connect to Mower",
                    action: {
                        Task {
                            await mowerVM.connectToMower()
                        }
                    },
                    isEnabled: mowerVM.mowerStatus == .disconnected,
                    buttonColor: Color.blue
                )
                
                HStack {
                    ActionButton(
                        title: "Start",
                        action: {
                            mowerVM.startMower()
                        },
                        isEnabled: (mowerVM.mowerStatus == .connected ||
                                    mowerVM.mowerStatus == .stopped),
                        buttonColor: Color.green
                    )
                    
                    ActionButton(
                        title: "Stop",
                        action: {
                            mowerVM.stopMower()
                        },
                        isEnabled: (mowerVM.mowerStatus == .running ||
                                    mowerVM.mowerStatus == .paused ||
                                    mowerVM.mowerStatus == .resumed),
                        buttonColor: Color.red
                    )
                }
                
                HStack {
                    ActionButton(
                        title: "Pause",
                        action: {
                            mowerVM.pauseMower()
                        },
                        isEnabled: (mowerVM.mowerStatus == .running ||
                                    mowerVM.mowerStatus == .resumed),
                        buttonColor: Color.orange // Example color for Pause
                    )
                    
                    ActionButton(
                        title: "Resume",
                        action: {
                            mowerVM.resumeMower()
                        },
                        isEnabled: (mowerVM.mowerStatus == .paused),
                        buttonColor: Color.yellow
                    )
                }
                
                NavigationLink(destination: MapView()) {
                    Text("Map")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.brown)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        .padding()
                }
            }
        }
        .navigationTitle("Mower")
    }
}


struct ActionButton: View {
    var title: String
    var action: () -> Void
    var isEnabled: Bool
    var buttonColor: Color
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isEnabled ? buttonColor : Color.gray)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .disabled(!isEnabled)
        .padding()
    }
}

private extension MowerStatus {
    var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .running: return "Running"
        case .paused: return "Paused"
        case .resumed: return "Resumed"
        case .stopped: return "Stopped"
        }
    }
}
