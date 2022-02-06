//
//  CurveView.swift
//  CubicCurve
//
//  Created by Bergen Pohl on 2/5/22.
//

import SwiftUI

struct CurveView: View {
	@Binding public var values: [Double]
	@Binding public var lineColor: Color
	@Binding public var lineWidth: CGFloat
	
	var body: some View {
		GeometryReader { geometry in
			let vector = AnimatableVector(values: values)
			let points = buildPoints(values: values, width: geometry.size.width, height: geometry.size.height)
			let cps = splitPoints(points: points)
			
			Curve(vector: vector, cp1: cps.cp1, cp2: cps.cp2, cp3: cps.cp3, cp4: cps.cp4, width: geometry.size.width, height: geometry.size.height)
				.stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
		}
	}
	
	private func buildPoints(values: [Double], width: CGFloat, height: CGFloat) -> [CGPoint] {
		var points: [CGPoint] = []
		
		for index in 0..<values.count {
			let value = values[index];
			points.append(CGPoint(x: CGFloat(index) / CGFloat(values.count - 1) * width, y: value * height))
		}
		return points
	}
	
	private func splitPoints(points: [CGPoint]) -> CubicControlPoints {
		var v1: [Double] = []
		var v2: [Double] = []
		var v3: [Double] = []
		var v4: [Double] = []
		
		var cp1: AnimatableVector
		var cp2: AnimatableVector
		var cp3: AnimatableVector
		var cp4: AnimatableVector
		
		let cubicCurveAlgorithm = CubicCurveAlgorithm()
		let controlPoints = cubicCurveAlgorithm.controlPointsFromPoints(dataPoints: points)
		
		for segment in controlPoints {
			v1.append(segment.controlPoint1.x)
			v2.append(segment.controlPoint1.y)
			v3.append(segment.controlPoint2.x)
			v4.append(segment.controlPoint2.y)
		}
		
		cp1 = AnimatableVector(values: v1)
		cp2 = AnimatableVector(values: v2)
		cp3 = AnimatableVector(values: v3)
		cp4 = AnimatableVector(values: v4)
		
		return CubicControlPoints(cp1: cp1, cp2: cp2, cp3: cp3, cp4: cp4)
	}
}

struct CurveFadeView: View {
	@Binding public var values: [Double]
	@Binding public var fadeColor: Color
	public var flip: Bool = false
	
	var body: some View {
		GeometryReader { geometry in
			let vector = AnimatableVector(values: values)
			let points = buildPoints(values: values, width: geometry.size.width, height: geometry.size.height)
			let cps = splitPoints(points: points)
			let edgeValue = edgeValue(values, flip: flip)
			
			CurveFade(vector: vector, cp1: cps.cp1, cp2: cps.cp2, cp3: cps.cp3, cp4: cps.cp4, width: geometry.size.width, height: geometry.size.height, flip: flip)
				.fill(LinearGradient(colors: [fadeColor, .clear],
									 startPoint: UnitPoint(x: 0.5, y: edgeValue),
									 endPoint: UnitPoint(x: 0.5, y: flip == true ? 0.0 : 1.0)))
		}
	}
	
	private func buildPoints(values: [Double], width: CGFloat, height: CGFloat) -> [CGPoint] {
		var points: [CGPoint] = []
		
		for index in 0..<values.count {
			let value = values[index];
			points.append(CGPoint(x: CGFloat(index) / CGFloat(values.count - 1) * width, y: value * height))
		}
		return points
	}
	
	private func splitPoints(points: [CGPoint]) -> CubicControlPoints {
		var v1: [Double] = []
		var v2: [Double] = []
		var v3: [Double] = []
		var v4: [Double] = []
		
		var cp1: AnimatableVector
		var cp2: AnimatableVector
		var cp3: AnimatableVector
		var cp4: AnimatableVector
		
		let cubicCurveAlgorithm = CubicCurveAlgorithm()
		let controlPoints = cubicCurveAlgorithm.controlPointsFromPoints(dataPoints: points)
		
		for segment in controlPoints {
			v1.append(segment.controlPoint1.x)
			v2.append(segment.controlPoint1.y)
			v3.append(segment.controlPoint2.x)
			v4.append(segment.controlPoint2.y)
		}
		
		cp1 = AnimatableVector(values: v1)
		cp2 = AnimatableVector(values: v2)
		cp3 = AnimatableVector(values: v3)
		cp4 = AnimatableVector(values: v4)
		
		return CubicControlPoints(cp1: cp1, cp2: cp2, cp3: cp3, cp4: cp4)
	}
	
	private func edgeValue(_ values: [Double], flip: Bool = false) -> Double {
		var edgeValue: Double = flip == true ? 0.0 : 1.0
		if (flip == true) {
			for value in values {
				if value > edgeValue {
					edgeValue = value
				}
			}
		} else {
			for value in values {
				if value < edgeValue {
					edgeValue = value
				}
			}
		}
		return edgeValue
	}
}

struct Curve: Shape {
	var vector: AnimatableVector
	var cp1: AnimatableVector
	var cp2: AnimatableVector
	var cp3: AnimatableVector
	var cp4: AnimatableVector
	var width: CGFloat
	var height: CGFloat
	
	var animatableData: AnimatablePair<AnimatableVector, AnimatablePair<AnimatablePair<AnimatableVector, AnimatableVector>, AnimatablePair<AnimatableVector, AnimatableVector>>> {
		get { AnimatablePair(vector, AnimatablePair(AnimatablePair(cp1, cp2), AnimatablePair(cp3, cp4))) }
		set {
			vector = newValue.first
			cp1 = newValue.second.first.first
			cp2 = newValue.second.first.second
			cp3 = newValue.second.second.first
			cp4 = newValue.second.second.second
		}
	}
	
	func path(in rect: CGRect) -> Path {
		var path = Path()
		
		for index in 0..<vector.values.count {
			let value = vector.values[index];
			if (index == 0) {
				path.move(to: CGPoint(x: 0, y: value * height))
			} else {
				path.addCurve(to: CGPoint(x: CGFloat(index) / CGFloat(vector.values.count - 1) * width, y: value * height),
							  control1: CGPoint(x: cp1.values[index - 1], y: cp2.values[index - 1]),
							  control2: CGPoint(x: cp3.values[index - 1], y: cp4.values[index - 1])
				)
			}
		}
		return path
	}
}

struct CurveFade: Shape {
	var vector: AnimatableVector
	var cp1: AnimatableVector
	var cp2: AnimatableVector
	var cp3: AnimatableVector
	var cp4: AnimatableVector
	var width: CGFloat
	var height: CGFloat
	var flip: Bool = false
	
	var animatableData: AnimatablePair<AnimatableVector, AnimatablePair<AnimatablePair<AnimatableVector, AnimatableVector>, AnimatablePair<AnimatableVector, AnimatableVector>>> {
		get { AnimatablePair(vector, AnimatablePair(AnimatablePair(cp1, cp2), AnimatablePair(cp3, cp4))) }
		set {
			vector = newValue.first
			cp1 = newValue.second.first.first
			cp2 = newValue.second.first.second
			cp3 = newValue.second.second.first
			cp4 = newValue.second.second.second
		}
	}
	
	func path(in rect: CGRect) -> Path {
		var path = Path()
		
		for index in 0..<vector.values.count {
			let value = vector.values[index];
			if (index == 0) {
				path.move(to: CGPoint(x: 0, y: value * height))
			} else {
				path.addCurve(to: CGPoint(x: CGFloat(index) / CGFloat(vector.values.count - 1) * width, y: value * height),
							  control1: CGPoint(x: cp1.values[index - 1], y: cp2.values[index - 1]),
							  control2: CGPoint(x: cp3.values[index - 1], y: cp4.values[index - 1])
				)
			}
		}
		if (flip == true) {
			path.addLine(to: CGPoint(x: width, y: 0))
			path.addLine(to: CGPoint(x: 0, y: 0))
		} else {
			path.addLine(to: CGPoint(x: width, y: height))
			path.addLine(to: CGPoint(x: 0, y: height))
		}
		return path
	}
}

struct LineChart_Previews: PreviewProvider {
	static var values: Binding<[Double]> = Binding.constant([0.2, 0.6, 0.4, 0.3, 0.2])
	static let color: Binding<Color> = Binding.constant(Color.blue)
	static let width: Binding<CGFloat> = Binding.constant(5.0)
	
	static var previews: some View {
		ZStack {
			CurveFadeView(values: values, fadeColor: color)
			CurveView(values: values, lineColor: color, lineWidth: width)
		}
	}
}

struct CubicControlPoints {
	let cp1: AnimatableVector
	let cp2: AnimatableVector
	let cp3: AnimatableVector
	let cp4: AnimatableVector
}
