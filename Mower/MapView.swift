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
    
    private(set)var fingerGlobal: [Int: CGPoint] = [:]
    private(set)var fingerLocal: [Int: CGPoint] = [:]
    private var activeFingers: [Int] = []
    
    func updateFingerPosition(index: Int, global: CGPoint, local: CGPoint) {
        fingerGlobal[index] = global
        fingerLocal[index] = local
        if !activeFingers.contains(index) {
            activeFingers.append(index)
            if activeFingers.count > 2 {
                activeFingers.removeFirst() // Keep only the last two active fingers
            }
        }
    }
    
    // Clear finger position on drag end
    func clearFinger(index: Int) {
        fingerGlobal.removeValue(forKey: index)
        fingerLocal.removeValue(forKey: index)
        activeFingers.removeAll { $0 == index }
    }
    
    func reset() {
        fingerGlobal.removeAll()
        activeFingers.removeAll()
        rotationAngle = .zero
        lastAngle = .zero
    }
    
    // Calculate the centroid of two active fingers
    var centroid: CGPoint? {
        guard activeFingers.count == 2,
              let pos1 = fingerGlobal[activeFingers[0]],
              let pos2 = fingerGlobal[activeFingers[1]] else {
            return nil
        }
        return CGPoint(x: (pos1.x + pos2.x) / 2, y: (pos1.y + pos2.y) / 2)
    }
    
    /// Computes the rotation anchor based on the centroid
    func anchorPoint(for centroid: CGPoint?, in geometry: GeometryProxy) -> UnitPoint {
        guard let centroid = centroid else { return .center }
        
        return UnitPoint(
            x: centroid.x / geometry.size.width,
            y: centroid.y / geometry.size.height
        )
    }
}

struct MapView: View {
    @ObservedObject private var mapVM = MapVM()
    private let mapImage = UIImage(named: "Garden")!
    
    var body: some View {
        VStack {
            Spacer()
            
            GeometryReader { geometry in
                ZStack {
                    
                    // Map Image
                    Image(uiImage: mapImage)
                        .resizable()
                        .rotationEffect(mapVM.lastAngle + mapVM.rotationAngle,
                                        anchor: mapVM.anchorPoint(for: mapVM.centroid,
                                                                  in: geometry))
                    
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
                    .simultaneousGesture(
                        RotationGesture()
                            .onChanged { value in
                                guard !value.radians.isNaN else { return }
                                mapVM.rotationAngle = value
                            }
                            .onEnded { _ in
                                mapVM.lastAngle += mapVM.rotationAngle
                                mapVM.rotationAngle = .zero
                            }
                    )
                    
                    // Centroid display
                    if let centroid = mapVM.centroid {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 30, height: 30)
                            .position(centroid)
                    }
                }
                .frame(width: 400, height: 400)
            }
            .coordinateSpace(name: "MapGeometry")
            .frame(width: 400, height: 400)
            
            Spacer()
        }
        .onDisappear {
            mapVM.reset()
        }
    }
}

struct Area: View {
    let index: Int
    @ObservedObject var mapVM: MapVM
    
    var body: some View {
        GeometryReader { localGeometry in
            ZStack {
                Color.black.opacity(0.1)
                    .cornerRadius(10)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let globalPosition = CGPoint(
                                    x: value.location.x + localGeometry.frame(in: .named("MapGeometry")).origin.x,
                                    y: value.location.y + localGeometry.frame(in: .named("MapGeometry")).origin.y
                                )
                                mapVM.updateFingerPosition(index: index, global: globalPosition, local: value.location)
                            }
                            .onEnded { _ in
                                mapVM.clearFinger(index: index)
                            }
                    )
                
                if let position = mapVM.fingerLocal[index] {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 30, height: 30)
                        .position(position)
                        .overlay(
                            Text("\(index)")
                                .foregroundColor(.white)
                                .bold()
                        )
                }
            }
        }
        .coordinateSpace(name: "AreaGeometry")
        .padding()
    }
}



#Preview {
    MapView()
}
