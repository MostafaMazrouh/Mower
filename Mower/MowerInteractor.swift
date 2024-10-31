//
//  MowerInteractor.swift
//  Mower
//
//  Created by Mostafa Mazrouh on 2024-10-31.
//

import CoreBluetooth
import Foundation

class MowerInteractor: NSObject, MowerRepo {
    static let shared = MowerInteractor()
    
    private lazy var centralManager: CBCentralManager =
    CBCentralManager(delegate: self, queue: nil)
    
    private var mowerPeripheral: CBPeripheral?
    
    private let mowerServiceUUID =
    CBUUID(string: "1234A000-5678-9ABC-DEF0-1234567890AB")
    
    private let startStopCharacteristicUUID =
    CBUUID(string: "1234A001-5678-9ABC-DEF0-1234567890AB")
    
    private let pauseCharacteristicUUID =
    CBUUID(string: "1234A002-5678-9ABC-DEF0-1234567890AB")
    
    private var startStopCharacteristic: CBCharacteristic?
    private var pauseCharacteristic: CBCharacteristic?
    
    private var connectContinuation: CheckedContinuation<Bool, Never>?
    private var operateContinuation: CheckedContinuation<Bool, Never>?
    
    private var isConnected = false
    
    func connect() async -> Bool {
        return await withCheckedContinuation { continuation in
            connectContinuation = continuation
            
            /*
             Inisializing centralManager will call the following:
             1. centralManagerDidUpdateState
             2. didDiscover
             3. didConnect
             And didConnect will resume the connectContinuation
             */
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    func operate(operation: Operation) async -> Bool {
        
        // Make sure Mower is connected before we operate
        if isConnected == false {
            let connect = await connect()
            guard connect else { return false }
        }
        
        var characteristic: CBCharacteristic?
        var command: UInt8?
        
        switch operation {
        case .start:
            characteristic = startStopCharacteristic
            command = 1
        
        case .stop:
            characteristic = startStopCharacteristic
            command = 0
            
        case .pause:
            characteristic = pauseCharacteristic
            command = 1
            
        case .resume:
            characteristic = pauseCharacteristic
            command = 0
        }
        
        guard let characteristic = characteristic,
              let command = command else { return false }
        
        return await withCheckedContinuation { continuation in
            operateContinuation = continuation
            
            let data = Data([command])
            mowerPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}

extension MowerInteractor: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .unknown:
            print("central.state: unknown")
        case .resetting:
            print("central.state: resetting")
        case .unsupported:
            print("central.state: unsupported")
        case .unauthorized:
            print("central.state: unauthorized")
        case .poweredOff:
            print("central.state: poweredOff")
        case .poweredOn:
            print("central.state: poweredOn")
            
//            let mowerServiceCBUUID = CBUUID(string: "1234A000-5678-9ABC-DEF0-1234567890AB")
            // Scan all Peripherals and search for Mower
            centralManager.scanForPeripherals(withServices: nil)
            
        @unknown default:
            fatalError()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Find "Mower" by localName key in the advertisementData
        // Because peripheral.name == Mac's name
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String, localName == "Mower" {
            print("Found Mower..")
            
            // Stop scanning once we find the Mower device
            central.stopScan()
            
            // Keep a reference to the peripheral to connect
            mowerPeripheral = peripheral
            mowerPeripheral?.delegate = self
            if let mowerPeripheral = mowerPeripheral {
                central.connect(mowerPeripheral, options: nil)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([mowerServiceUUID])
    }
}

extension MowerInteractor: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        guard let services = peripheral.services else { return }
        
        for service in services where service.uuid == mowerServiceUUID {
            print("Mower Control Service found.")
            mowerPeripheral?.discoverCharacteristics([startStopCharacteristicUUID, pauseCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == startStopCharacteristicUUID {
                startStopCharacteristic = characteristic
                print("Start/Stop Characteristic found.")
            } else if characteristic.uuid == pauseCharacteristicUUID {
                pauseCharacteristic = characteristic
                print("Pause Characteristic found.")
            }
        }
        
        print("Connected to Mower")
        isConnected = true
        connectContinuation?.resume(returning: true)
        connectContinuation = nil
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        
        if error != nil {
            operateContinuation?.resume(returning: false)
        } else {
            operateContinuation?.resume(returning: true)
        }
        operateContinuation = nil
    }
}

