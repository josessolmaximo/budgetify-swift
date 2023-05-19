//
//  PieChart.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 14/12/22.
//

import SwiftUI

struct PieChartSlice: View {
    var center: CGPoint
    var radius: CGFloat
    var startDegree: Double
    var endDegree: Double
    var isTouched:  Bool
    var accentColor:  Color
    var separatorColor: Color
    
    var body: some View {
        path
            .fill(isTouched ? accentColor : Color(uiColor: .systemGray5))
            .overlay(path.stroke(separatorColor, lineWidth: 2))
            .scaleEffect(isTouched ? 1.05 : 1)
            .animation(Animation.spring())
    }
    
    var path: Path {
        var path = Path()
        path.addArc(center: center, radius: radius, startAngle: Angle(degrees: startDegree), endAngle: Angle(degrees: endDegree), clockwise: false)
        path.addLine(to: center)
        path.closeSubpath()
        return path
    }
}

//struct PieChart_Previews: PreviewProvider {
//    static var previews: some View {
//        PieChart(title: "MyPieChart", data: chartDataSet, separatorColor: Color(UIColor.systemBackground), accentColors: [.black])
//    }
//}

struct ChartData {
    var category: Category
    var value: Double
}

struct PieChart: View {
    
    var title: String
    var data: [ChartData]
    var separatorColor: Color
    var accentColors: [Color]
    
    @State  private var currentValue = ""
    @State  private var currentLabel = ""
    @State  private var touchLocation: CGPoint = .init(x: -1, y: -1)
    
    var pieSlices: [PieSlice] {
        var slices = [PieSlice]()
        data.enumerated().forEach {(index, data) in
            let value = normalizedValue(index: index, data: self.data)
            if slices.isEmpty    {
                slices.append((.init(startDegree: 0, endDegree: value * 360)))
            } else {
                slices.append(.init(startDegree: slices.last!.endDegree, endDegree: (value * 360 + slices.last!.endDegree)))
            }
        }
        return slices
    }
    func angleAtTouchLocation(inPie pieSize: CGRect, touchLocation: CGPoint) ->  Double?  {
        let dx = touchLocation.x - pieSize.midX
        let dy = touchLocation.y - pieSize.midY
        
        let distanceToCenter = (dx * dx + dy * dy).squareRoot()
        let radius = pieSize.width/2
        guard distanceToCenter <= radius else {
            return nil
        }
        let angleAtTouchLocation = Double(atan2(dy, dx) * (180 / .pi))
        if angleAtTouchLocation < 0 {
            return (180 + angleAtTouchLocation) + 180
        } else {
            return angleAtTouchLocation
        }
    }
    
    func updateCurrentValue(inPie   pieSize:    CGRect)  {
        guard let angle = angleAtTouchLocation(inPie: pieSize, touchLocation: touchLocation)    else    {return}
        let currentIndex = pieSlices.firstIndex(where: { $0.startDegree < angle && $0.endDegree > angle }) ?? -1
        
//        currentLabel = data[currentIndex].label
//        currentValue = "\(data[currentIndex].value)"
    }
    
    func resetValues() {
        currentValue = ""
        currentLabel = ""
        touchLocation = .init(x: -1, y: -1)
    }
    
    func sliceIsTouched(index: Int, inPie pieSize: CGRect) -> Bool {
        guard let angle =   angleAtTouchLocation(inPie: pieSize, touchLocation: touchLocation) else { return false }
        return pieSlices.firstIndex(where: { $0.startDegree < angle && $0.endDegree > angle }) == index
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    ForEach(Array(zip(data.indices, data)), id: \.0){ index, item in
                        PieChartSlice(center: CGPoint(x: geometry.frame(in: .local).midX, y: geometry.frame(in:  .local).midY), radius: geometry.frame(in: .local).width/2, startDegree: pieSlices[index].startDegree, endDegree: pieSlices[index].endDegree, isTouched: sliceIsTouched(index: index, inPie: geometry.frame(in:  .local)), accentColor: item.category.color.stringToColor().opacity(0.5), separatorColor: separatorColor)
                    }
                }
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ position in
                        let pieSize = geometry.frame(in: .local)
                        touchLocation   =   position.location
                        updateCurrentValue(inPie: pieSize)
                    })
                        .onEnded({ _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation(Animation.easeOut) {
                                    resetValues()
                                }
                            }
                        })
                )
            }
            .aspectRatio(contentMode: .fit)
            VStack  {
                if !currentLabel.isEmpty   {
                    Text(currentLabel)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.black)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 5).foregroundColor(.white).shadow(radius: 3))
                }
                
                if !currentValue.isEmpty {
                    Text("\(currentValue)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.black)
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 5).foregroundColor(.white).shadow(radius: 3))
                }
            }
            .padding()
        }
    }
}

func normalizedValue(index: Int, data: [ChartData]) -> Double {
    var total = 0.0
    data.forEach { data in
        total += data.value
    }
    return data[index].value/total
}

struct PieSlice {
    var startDegree: Double
    var endDegree: Double
}
