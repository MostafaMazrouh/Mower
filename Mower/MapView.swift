//
//  MapView.swift
//  Mower
//
//  Created by Mostafa Mazrouh on 2025-01-10.
//

import SwiftUI

@Observable
class MapVM: ObservableObject {
    
    var rotationAngle: Angle = .zero
    var lastAngle: Angle = .zero
    
    private var fingerPositions: [Int: CGPoint] = [:]
    private var activeFingers: [Int] = []
    
    func updateFingerPosition(index: Int, position: CGPoint) {
        fingerPositions[index] = position
        if !activeFingers.contains(index) {
            activeFingers.append(index)
            if activeFingers.count > 2 {
                activeFingers.removeFirst() // Keep only the last two active fingers
            }
        }
    }
    
    // Clear finger position on drag end
    func clearFinger(index: Int) {
        fingerPositions.removeValue(forKey: index)
        activeFingers.removeAll { $0 == index }
    }
    
    // Calculate the centroid of two active fingers
    var centroid: CGPoint? {
        guard activeFingers.count == 2,
              let pos1 = fingerPositions[activeFingers[0]],
              let pos2 = fingerPositions[activeFingers[1]] else {
            return nil
        }
        return CGPoint(x: (pos1.x + pos2.x) / 2, y: (pos1.y + pos2.y) / 2)
    }
}

struct MapView: View {
    @ObservedObject private var mapVM = MapVM()
    private let mapImage = UIImage(named: "Garden")!
    
    var body: some View {
        VStack {
            Text("Reset")
            
            GeometryReader { geometry in
                ZStack {
                    
                    // Map Image
//                    Image(uiImage: mapImage)
//                        .resizable()
//                        .rotationEffect(mapVM.lastAngle + mapVM.rotationAngle,
//                                        anchor: anchorPoint(for: mapVM.centroid, in: geometry))
//                        .simultaneousGesture(
//                            RotationGesture()
//                                .onChanged { value in
//                                    guard !value.radians.isNaN else { return }
//                                    mapVM.rotationAngle = value
//                                }
//                                .onEnded { _ in
//                                    mapVM.lastAngle += mapVM.rotationAngle
//                                    mapVM.rotationAngle = .zero
//                                }
//                        )
                    
                    // Grid of areas
                    VStack(spacing: 1) {
                        HStack(spacing: 1) {
                            Area(index: 0, mapVM: mapVM)
                            Area(index: 1, mapVM: mapVM)
                        }
                        HStack(spacing: 1) {
                            Area(index: 2, mapVM: mapVM)
                            Area(index: 3, mapVM: mapVM)
                        }
                    }
                    
                    // Centroid display
                    if let centroid = mapVM.centroid {
                        Circle()
                            .fill(Color.green.opacity(0.8))
                            .frame(width: 20, height: 20)
                            .position(centroid)
                    }
                }
                .frame(width: 400, height: 400)
                .background(Color.blue)
            }
            .coordinateSpace(name: "MapGeometry")
        }
    }
    
    /// Computes the rotation anchor based on the centroid
    private func anchorPoint(for centroid: CGPoint?, in geometry: GeometryProxy) -> UnitPoint {
        guard let centroid = centroid else { return .center }
        
        
        
        return UnitPoint(
            x: centroid.x / geometry.size.width,
            y: centroid.y / geometry.size.height
        )
    }
}

struct Area: View {
    let index: Int
    @ObservedObject var mapVM: MapVM
    
    var body: some View {
        GeometryReader { localGeometry in
            Color.red
                .cornerRadius(10)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let globalPosition = CGPoint(
                                x: value.location.x + localGeometry.frame(in: .named("MapGeometry")).origin.x,
                                y: value.location.y + localGeometry.frame(in: .named("MapGeometry")).origin.y
                            )
                            mapVM.updateFingerPosition(index: index, position: globalPosition)
                        }
                        .onEnded { _ in
                            mapVM.clearFinger(index: index)
                        }
                )
        }
        .coordinateSpace(name: "AreaGeometry")
        .padding()
    }
}



#Preview {
    MapView()
}
