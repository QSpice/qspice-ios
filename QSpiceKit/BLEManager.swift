import Foundation
import CoreBluetooth

@objc public protocol BLEManagerDelegate: class {
    @objc optional func managerDidUpdateState(_ manager: BLEManager)
    @objc optional func manager(_ manager: BLEManager, didDiscover peripheral: CBPeripheral)
    @objc optional func manager(_ manager: BLEManager, didConnect peripheral: CBPeripheral)
    @objc optional func manager(_ manager: BLEManager, didDisconnect peripheral: CBPeripheral)
    @objc optional func manager(_ manager: BLEManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
    @objc optional func manager(_ manager: BLEManager, didReceive message: String, error: Error?)
}

public class BLEManager: NSObject {
    
    public static let shared = BLEManager()
    
    private var centralManager: CBCentralManager!
    
    public weak var delegate: BLEManagerDelegate?
    
    public var peripheral: CBPeripheral?
    
    private var messageBuffer: String = ""
    
    private var writeType: CBCharacteristicWriteType = .withoutResponse
    private weak var writeCharacteristic: CBCharacteristic?
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private let serviceUUID = CBUUID(string: "FFE0")
    private let characteristicUUID = CBUUID(string: "FFE1")
    
    public var isPoweredOn: Bool {
        return centralManager.state == .poweredOn
    }
    
    public var isReady: Bool {
        return isPoweredOn && peripheral != nil && writeCharacteristic != nil
    }
    
    public func write(message: String) {
        guard isReady else { return }
        
        if let data = message.appending("\n").data(using: String.Encoding.utf8) {
            peripheral?.writeValue(data, for: writeCharacteristic!, type: writeType)
        }
    }
    
    public func scan() {
        guard centralManager.state == .poweredOn else { return }
        
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    public func stopScan() {
        centralManager.stopScan()
    }
    
    public func connectTo(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    public func reconnect(uuid: UUID) {
        if let peripheral = centralManager.retrievePeripherals(withIdentifiers: [uuid]).first {
            self.peripheral = peripheral
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    public func disconnect() {
        if let peripheral = peripheral {
            UserDefaults.standard.removeObject(forKey: "ble_identifier")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    public func powerUp() {
        
    }
}

extension BLEManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: Core Bluetooth manager delegate
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOff {
            disconnect()
        }
        
        if central.state == .poweredOn {
            if let uuidString = UserDefaults.standard.string(forKey: "ble_identifier"), let uuid = UUID(uuidString: uuidString) {
                reconnect(uuid: uuid)
            }
        }
        
        delegate?.managerDidUpdateState?(self)
    }
    
    private func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        delegate?.manager?(self, didDiscover: peripheral)
    }
    
    private func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: "ble_identifier")
        self.peripheral?.delegate = self
        
        delegate?.manager?(self, didConnect: peripheral)
        
        peripheral.discoverServices([serviceUUID])
    }
    
    private func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        
        delegate?.manager?(self, didFailToConnect: peripheral, error: error)
    }
    
    private func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        
        delegate?.manager?(self, didDisconnect: peripheral)
    }
    
    // MARK: Core Bluetooth peripheral delegate
    
    private func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    private func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics where characteristic.uuid == characteristicUUID {
            peripheral.setNotifyValue(true, for: characteristic)
            
            writeCharacteristic = characteristic
            
            writeType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
        }
    }
    
    private func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else {
            return
        }
        
        if let message = String(data: data, encoding: String.Encoding.utf8) {
            messageBuffer += message
            
            if message.last == "\n" {
                messageBuffer.removeLast()
                print(messageBuffer)
                delegate?.manager?(self, didReceive: messageBuffer, error: error)
                messageBuffer = ""
            }
        }
        
    }
}
