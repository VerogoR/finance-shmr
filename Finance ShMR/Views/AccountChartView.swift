import SwiftUI
import Charts

struct BalancePoint: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let amount: Decimal
    var amountDouble: Double {
        (amount as NSDecimalNumber).doubleValue
    }
}

enum ChartPeriod: String, CaseIterable, Identifiable {
    case day = "Дни"
    case month = "Месяцы"
    var id: Self { self }
    var title: String { rawValue }
}

struct AccountChartView: View {
    let points: [BalancePoint]
    let period: ChartPeriod
    @State private var selected: BalancePoint?

    private var maxAbsValue: Double {
        points.map { abs($0.amountDouble) }.max() ?? 0
    }

    private var axisDates: [Date] {
        let dates = points.map(\.date)
        guard dates.count > 1 else { return dates }

        let first = dates.first!
        let last  = dates.last!

        let step = (period == .day) ? 7 : 12
        let mids = stride(from: 0, to: dates.count, by: step)
            .map { dates[$0] }
            .dropFirst()
            .dropLast()
            .map { $0 }

        return [first] + mids + [last]
    }


    var body: some View {
        Chart {
            ForEach(points) { item in
                BarMark(
                    x: .value("Date", item.date, unit: period == .day ? .day : .month),
                    y: .value("Amount", abs(item.amountDouble))
                )
                .foregroundStyle(
                        selected != nil ?
                        (item.amount < 0
                        ? (selected?.id == item.id ? Color.orange : Color.orange.opacity(0.5))
                        : (selected?.id == item.id ? Color.accentColor : Color.accentColor.opacity(0.5)))
                        : (item.amount < 0
                           ? Color.orange
                           : Color.accentColor)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                )
            }
        }
        .chartYScale(domain: 0...maxAbsValue)
        .chartXAxis {
            AxisMarks(values: axisDates) { date in
                if let d = date.as(Date.self) {
                    let isFirst = (d == axisDates.first)
                    let isLast  = (d == axisDates.last)

                    let anchor: UnitPoint = isFirst ? .topLeading : (isLast ? .topTrailing : .top)
                    let xOffset: CGFloat = isFirst ? -8 : (isLast ? 8 : 0)

                    AxisValueLabel(anchor: anchor) {
                        Text(
                            d, format: period == .day ? .dateTime.day(.twoDigits).month(.twoDigits)
                            : .dateTime.month(.abbreviated).year(.defaultDigits)
                        )
                        .offset(x: xOffset, y: 0)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisTick()
            }
        }
        .chartOverlay { proxy in
            GeometryReader { _ in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let date: Date = proxy.value(atX: value.location.x) {
                                    selected = points.min(by: {
                                        abs($0.date.timeIntervalSince(date)) <
                                        abs($1.date.timeIntervalSince(date))
                                    })
                                }
                            }
                            .onEnded { _ in selected = nil }
                    )
            }
        }
        .overlay(alignment: .topLeading) {
            if let sel = selected {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sel.date,
                         format: period == .day
                                ? .dateTime.day().month().year()
                                : .dateTime.month().year()
                    )
                    .font(.caption).foregroundStyle(.secondary)
                    Text(sel.amount,
                         format: .number.precision(.fractionLength(2)))
                    .font(.caption).bold()
                }
                .padding(6)
                .background(.ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 8))
                .offset(x: -6, y: -11)
            }
        }
        .animation(.easeInOut, value: points)
    }
}
