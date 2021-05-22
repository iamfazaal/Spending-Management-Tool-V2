//
//  PieChartView.swift
//  SpendingManagementTool
//
//  Created by Fazal on 13/05/2021.


import UIKit

struct LabelledSegment {

  var color: UIColor

  var name: String

  var value: CGFloat
}

extension Collection where Element : Numeric {
  func sum() -> Element {
    return reduce(0, +)
  }
}

extension NumberFormatter {
  static let toOneDecimalPlace: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 1
    return formatter
  }()
}

extension CGRect {
  init(centeredOn center: CGPoint, size: CGSize) {
    self.init(
      origin: CGPoint(
        x: center.x - size.width * 0.5, y: center.y - size.height * 0.5
      ),
      size: size
    )
  }

  var center: CGPoint {
    return CGPoint(
      x: origin.x + size.width * 0.5, y: origin.y + size.height * 0.5
    )
  }
}

extension CGPoint {
  func projected(by value: CGFloat, angle: CGFloat) -> CGPoint {
    return CGPoint(
      x: x + value * cos(angle), y: y + value * sin(angle)
    )
  }
}

extension UIColor {
  struct RGBAComponents {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
  }

  var rgbaComponents: RGBAComponents {
    var components = RGBAComponents(red: 0, green: 0, blue: 0, alpha: 0)
    getRed(&components.red, green: &components.green, blue: &components.blue,
           alpha: &components.alpha)
    return components
  }

  var brightness: CGFloat {
    return rgbaComponents.brightness
  }
}

extension UIColor.RGBAComponents {
  var brightness: CGFloat {
    return (red + green + blue) / 3
  }
}

struct SegmentLabelFormatter {
  private let _getLabel: (LabelledSegment) -> String
  init(_ getLabel: @escaping (LabelledSegment) -> String) {
    self._getLabel = getLabel
  }
  func getLabel(for segment: LabelledSegment) -> String {
    return _getLabel(segment)
  }
}

extension SegmentLabelFormatter {
  static let nameWithValue = SegmentLabelFormatter { segment in
    let formattedValue = NumberFormatter.toOneDecimalPlace
      .string(from: segment.value as NSNumber) ?? "\(segment.value)"
    return "\(segment.name) (\(formattedValue))"
  }

  static let nameOnly = SegmentLabelFormatter { $0.name }
}

@IBDesignable
class PieChartView : UIView {

  var segments = [LabelledSegment]() {
    didSet { setNeedsDisplay() }
  }

  @IBInspectable
  var showSegmentLabels: Bool = true {
    didSet { setNeedsDisplay() }
  }

  @IBInspectable
  var segmentLabelFont: UIFont = UIFont.systemFont(ofSize: 14) {
    didSet {
      textAttributes[.font] = segmentLabelFont
      setNeedsDisplay()
    }
  }

    var segmentLabelFormatter = SegmentLabelFormatter.nameWithValue {
    didSet { setNeedsDisplay() }
  }

    
  @IBInspectable
  var textPositionOffset: CGFloat = 0.67 {
    didSet { setNeedsDisplay() }
  }

  private let paragraphStyle: NSParagraphStyle = {
    var p = NSMutableParagraphStyle()
    p.alignment = .center
    return p.copy() as! NSParagraphStyle
  }()

  private lazy var textAttributes: [NSAttributedString.Key: Any] = [
    .paragraphStyle: self.paragraphStyle, .font: self.segmentLabelFont
  ]

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }

  private func initialize() {
    isOpaque = false
  }

//

  private func forEachSegment(
    _ body: (LabelledSegment, _ startAngle: CGFloat,
             _ endAngle: CGFloat) -> Void
  ) {
    let valueCount = segments.lazy.map { $0.value }.sum()

   
    var startAngle: CGFloat = -.pi * 0.5

    for segment in segments {
      let endAngle = startAngle + .pi * 2 * (segment.value / valueCount)
      defer {
        startAngle = endAngle
      }
      
      body(segment, startAngle, endAngle)
    }
  }

  override func draw(_ rect: CGRect) {

    guard let ctx = UIGraphicsGetCurrentContext() else { return }

    let radius = min(frame.width, frame.height) * 0.5

    let viewCenter = bounds.center

    forEachSegment { segment, startAngle, endAngle in

      ctx.setFillColor(segment.color.cgColor)

      ctx.move(to: viewCenter)

      ctx.addArc(center: viewCenter, radius: radius, startAngle: startAngle,
                 endAngle: endAngle, clockwise: false)

        ctx.fillPath()
    }
    if showSegmentLabels { // Do text rendering.
      forEachSegment { segment, startAngle, endAngle in

        let halfAngle = startAngle + (endAngle - startAngle) * 0.5;

        var segmentCenter = viewCenter
        if segments.count > 1 {
          segmentCenter = segmentCenter
            .projected(by: radius * textPositionOffset, angle: halfAngle)
        }

        let textToRender = segmentLabelFormatter
          .getLabel(for: segment) as NSString

        textAttributes[.foregroundColor] =
          segment.color.brightness > 0.4 ? UIColor.black : UIColor.white

        let textRenderSize = textToRender.size(withAttributes: textAttributes)

        let renderRect = CGRect(
          centeredOn: segmentCenter, size: textRenderSize
        )

        textToRender.draw(in: renderRect, withAttributes: textAttributes)
      }
    }
  }
}
