//
//  CircularProgressView.swift
//  EOY_Project
//
//  Created by Saraya Patel on 11/10/26.
//

import UIKit

class CircularProgressView: UIView {
    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    var progress: CGFloat = 0 {
        didSet {
            progressLayer.strokeEnd = min(max(progress, 0), 1)
        }
    }

    var ringColor: UIColor = UIColor(red: 0.05, green: 0.50, blue: 0.46, alpha: 1) {
        didSet { setNeedsLayout() }
    }

    var trackColor: UIColor = UIColor(red: 0.89, green: 0.93, blue: 0.92, alpha: 1) {
        didSet { setNeedsLayout() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let centerPoint = CGPoint(
            x: bounds.midX,
            y: bounds.midY
        )

        let radius = min(bounds.width, bounds.height) / 2 - 12

        let path = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )

        backgroundLayer.path = path.cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = trackColor.cgColor
        backgroundLayer.lineWidth = 15

        progressLayer.path = path.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = ringColor.cgColor
        progressLayer.lineWidth = 15
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = min(max(progress, 0), 1)

        if backgroundLayer.superlayer == nil {
            layer.addSublayer(backgroundLayer)
        }

        if progressLayer.superlayer == nil {
            layer.addSublayer(progressLayer)
        }
    }
}
