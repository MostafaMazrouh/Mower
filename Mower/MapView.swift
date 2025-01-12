//
//  MapView.swift
//  Mower
//
//  Created by Mostafa Mazrouh on 2025-01-10.
//

import SwiftUI


@Observable
class MapVM: ObservableObject {}

struct MapView: View {
    
    private let mapImage = UIImage(named: "Garden")!
    
    @State private var rotationAngle: Angle = .zero
    @State private var lastAngle: Angle = .zero
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    Image(uiImage: mapImage)
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(lastAngle + rotationAngle)
                        .gesture(
                            RotationGesture()
                                .onChanged { value in
                                    guard !value.radians.isNaN else {
                                        return
                                    }
                                    rotationAngle = value
                                }
                                .onEnded { _ in
                                    print("Rotation ended: \(rotationAngle.degrees)°")
                                    lastAngle += rotationAngle
                                    rotationAngle = .zero
                                }
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .border(Color.gray)
        }
        .padding()
    }
}


#Preview {
    MapView()
}
