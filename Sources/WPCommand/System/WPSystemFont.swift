//
//  WPSystemFont.swift
//  WPCommand
//
//  Created by new on 2025/5/9.
//

import UIKit
public enum SystemFontName:String,CaseIterable{
    case AcademyEngravedLetPlain
    case AlNile
    case AlNile_Bold = "AlNile-Bold"
    case AmericanTypewriter
    case AmericanTypewriter_Bold = "AmericanTypewriter-Bold"
    case AmericanTypewriter_Condensed = "AmericanTypewriter-Condensed"
    case AmericanTypewriter_CondensedBold = "AmericanTypewriter-CondensedBold"
    case AmericanTypewriter_CondensedLight = "AmericanTypewriter-CondensedLight"
    case AmericanTypewriter_Light = "AmericanTypewriter-Light"
    case AmericanTypewriter_Semibold = "AmericanTypewriter-Semibold"
    case AppleColorEmoji
    case AppleSDGothicNeo_Bold = "AppleSDGothicNeo-Bold"
    case AppleSDGothicNeo_Light = "AppleSDGothicNeo-Light"
    case AppleSDGothicNeo_Medium = "AppleSDGothicNeo-Medium"
    case AppleSDGothicNeo_Regular = "AppleSDGothicNeo-Regular"
    case AppleSDGothicNeo_SemiBold = "AppleSDGothicNeo-SemiBold"
    case AppleSDGothicNeo_Thin = "AppleSDGothicNeo-Thin"
    case AppleSDGothicNeo_UltraLight = "AppleSDGothicNeo-UltraLight"
    case AppleSymbols
    case Arial_BoldItalicMT = "Arial-BoldItalicMT"
    case Arial_BoldMT = "Arial-BoldMT"
    case Arial_ItalicMT = "Arial-ItalicMT"
    case ArialMT
    case ArialHebrew
    case ArialHebrew_Bold = "ArialHebrew-Bold"
    case ArialHebrew_Light = "ArialHebrew-Light"
    case ArialRoundedMTBold
    case Avenir_Black = "Avenir-Black"
    case Avenir_BlackOblique = "Avenir-BlackOblique"
    case Avenir_Book = "Avenir-Book"
    case Avenir_BookOblique = "Avenir-BookOblique"
    case Avenir_Heavy = "Avenir-Heavy"
    case Avenir_HeavyOblique = "Avenir-HeavyOblique"
    case Avenir_Light = "Avenir-Light"
    case Avenir_LightOblique = "Avenir-LightOblique"
    case Avenir_Medium = "Avenir-Medium"
    case Avenir_MediumOblique = "Avenir-MediumOblique"
    case Avenir_Oblique = "Avenir-Oblique"
    case Avenir_Roman = "Avenir-Roman"
    case AvenirNext_Bold = "AvenirNext-Bold"
    case AvenirNext_BoldItalic = "AvenirNext-BoldItalic"
    case AvenirNext_DemiBold = "AvenirNext-DemiBold"
    case AvenirNext_DemiBoldItalic = "AvenirNext-DemiBoldItalic"
    case AvenirNext_Heavy = "AvenirNext-Heavy"
    case AvenirNext_HeavyItalic = "AvenirNext-HeavyItalic"
    case AvenirNext_Italic = "AvenirNext-Italic"
    case AvenirNext_Medium = "AvenirNext-Medium"
    case AvenirNext_MediumItalic = "AvenirNext-MediumItalic"
    case AvenirNext_Regular = "AvenirNext-Regular"
    case AvenirNext_UltraLight = "AvenirNext-UltraLight"
    case AvenirNext_UltraLightItalic = "AvenirNext-UltraLightItalic"
    case AvenirNextCondensed_Bold = "AvenirNextCondensed-Bold"
    case AvenirNextCondensed_BoldItalic = "AvenirNextCondensed-BoldItalic"
    case AvenirNextCondensed_DemiBold = "AvenirNextCondensed-DemiBold"
    case AvenirNextCondensed_DemiBoldItalic = "AvenirNextCondensed-DemiBoldItalic"
    case AvenirNextCondensed_Heavy = "AvenirNextCondensed-Heavy"
    case AvenirNextCondensed_HeavyItalic = "AvenirNextCondensed-HeavyItalic"
    case AvenirNextCondensed_Italic = "AvenirNextCondensed-Italic"
    case AvenirNextCondensed_Medium = "AvenirNextCondensed-Medium"
    case AvenirNextCondensed_MediumItalic = "AvenirNextCondensed-MediumItalic"
    case AvenirNextCondensed_Regular = "AvenirNextCondensed-Regular"
    case AvenirNextCondensed_UltraLight = "AvenirNextCondensed-UltraLight"
    case AvenirNextCondensed_UltraLightItalic = "AvenirNextCondensed-UltraLightItalic"
    case Baskerville
    case Baskerville_Bold = "Baskerville-Bold"
    case Baskerville_BoldItalic = "Baskerville-BoldItalic"
    case Baskerville_Italic = "Baskerville-Italic"
    case Baskerville_SemiBold = "Baskerville-SemiBold"
    case Baskerville_SemiBoldItalic = "Baskerville-SemiBoldItalic"
    case BodoniSvtyTwoITCTT_Bold = "BodoniSvtyTwoITCTT-Bold"
    case BodoniSvtyTwoITCTT_Book = "BodoniSvtyTwoITCTT-Book"
    case BodoniSvtyTwoITCTT_BookIta = "BodoniSvtyTwoITCTT-BookIta"
    case BodoniSvtyTwoOSITCTT_Bold = "BodoniSvtyTwoOSITCTT-Bold"
    case BodoniSvtyTwoOSITCTT_Book = "BodoniSvtyTwoOSITCTT-Book"
    case BodoniSvtyTwoOSITCTT_BookIt = "BodoniSvtyTwoOSITCTT-BookIt"
    case BodoniSvtyTwoSCITCTT_Book = "BodoniSvtyTwoSCITCTT-Book"
    case BodoniOrnamentsITCTT
    case BradleyHandITCTT_Bold = "BradleyHandITCTT-Bold"
    case ChalkboardSE_Bold = "ChalkboardSE-Bold"
    case ChalkboardSE_Light = "ChalkboardSE-Light"
    case ChalkboardSE_Regular = "ChalkboardSE-Regular"
    case Chalkduster
    case Charter_Black = "Charter-Black"
    case Charter_BlackItalic = "Charter-BlackItalic"
    case Charter_Bold = "Charter-Bold"
    case Charter_BoldItalic = "Charter-BoldItalic"
    case Charter_Italic = "Charter-Italic"
    case Charter_Roman = "Charter-Roman"
    case Cochin
    case Cochin_Bold = "Cochin-Bold"
    case Cochin_BoldItalic = "Cochin-BoldItalic"
    case Cochin_Italic = "Cochin-Italic"
    case Copperplate
    case Copperplate_Bold = "Copperplate-Bold"
    case Copperplate_Light = "Copperplate-Light"
    case CourierNewPS_BoldItalicMT = "CourierNewPS-BoldItalicMT"
    case CourierNewPS_BoldMT = "CourierNewPS-BoldMT"
    case CourierNewPS_ItalicMT = "CourierNewPS-ItalicMT"
    case CourierNewPSMT
    case DINAlternate_Bold = "DINAlternate-Bold"
    case DINCondensed_Bold = "DINCondensed-Bold"
    case Damascus
    case DamascusBold
    case DamascusLight
    case DamascusMedium
    case DamascusSemiBold
    case DevanagariSangamMN
    case DevanagariSangamMN_Bold = "DevanagariSangamMN-Bold"
    case Didot
    case Didot_Bold = "Didot-Bold"
    case Didot_Italic = "Didot-Italic"
    case EuphemiaUCAS
    case EuphemiaUCAS_Bold = "EuphemiaUCAS-Bold"
    case EuphemiaUCAS_Italic = "EuphemiaUCAS-Italic"
    case Farah
    case Futura_Bold = "Futura-Bold"
    case Futura_CondensedExtraBold = "Futura-CondensedExtraBold"
    case Futura_CondensedMedium = "Futura-CondensedMedium"
    case Futura_Medium = "Futura-Medium"
    case Futura_MediumItalic = "Futura-MediumItalic"
    case Galvji
    case Galvji_Bold = "Galvji-Bold"
    case GeezaPro
    case GeezaPro_Bold = "GeezaPro-Bold"
    case Georgia
    case Georgia_Bold = "Georgia-Bold"
    case Georgia_BoldItalic = "Georgia-BoldItalic"
    case Georgia_Italic = "Georgia-Italic"
    case GillSans
    case GillSans_Bold = "GillSans-Bold"
    case GillSans_BoldItalic = "GillSans-BoldItalic"
    case GillSans_Italic = "GillSans-Italic"
    case GillSans_Light = "GillSans-Light"
    case GillSans_LightItalic = "GillSans-LightItalic"
    case GillSans_SemiBold = "GillSans-SemiBold"
    case GillSans_SemiBoldItalic = "GillSans-SemiBoldItalic"
    case GillSans_UltraBold = "GillSans-UltraBold"
    case GranthaSangamMN_Bold = "GranthaSangamMN-Bold"
    case GranthaSangamMN_Regular = "GranthaSangamMN-Regular"
    case Helvetica
    case Helvetica_Bold = "Helvetica-Bold"
    case Helvetica_BoldOblique = "Helvetica-BoldOblique"
    case Helvetica_Light = "Helvetica-Light"
    case Helvetica_LightOblique = "Helvetica-LightOblique"
    case Helvetica_Oblique = "Helvetica-Oblique"
    case HelveticaNeue
    case HelveticaNeue_Bold = "HelveticaNeue-Bold"
    case HelveticaNeue_BoldItalic = "HelveticaNeue-BoldItalic"
    case HelveticaNeue_CondensedBlack = "HelveticaNeue-CondensedBlack"
    case HelveticaNeue_CondensedBold = "HelveticaNeue-CondensedBold"
    case HelveticaNeue_Italic = "HelveticaNeue-Italic"
    case HelveticaNeue_Light = "HelveticaNeue-Light"
    case HelveticaNeue_LightItalic = "HelveticaNeue-LightItalic"
    case HelveticaNeue_Medium = "HelveticaNeue-Medium"
    case HelveticaNeue_MediumItalic = "HelveticaNeue-MediumItalic"
    case HelveticaNeue_Thin = "HelveticaNeue-Thin"
    case HelveticaNeue_ThinItalic = "HelveticaNeue-ThinItalic"
    case HelveticaNeue_UltraLight = "HelveticaNeue-UltraLight"
    case HelveticaNeue_UltraLightItalic = "HelveticaNeue_UltraLightItalic"
    case HiraMaruProN_W4 = "HiraMaruProN-W4"
    case HiraMinProN_W3 = "HiraMinProN-W3"
    case HiraMinProN_W6 = "HiraMinProN-W6"
    case HiraginoSans_W3 = "HiraginoSans-W3"
    case HiraginoSans_W4 = "HiraginoSans-W4"
    case HiraginoSans_W5 = "HiraginoSans-W5"
    case HiraginoSans_W6 = "HiraginoSans-W6"
    case HiraginoSans_W7 = "HiraginoSans-W7"
    case HiraginoSans_W8 = "HiraginoSans-W8"
    case HoeflerText_Black = "HoeflerText-Black"
    case HoeflerText_BlackItalic = "HoeflerText-BlackItalic"
    case HoeflerText_Italic = "HoeflerText-Italic"
    case HoeflerText_Regular = "HoeflerText-Regular"
    case Impact
    case Kailasa
    case Kailasa_Bold = "Kailasa-Bold"
    case Kefa_Regular = "Kefa-Regular"
    case KhmerSangamMN
    case KohinoorBangla_Light = "KohinoorBangla-Light"
    case KohinoorBangla_Regular = "KohinoorBangla-Regular"
    case KohinoorBangla_Semibold = "KohinoorBangla-Semibold"
    case KohinoorDevanagari_Light = "KohinoorDevanagari-Light"
    case KohinoorDevanagari_Regular = "KohinoorDevanagari-Regular"
    case KohinoorDevanagari_Semibold = "KohinoorDevanagari-Semibold"
    case KohinoorGujarati_Bold = "KohinoorGujarati-Bold"
    case KohinoorGujarati_Light = "KohinoorGujarati-Light"
    case KohinoorGujarati_Regular = "KohinoorGujarati-Regular"
    case KohinoorTelugu_Light = "KohinoorTelugu-Light"
    case KohinoorTelugu_Medium = "KohinoorTelugu-Medium"
    case KohinoorTelugu_Regular = "KohinoorTelugu-Regular"
    case LaoSangamMN
    case MalayalamSangamMN
    case MalayalamSangamMN_Bold = "MalayalamSangamMN-Bold"
    case MarkerFelt_Thin = "MarkerFelt-Thin"
    case MarkerFelt_Wide = "MarkerFelt-Wide"
    case Menlo_Bold = "Menlo-Bold"
    case Menlo_BoldItalic = "Menlo-BoldItalic"
    case Menlo_Italic = "Menlo-Italic"
    case Menlo_Regular = "Menlo-Regular"
    case DiwanMishafi
    case MuktaMahee_Bold = "MuktaMahee-Bold"
    case MuktaMahee_Light = "MuktaMahee-Light"
    case MuktaMahee_Regular = "MuktaMahee-Regular"
    case MyanmarSangamMN
    case MyanmarSangamMN_Bold = "MyanmarSangamMN-Bold"
    case Noteworthy_Bold = "Noteworthy-Bold"
    case Noteworthy_Light = "Noteworthy-Light"
    case NotoNastaliqUrdu
    case NotoNastaliqUrdu_Bold = "NotoNastaliqUrdu-Bold"
    case NotoSansKannada_Bold = "NotoSansKannada-Bold"
    case NotoSansKannada_Light = "NotoSansKannada-Light"
    case NotoSansKannada_Regular = "NotoSansKannada-Regular"
    case NotoSansMyanmar_Bold = "NotoSansMyanmar-Bold"
    case NotoSansMyanmar_Light = "NotoSansMyanmar-Light"
    case NotoSansMyanmar_Regular = "NotoSansMyanmar-Regular"
    case NotoSansOriya
    case NotoSansOriya_Bold = "NotoSansOriya-Bold"
    case NotoSansSyriac_Regular = "NotoSansSyriac-Regular"
    case NotoSansSyriac_Regular_Black = "NotoSansSyriac-Regular-Black"
    case NotoSansSyriac_Regular_Bold = "NotoSansSyriac-Regular-Bold"
    case NotoSansSyriac_Regular_ExtraBold = "NotoSansSyriac-Regular-ExtraBold"
    case NotoSansSyriac_Regular_ExtraLight = "NotoSansSyriac-Regular-ExtraLight"
    case NotoSansSyriac_Regular_Light = "NotoSansSyriac-Regular-Light"
    case NotoSansSyriac_Regular_Medium = "NotoSansSyriac-Regular-Medium"
    case NotoSansSyriac_Regular_SemiBold = "NotoSansSyriac-Regular-SemiBold"
    case NotoSansSyriac_Regular_Thin = "NotoSansSyriac-Regular-Thin"
    case Optima_Bold = "Optima-Bold"
    case Optima_BoldItalic = "Optima-BoldItalic"
    case Optima_ExtraBlack = "Optima-ExtraBlack"
    case Optima_Italic = "Optima-Italic"
    case Optima_Regular = "Optima-Regular"
    case Palatino_Bold = "Palatino-Bold"
    case Palatino_BoldItalic = "Palatino-BoldItalic"
    case Palatino_Italic = "Palatino-Italic"
    case Palatino_Roman = "Palatino-Roman"
    case Papyrus
    case Papyrus_Condensed = "Papyrus-Condensed"
    case PartyLetPlain
    case PingFangHK_Light = "PingFangHK-Light"
    case PingFangHK_Medium = "PingFangHK-Medium"
    case PingFangHK_Regular = "PingFangHK-Regular"
    case PingFangHK_Semibold = "PingFangHK-Semibold"
    case PingFangHK_Thin = "PingFangHK-Thin"
    case PingFangHK_Ultralight = "PingFangHK-Ultralight"
    case PingFangMO_Light = "PingFangMO-Light"
    case PingFangMO_Medium = "PingFangMO-Medium"
    case PingFangMO_Regular = "PingFangMO-Regular"
    case PingFangMO_Semibold = "PingFangMO-Semibold"
    case PingFangMO_Thin = "PingFangMO-Thin"
    case PingFangMO_Ultralight = "PingFangMO-Ultralight"
    case PingFangSC_Light = "PingFangSC-Light"
    case PingFangSC_Medium = "PingFangSC-Medium"
    case PingFangSC_Regular = "PingFangSC-Regular"
    case PingFangSC_Semibold = "PingFangSC-Semibold"
    case PingFangSC_Thin = "PingFangSC-Thin"
    case PingFangSC_Ultralight = "PingFangSC-Ultralight"
    case PingFangTC_Light = "PingFangTC-Light"
    case PingFangTC_Medium = "PingFangTC-Medium"
    case PingFangTC_Regular = "PingFangTC-Regular"
    case PingFangTC_Semibold = "PingFangTC-Semibold"
    case PingFangTC_Thin = "PingFangTC-Thin"
    case PingFangTC_Ultralight = "PingFangTC-Ultralight"
    case Rockwell_Bold = "Rockwell-Bold"
    case Rockwell_BoldItalic = "Rockwell-BoldItalic"
    case Rockwell_Italic = "Rockwell-Italic"
    case Rockwell_Regular = "Rockwell-Regular"
    case STIXTwoMath_Regular = "STIXTwoMath-Regular"
    case STIXTwoText
    case STIXTwoText_Italic = "STIXTwoText-Italic"
    case STIXTwoText_Italic_Bold_Italic = "STIXTwoText-Italic-Bold-Italic"
    case STIXTwoText_Italic_Medium_Italic = "STIXTwoText-Italic-Medium-Italic"
    case STIXTwoText_Italic_SemiBold_Italic = "STIXTwoText-Italic-SemiBold-Italic"
    case STIXTwoText_Bold = "STIXTwoText-Bold"
    case STIXTwoText_Medium = "STIXTwoText-Medium"
    case STIXTwoText_SemiBold = "STIXTwoText-SemiBold"
    case SavoyeLetPlain
    case SinhalaSangamMN
    case SinhalaSangamMN_Bold = "SinhalaSangamMN-Bold"
    case SnellRoundhand
    case SnellRoundhand_Black = "SnellRoundhand-Black"
    case SnellRoundhand_Bold = "SnellRoundhand-Bold"
    case Symbol
    case TamilSangamMN
    case TamilSangamMN_Bold = "TamilSangamMN-Bold"
    case Thonburi
    case Thonburi_Bold = "Thonburi-Bold"
    case Thonburi_Light = "Thonburi-Light"
    case TimesNewRomanPS_BoldItalicMT = "TimesNewRomanPS-BoldItalicMT"
    case TimesNewRomanPS_BoldMT = "TimesNewRomanPS-BoldMT"
    case TimesNewRomanPS_ItalicMT = "TimesNewRomanPS-ItalicMT"
    case TimesNewRomanPSMT
    case Trebuchet_BoldItalic = "Trebuchet-BoldItalic"
    case TrebuchetMS
    case TrebuchetMS_Bold = "TrebuchetMS-Bold"
    case TrebuchetMS_Italic = "TrebuchetMS-Italic"
    case Verdana
    case Verdana_Bold = "Verdana-Bold"
    case Verdana_BoldItalic = "Verdana-BoldItalic"
    case Verdana_Italic = "Verdana-Italic"
    case ZapfDingbatsITC
    case Zapfino
}


public protocol WPSystemFont{
    func font(_ fontName:SystemFontName) -> UIFont?
}

extension Int: WPSystemFont {
    public func font(_ fontName: SystemFontName) -> UIFont? {
        return .init(name: fontName.rawValue, size: CGFloat(self))
    }
}
extension Int8: WPSystemFont{
    public func font(_ fontName: SystemFontName) -> UIFont? {
        return .init(name: fontName.rawValue, size: CGFloat(self))
    }
}
extension Int16: WPSystemFont{
    public func font(_ fontName: SystemFontName) -> UIFont? {
        return .init(name: fontName.rawValue, size: CGFloat(self))
    }
}
extension Int32: WPSystemFont{
    public func font(_ fontName: SystemFontName) -> UIFont? {
        return .init(name: fontName.rawValue, size: CGFloat(self))
    }
}
extension Int64: WPSystemFont{
    public func font(_ fontName: SystemFontName) -> UIFont? {
        return .init(name: fontName.rawValue, size: CGFloat(self))
    }
}
extension UInt: WPSystemFont{
    public func font(_ fontName: SystemFontName) -> UIFont? {
        return .init(name: fontName.rawValue, size: CGFloat(self))
    }
}
extension UInt8: WPSystemFont{
    public func font(_ fontName: SystemFontName) -> UIFont? {
        return .init(name: fontName.rawValue, size: CGFloat(self))
    }
}
extension UInt16: WPSystemFont{
    public func font(_ fontName: SystemFontName) -> UIFont? {
        return .init(name: fontName.rawValue, size: CGFloat(self))
    }
}
extension UInt32: WPSystemFont{
    public func font(_ fontName: SystemFontName) -> UIFont? {
        return .init(name: fontName.rawValue, size: CGFloat(self))
    }
}
extension UInt64: WPSystemFont{
    public func font(_ fontName: SystemFontName) -> UIFont? {
        return .init(name: fontName.rawValue, size: CGFloat(self))
    }
}
extension CGFloat: WPSystemFont{
    public func font(_ fontName: SystemFontName) -> UIFont? {
        return .init(name: fontName.rawValue, size: CGFloat(self))
    }
}
extension Double: WPSystemFont{
    public func font(_ fontName: SystemFontName) -> UIFont? {
        return .init(name: fontName.rawValue, size: CGFloat(self))
    }
}


extension WPSpace where Base == WPSystemFont{
    func font(_ fontName:SystemFontName) -> UIFont {
        return base.font(fontName) ?? .systemFont(ofSize: 10)
    }
}
