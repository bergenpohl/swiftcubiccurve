//
//  ContentView.swift
//  CubicCurve
//
//  Created by Bergen Pohl on 2/5/22.
//

import SwiftUI

struct ContentView: View {
	@State private var values: [Double] = [0.2, 0.6, 0.4, 0.3, 0.2]
	@State private var color: Color = Color.blue
	@State private var lineWidth: CGFloat = 5.0
	
    var body: some View {
		ZStack {
			CurveFadeView(values: $values, fadeColor: $color)
			CurveView(values: $values, lineColor: $color, lineWidth: $lineWidth)
			Button(action: {
				withAnimation {
					for i in 0..<values.count {
						values[i] = CGFloat.random(in: 0..<1)
					}
				}
			}) {
				Text("Change Values")
					.padding()
					.background(Color.black.opacity(0.8))
					.cornerRadius(10)
			}
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
