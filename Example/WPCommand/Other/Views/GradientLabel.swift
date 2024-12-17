//
//  GradientLabel.swift
//  WPCommand_Example
//
//  Created by 1234 on 2024/12/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

/// 渐变Label 以\n分割
public class GradientLabel:WPBaseView{
    private let sizeLabel = UILabel()
    private let labelView = GradientLabelView()
    
    var numberOfLines:Int = 1{
        didSet{
            sizeLabel.numberOfLines = numberOfLines
        }
    }

    var text: String {
        get{
            return labelView.text
        }
        set{
            labelView.text = newValue
            sizeLabel.text = newValue
        }
    }
    var font: UIFont {
        get{
            return labelView.font
        }
        set{
            labelView.font = newValue
            sizeLabel.font = newValue
        }
    }
    var colors: [[UIColor]]{
        get{
            return labelView.gradientColors.map { elmt in
                return elmt.map { elmt in
                    return UIColor(cgColor: elmt)
                }
            }
        }
        set{
            labelView.gradientColors = newValue.map { elmt in
                return elmt.map({ elmt in
                    return elmt.cgColor
                })
            }
        }
    }

    public override func initSubView() {
        super.initSubView()
        addSubview(sizeLabel)
        addSubview(labelView)
        sizeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        labelView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
                                

public class GradientLabelView: WPBaseView {
    private let textLayer = CATextLayer()
    
    var text: String = "" {
        didSet {
            updateText()
        }
    }
    var font: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            textLayer.font = font as CFTypeRef
            textLayer.fontSize = font.pointSize
            updateText()
        }
    }
    var gradientColors: [[CGColor]] = [[]] { // Array of color arrays, one for each line
        didSet {
            updateText()
        }
    }

    public override func initSubView() {
        super.initSubView()
        layer.addSublayer(textLayer)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        updateText()
    }

    private func updateText() {
        layer.sublayers?.filter { $0 != textLayer }.forEach { $0.removeFromSuperlayer() } //Clean up old layers

        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
        var yPosition: CGFloat = 0

        for (index, line) in lines.enumerated() {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(x: 0, y: yPosition, width: wp_width, height: 0) // Height will be set later

            let attributedString = NSAttributedString(string: line, attributes: [
                .font: font,
            ])

            let size = attributedString.boundingRect(with: CGSize(width: wp_width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil).size
            gradientLayer.frame.size.height = size.height
            gradientLayer.colors = gradientColors[min(index, gradientColors.count - 1)] // Handle cases where there are fewer gradient sets than lines
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)


            let textLayer = CATextLayer()
            textLayer.string = attributedString
            textLayer.frame = gradientLayer.bounds
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.alignmentMode = .left // Or other alignment as needed
            gradientLayer.mask = textLayer
            layer.addSublayer(gradientLayer)
            yPosition += size.height
        }
    }
}
