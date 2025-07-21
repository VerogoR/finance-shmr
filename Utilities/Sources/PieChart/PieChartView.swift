import UIKit

public final class PieChartView: UIView {

    public var entities: [Entity] = [] {
        didSet {
            prepareSegments()
            setNeedsDisplay()
            updateLabels()
        }
    }

    private struct Segment {
        let value: CGFloat
        let color: UIColor
        let label: String
        let percentText: String
    }

    private var segments: [Segment] = []

    private let colors: [UIColor] = [
        .systemBlue, .systemGreen, .systemOrange,
        .systemRed, .systemPurple, .systemGray
    ]

    private let labelsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        addSubview(labelsStackView)

        NSLayoutConstraint.activate([
            labelsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelsStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func prepareSegments() {
        guard !entities.isEmpty else {
            segments = []
            return
        }

        let total = entities.map(\.value).reduce(0, +)
        let totalValue = NSDecimalNumber(decimal: total).doubleValue
        guard totalValue > 0 else {
            segments = []
            return
        }

        var tempSegments: [Segment] = []

        let top5 = entities.prefix(5)
        let other = entities.dropFirst(5)

        for (index, item) in top5.enumerated() {
            let itemValue = NSDecimalNumber(decimal: item.value).doubleValue
            let fraction = CGFloat(itemValue / totalValue)
            let percentInt = Int((itemValue / totalValue) * 100)

            tempSegments.append(Segment(
                value: fraction,
                color: colors[index],
                label: item.label,
                percentText: "\(percentInt)%"
            ))
        }

        if !other.isEmpty {
            let otherValueDecimal = other.map(\.value).reduce(0, +)
            let otherValue = NSDecimalNumber(decimal: otherValueDecimal).doubleValue
            let fraction = CGFloat(otherValue / totalValue)
            let percentInt = Int((otherValue / totalValue) * 100)

            tempSegments.append(Segment(
                value: fraction,
                color: colors[5],
                label: "Остальные",
                percentText: "\(percentInt)%"
            ))
        }

        segments = tempSegments
    }

    public override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), !segments.isEmpty else { return }

        let lineWidth: CGFloat = 24
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        var startAngle: CGFloat = -.pi / 2

        for segment in segments {
            let endAngle = startAngle + .pi * 2 * segment.value

            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )

            path.lineWidth = lineWidth
            segment.color.setStroke()
            path.stroke()

            startAngle = endAngle
        }
    }

    private func updateLabels() {
        labelsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for segment in segments {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 6
            row.alignment = .center

            let colorCircle = UIView()
            colorCircle.backgroundColor = segment.color
            colorCircle.layer.cornerRadius = 5
            colorCircle.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                colorCircle.widthAnchor.constraint(equalToConstant: 10),
                colorCircle.heightAnchor.constraint(equalToConstant: 10)
            ])

            let titleLabel = UILabel()
            titleLabel.text = segment.label
            titleLabel.font = UIFont.systemFont(ofSize: 12)
            titleLabel.textColor = .black

            let percentLabel = UILabel()
            percentLabel.text = segment.percentText
            percentLabel.font = UIFont.systemFont(ofSize: 12)
            percentLabel.textColor = .black

            row.addArrangedSubview(colorCircle)
            row.addArrangedSubview(titleLabel)
            row.addArrangedSubview(percentLabel)

            labelsStackView.addArrangedSubview(row)
        }
    }
    
    public func setEntities(_ newEntities: [Entity], animated: Bool = true) {
        guard animated else {
            self.entities = newEntities
            setNeedsDisplay()
            return
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(rotationAngle: .pi)
        }, completion: { _ in
            self.entities = newEntities
            self.setNeedsDisplay()

            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
                self.transform = CGAffineTransform(rotationAngle: .pi * 2)
            } completion: { _ in
                self.transform = .identity
            }
        })
    }
}
