//
//  ContentView.swift
//  SeniorDesign
//
//  Created by Kevin Nelson on 12/29/20.
//

import SwiftUI

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
