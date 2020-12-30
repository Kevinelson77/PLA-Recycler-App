//
//  ContentView.swift
//  SeniorDesign
//
//  Created by Kevin Nelson on 12/29/20.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    var body: some View {
        ZStack{
            BackgroundView()
            VStack(alignment: .leading, spacing: 40.0){
                TimeRemaining(Time: 1)
                PlasticType(Plastic: "PLA")
                Temperature(Temp: 180)
                FanSpeed(Fan: 1000)
                AugerSpeed(Auger: 60)
                DiameterOverTime(Diameter: 1.75)
                LineGraphView()
                Spacer()
            }
            }
        }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BackgroundView: View {
    var body: some View{
        LinearGradient(gradient: Gradient(colors: [.blue, .black]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

struct TimeRemaining: View {
    var Time: Int
    var body: some View{
        Text("Time Remaining: \(Time) minute")
            .font(.system(size: 30, weight: .medium))
            .foregroundColor(.white)
            .padding(.top, 50)
    }
}

struct PlasticType: View {
    var Plastic: String
    var body: some View{
        Text("Plastic Type: \(Plastic)")
            .font(.system(size: 30, weight: .medium))
            .foregroundColor(.white)
    }
}

struct Temperature: View {
    var Temp: Int
    var body: some View{
        Text("Temperature: \(Temp)°")
            .font(.system(size: 30, weight: .medium))
            .foregroundColor(.white)
    }
}

struct FanSpeed: View {
    var Fan: Int
    var body: some View{
        Text("Fan Speed: \(Fan) RPM")
            .font(.system(size: 30, weight: .medium))
            .foregroundColor(.white)
    }
}

struct AugerSpeed: View {
    var Auger: Int
    var body: some View{
        Text("Auger Speed: \(Auger) RPM")
            .font(.system(size: 30, weight: .medium))
            .foregroundColor(.white)
    }
}

struct DiameterOverTime: View {
    var Diameter: CGFloat
    var body: some View{
        Text("Diameter: \(Diameter) mm")
            .font(.system(size: 30, weight: .medium))
            .foregroundColor(.white)
    }
}

struct LineGraph: Shape {
    var dataPoints: [CGFloat]
    func path(in rect: CGRect) -> Path {
        func point(at index: Int) -> CGPoint {
            let point = dataPoints[index]
            let x = rect.width * CGFloat(index) / CGFloat(dataPoints.count - 1)
            let y = (1 - point) * rect.height
            return CGPoint(x: x, y: y)
        }
        return Path { p in
            guard dataPoints.count > 1 else { return }
            let start = dataPoints[0]
            p.move(to: CGPoint(x: 0, y: (1 - start) * rect.height))
            
            for idx in dataPoints.indices{
                p.addLine(to: point(at: idx))
            }
        }
    }
}

struct LineGraphView: View {
    var body: some View{
        LineGraph(dataPoints: [0, 0.1, 0.2, 0.6,1])
            .stroke(Color.white)
            .frame(width: 350, height: 200)
            .border(Color.white)
    }
}

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var scale: CBPeripheral?
    
    let serviceUUID = CBUUID(string: "780A")
    let kitchenScaleCharacteristicUUID = CBUUID(string: "8AA2")
    @IBOutlet weak var weighLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager()
        centralManager.delegate = self
    }
    
    //MARK: - Central manager delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        centralManager.stopScan()
        scale = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    //MARK: - Peripheral delegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) {
            peripheral.discoverCharacteristics([kitchenScaleCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristic = service.characteristics?.first(where: { $0.uuid == kitchenScaleCharacteristicUUID}) {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            let weight: Int = data.withUnsafeBytes{ $0.pointee } >> 8 & 0xFFFFFF
            let weight = data.withUnsafeBytes { $0.load(as: Int.self) } >> 8 & 0xFFFFFF
            weighLabel.text = String(weight) + " g"
        }
    }
}
