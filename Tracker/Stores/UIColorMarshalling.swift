import UIKit

import UIKit

final class UIColorMarshalling{
    func serialize(_ value: UIColor) -> String {
        var result = ""
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        value.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255) << 16 | (Int)(g*255) << 8 | (Int)(b*255) << 0
        result = String(format: "#%06x", rgb).uppercased()
        return result
    }
    func deserialize(_ value: String) -> UIColor {
        var hexSanitized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return UIColor() }
        
        let r, g, b, a: CGFloat
        r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        b = CGFloat(rgb & 0x0000FF) / 255.0
        a = 1.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

