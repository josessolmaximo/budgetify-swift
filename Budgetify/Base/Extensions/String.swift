//
//  String.swift
//  Budgetify
//
//  Created by Joses Solmaximo on 25/11/22.
//

import SwiftUI

extension String {
    var removeYearFromString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE, d MMMM yyyy"

        guard let date = formatter.date(from: self) else {
            return ""
        }

        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let weekday = calendar.component(.weekday, from: date)

        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Calendar.current.date(from: DateComponents(month: month, day: day, weekday: weekday))!)
    }
    
    var stringAsDate: Date {
        let df = DateFormatter()
        df.dateFormat = "EEEE, dd MMM yyyy"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df.date(from: self) ?? Date()
    }
    
    var currencySymbol: String {
        let code = CurrencySymbol.shared.findSymbol(currencyCode: self)
        
        if code.isEmpty || code == self {
            return self
        }
        
        return code
    }
    
    func withCurrency(currency: String, color: Color) -> AttributedString {
        let amount = AttributedString(self)
        var currency = AttributedString(currency)
        currency.foregroundColor = color
        return currency + " " + amount
    }
}

extension String {
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

extension String {
    func stringToColor() -> Color {
        if self.split(separator: "#").count == 4 {
            return Color(red: (Double(self.split(separator: "#")[0]) ?? 0) / 1,
                  green: (Double(self.split(separator: "#")[1]) ?? 0) / 1,
                  blue: (Double(self.split(separator: "#")[2]) ?? 0) / 1,
                  opacity: Double(self.split(separator: "#")[3]) ?? 0)
//            return Color(.sRGB)
        } else {
            return Color(self)
        }
    }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}

extension String {
    private func compare(toVersion targetVersion: String) -> ComparisonResult {
        
        let versionDelimiter = "."
        var result: ComparisonResult = .orderedSame
        var versionComponents = components(separatedBy: versionDelimiter)
        var targetComponents = targetVersion.components(separatedBy: versionDelimiter)
        let spareCount = versionComponents.count - targetComponents.count
        
        if spareCount == 0 {
            result = compare(targetVersion, options: .numeric)
        } else {
            let spareZeros = repeatElement("0", count: abs(spareCount))
            if spareCount > 0 {
                targetComponents.append(contentsOf: spareZeros)
            } else {
                versionComponents.append(contentsOf: spareZeros)
            }
            result = versionComponents.joined(separator: versionDelimiter)
                .compare(targetComponents.joined(separator: versionDelimiter), options: .numeric)
        }
        return result
    }
    
    public func isVersion(equalTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedSame }
    public func isVersion(greaterThan targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedDescending }
    public func isVersion(greaterThanOrEqualTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) != .orderedAscending }
    public func isVersion(lessThan targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedAscending }
    public func isVersion(lessThanOrEqualTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) != .orderedDescending }
}

extension String {
    func image(fontSize: CGFloat = 20, bgColor: UIColor = UIColor.clear, imageSize: CGSize? = nil) -> UIImage? {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font: font]
        let imageSize = imageSize ?? self.size(withAttributes: attributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        bgColor.set()
        let rect = CGRect(origin: .zero, size: imageSize)
        UIRectFill(rect)
        self.draw(in: rect, withAttributes: [.font: font])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
