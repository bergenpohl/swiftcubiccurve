import SwiftUI

struct CubicCurveSegment {
	let controlPoint1: CGPoint
	let controlPoint2: CGPoint
}

class CubicCurveAlgorithm {
	private var firstControlPoints: [CGPoint?] = []
	private var secondControlPoints: [CGPoint?] = []
	
	func controlPointsFromPoints(dataPoints: [CGPoint]) -> [CubicCurveSegment] {
		let count = dataPoints.count - 1
		
		if count == 1 {
			let P0 = dataPoints[0]
			let P3 = dataPoints[1]
			
			let P1x = (2*P0.x + P3.x)/3
			let P1y = (2*P0.y + P3.y)/3
			
			firstControlPoints.append(CGPoint(x: P1x, y: P1y))
			
			let P2x = (2*P1x - P0.x)
			let P2y = (2*P1y - P0.y)
			
			secondControlPoints.append(CGPoint(x: P2x, y: P2y))
		} else {
			firstControlPoints = Array(repeating: nil, count: count)

			var rhsArray = [CGPoint]()
			
			var a = [CGFloat]()
			var b = [CGFloat]()
			var c = [CGFloat]()
			
			for i in 0..<count {
				var rhsValueX: CGFloat = 0
				var rhsValueY: CGFloat = 0
				
				let P0 = dataPoints[i];
				let P3 = dataPoints[i+1];
				
				if i==0 {
					a.append(0)
					b.append(2)
					c.append(1)
					
					rhsValueX = P0.x + 2*P3.x;
					rhsValueY = P0.y + 2*P3.y;
				} else if i == count-1 {
					a.append(2)
					b.append(7)
					c.append(0)
					
					rhsValueX = 8*P0.x + P3.x;
					rhsValueY = 8*P0.y + P3.y;
				} else {
					a.append(1)
					b.append(4)
					c.append(1)
					
					rhsValueX = 4*P0.x + 2*P3.x;
					rhsValueY = 4*P0.y + 2*P3.y;
				}
				rhsArray.append(CGPoint(x: rhsValueX, y: rhsValueY))
			}
			
			for i in 1..<count {
				let rhsValueX = rhsArray[i].x
				let rhsValueY = rhsArray[i].y
				
				let prevRhsValueX = rhsArray[i-1].x
				let prevRhsValueY = rhsArray[i-1].y
				
				let m = CGFloat(a[i]/b[i-1])
				
				let b1 = b[i] - m * c[i-1];
				b[i] = b1
				
				let r2x = rhsValueX - m * prevRhsValueX
				let r2y = rhsValueY - m * prevRhsValueY
				
				rhsArray[i] = CGPoint(x: r2x, y: r2y)
			}
			
			let lastControlPointX = rhsArray[count-1].x/b[count-1]
			let lastControlPointY = rhsArray[count-1].y/b[count-1]
			
			firstControlPoints[count-1] = CGPoint(x: lastControlPointX, y: lastControlPointY)
			
			for i in (0 ..< count - 1).reversed() {
				if let nextControlPoint = firstControlPoints[i+1] {
					let controlPointX = (rhsArray[i].x - c[i] * nextControlPoint.x)/b[i]
					let controlPointY = (rhsArray[i].y - c[i] * nextControlPoint.y)/b[i]
					
					firstControlPoints[i] = CGPoint(x: controlPointX, y: controlPointY)
				}
			}
			
			for i in 0..<count {
				if i == count-1 {
					let P3 = dataPoints[i+1]
					
					guard let P1 = firstControlPoints[i] else{
						continue
					}
					
					let controlPointX = (P3.x + P1.x)/2
					let controlPointY = (P3.y + P1.y)/2
					
					secondControlPoints.append(CGPoint(x: controlPointX, y: controlPointY))
					
				} else {
					let P3 = dataPoints[i+1]
					
					guard let nextP1 = firstControlPoints[i+1] else {
						continue
					}
					
					let controlPointX = 2*P3.x - nextP1.x
					let controlPointY = 2*P3.y - nextP1.y
					
					secondControlPoints.append(CGPoint(x: controlPointX, y: controlPointY))
				}
			}
		}
		
		var controlPoints = [CubicCurveSegment]()
		
		for i in 0..<count {
			if let firstControlPoint = firstControlPoints[i],
				let secondControlPoint = secondControlPoints[i] {
				let segment = CubicCurveSegment(controlPoint1: firstControlPoint, controlPoint2: secondControlPoint)
				controlPoints.append(segment)
			}
		}
		
		return controlPoints
	}
}

