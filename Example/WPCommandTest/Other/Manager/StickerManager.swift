//
//  StickerManager.swift
//  WPCommand_Example
//
//  Created by tmb on 2026/9/4.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import Vision
import CoreImage

/// 抠图
@available(iOS 17.0, *)
final class StickerManager {

    enum StickerResult {
        /// Vision 抠出的前景成品，以及颜色与描边一致的实心轮廓图。
        case image(image: UIImage, outlineImage: UIImage)

        /// OCR 生成的实体文字图片、原始文字区域及其识别结果。
        case text(image: UIImage, originalImage: UIImage, text: String)
    }

    static let shared = StickerManager()

    private let context = CIContext()

    private init() {}

    // MARK: - Public

    /// 检测图片中的所有前景实例 + 所有文字
    ///
    /// 前景：
    ///     Vision 抠出主体
    ///     + 白色 10px 描边
    ///
    /// 文字：
    ///     OCR 识别
    ///     + 生成透明背景的白色实体文字
    func createStickers(
        from url: URL,
        completion: @escaping (Result<[StickerResult], Error>) -> Void
    ) {

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in

            if let error {
                completion(.failure(error))
                return
            }

            guard
                let data,
                let image = UIImage(data: data),
                let cgImage = image.cgImage
            else {
                completion(
                    .failure(
                        StickerError.invalidImage
                    )
                )
                return
            }

            self?.createStickers(
                image: image,
                cgImage: cgImage,
                completion: completion
            )

        }.resume()
    }

    // MARK: - Vision

    private func createStickers(
        image: UIImage,
        cgImage: CGImage,
        completion: @escaping (Result<[StickerResult], Error>) -> Void
    ) {

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in

            guard let self else {
                return
            }

            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                options: [:]
            )

            // =====================================================
            // 前景实例
            // =====================================================

            let foregroundRequest =
                VNGenerateForegroundInstanceMaskRequest()

            // =====================================================
            // OCR
            // =====================================================

            let textRequest =
                VNRecognizeTextRequest()

            textRequest.recognitionLevel = .accurate
            textRequest.usesLanguageCorrection = true
            textRequest.automaticallyDetectsLanguage = true

            do {

                try handler.perform([
                    foregroundRequest,
                    textRequest
                ])

                var stickers: [StickerResult] = []

                // =================================================
                // 1. 前景实例
                // =================================================

                if let observation =
                    foregroundRequest.results?.first {

                    let instances =
                        observation.allInstances

                    print(
                        "Vision 检测到实例数量:",
                        instances.count
                    )

                    print(
                        "Vision 实例:",
                        instances
                    )

                    for instance in instances {

                        let instanceSet =
                            IndexSet(
                                integer: instance
                            )

                        do {

                            let pixelBuffer =
                                try observation.generateMaskedImage(
                                    ofInstances: instanceSet,
                                    from: handler,
                                    croppedToInstancesExtent: true
                                )

                            // 主体 + 白色 10px 描边
                            if let sticker =
                                self.makeSticker(
                                    pixelBuffer: pixelBuffer,
                                    scale: image.scale,
                                    orientation: image.imageOrientation
                                ) {
                                stickers.append(
                                    .image(
                                        image: sticker.image,
                                        outlineImage: sticker.outlineImage
                                    )
                                )
                            }

                        } catch {

                            print(
                                "实例 \(instance) 抠图失败:",
                                error
                            )
                        }
                    }
                }

                // =================================================
                // 2. 文字
                // =================================================

                if let textResults =
                    textRequest.results {

                    for textObservation in textResults {

                        guard
                            let candidate =
                                textObservation
                                .topCandidates(1)
                                .first
                        else {
                            continue
                        }

                        let text =
                            candidate.string

                        guard !text.isEmpty else {
                            continue
                        }

                        print(
                            "检测到文字:",
                            text
                        )

                        let boundingBox =
                            textObservation.boundingBox

                        if let sticker =
                            self.makeTextSticker(
                                text: text,
                                boundingBox: boundingBox,
                                imageSize: image.size,
                                scale: image.scale
                            ),
                           let originalTextImage = self.cropTextImage(
                                from: cgImage,
                                boundingBox: boundingBox,
                                scale: image.scale,
                                orientation: image.imageOrientation
                           ) {

                            stickers.append(
                                .text(
                                    image: sticker,
                                    originalImage: originalTextImage,
                                    text: text
                                )
                            )
                        }
                    }
                }

                // =================================================
                // 3. 最终结果
                // =================================================

                guard !stickers.isEmpty else {

                    completion(
                        .failure(
                            StickerError.noSubject
                        )
                    )

                    return
                }

                completion(
                    .success(stickers)
                )

            } catch {

                completion(
                    .failure(error)
                )
            }
        }
    }

    // MARK: - Foreground PixelBuffer -> UIImage

    /// Vision 抠出来的主体
    /// + 真正的白色 10px 描边
    private func makeSticker(
        pixelBuffer: CVPixelBuffer,
        scale: CGFloat,
        orientation: UIImage.Orientation
    ) -> (image: UIImage, outlineImage: UIImage)? {

        let ciImage =
            CIImage(
                cvPixelBuffer: pixelBuffer
            )

        guard let cgImage =
            context.createCGImage(
                ciImage,
                from: ciImage.extent
            )
        else {
            return nil
        }

        let image = UIImage(
            cgImage: cgImage,
            scale: scale,
            orientation: orientation
        )

        return addWhiteOutline(
            to: image,
            pixelWidth: 10
        )
    }

    // MARK: - White Outline

    /// 给透明主体增加白色轮廓
    ///
    /// pixelWidth = 实际物理像素
    ///
    /// 输出画布会自动扩大，
    /// 因此描边不会被裁剪。
    private func addWhiteOutline(
        to image: UIImage,
        pixelWidth: Int
    ) -> (image: UIImage, outlineImage: UIImage)? {

        guard
            let cgImage = image.cgImage
        else {
            return nil
        }

        let width =
            cgImage.width

        let height =
            cgImage.height

        guard
            width > 0,
            height > 0,
            pixelWidth > 0
        else {
            return nil
        }

        // =========================================================
        // 1. 转成 CIImage
        // =========================================================

        let source =
            CIImage(cgImage: cgImage)

        let outlinePadding = CGFloat(pixelWidth)
        let outputExtent = source.extent.insetBy(
            dx: -outlinePadding,
            dy: -outlinePadding
        )

        // =========================================================
        // 2. 只保留主体自身的 Alpha
        // =========================================================

        let zeroVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        let alpha = source.applyingFilter(
            "CIColorMatrix",
            parameters: [
                "inputRVector": zeroVector,
                "inputGVector": zeroVector,
                "inputBVector": zeroVector,
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1),
                "inputBiasVector": CIVector(x: 1, y: 1, z: 1, w: 0)
            ]
        )

        let transparent = CIImage(
            color: CIColor(red: 0, green: 0, blue: 0, alpha: 0)
        ).cropped(to: outputExtent)

        let expandedAlpha = alpha.composited(over: transparent)

        // =========================================================
        // 3. Alpha 向外扩张
        // =========================================================
        //
        // CIMorphologyMaximum 的 radius
        // 使用 CIImage 的像素坐标。
        //
        // 因为这里 source 是 CGImage，
        // 所以直接使用 pixelWidth。
        //

        let dilated =
            expandedAlpha.applyingFilter(
                "CIMorphologyMaximum",
                parameters: [
                    kCIInputRadiusKey:
                        CGFloat(pixelWidth)
                ]
            )
            .cropped(to: outputExtent)

        // =========================================================
        // 4. 白色图层
        // =========================================================

        let white =
            CIImage(
                color: CIColor(
                    red: 1,
                    green: 1,
                    blue: 1,
                    alpha: 1
                )
            )
            .cropped(
                to: outputExtent
            )

        // =========================================================
        // 5. 使用 Alpha Mask 得到白色轮廓层
        // =========================================================

        let outline =
            white.applyingFilter(
                "CIBlendWithMask",
                parameters: [
                    kCIInputBackgroundImageKey:
                        transparent,
                    kCIInputMaskImageKey:
                        dilated
                ]
            )

        // 从扩张后的白色区域中挖掉主体本身，只留下外轮廓。
        let outlineOnly = transparent.applyingFilter(
            "CIBlendWithMask",
            parameters: [
                kCIInputBackgroundImageKey: outline,
                kCIInputMaskImageKey: expandedAlpha
            ]
        )
        .cropped(to: outputExtent)

        // =========================================================
        // 6. 原始主体覆盖到白色描边上
        // =========================================================

        let result =
            source.composited(
                over: outlineOnly
            )

        // =========================================================
        // 7. 输出
        // =========================================================

        guard
            let finalCGImage =
            context.createCGImage(
                result,
                from: outputExtent
            ),
            let outlineCGImage = context.createCGImage(
                outline,
                from: outputExtent
            )
        else {
            return nil
        }

        return (
            image: UIImage(
                cgImage: finalCGImage,
                scale: image.scale,
                orientation: image.imageOrientation
            ),
            outlineImage: UIImage(
                cgImage: outlineCGImage,
                scale: image.scale,
                orientation: image.imageOrientation
            )
        )
    }

    /// 从原始图片中裁出 Vision 识别到的文字区域。
    private func cropTextImage(
        from cgImage: CGImage,
        boundingBox: CGRect,
        scale: CGFloat,
        orientation: UIImage.Orientation
    ) -> UIImage? {

        let imageBounds = CGRect(
            x: 0,
            y: 0,
            width: cgImage.width,
            height: cgImage.height
        )

        // Vision 使用左下角为原点，CGImage 裁剪使用左上角为原点。
        let cropRect = CGRect(
            x: boundingBox.minX * imageBounds.width,
            y: (1 - boundingBox.maxY) * imageBounds.height,
            width: boundingBox.width * imageBounds.width,
            height: boundingBox.height * imageBounds.height
        )
        .integral
        .intersection(imageBounds)

        guard
            cropRect.width > 0,
            cropRect.height > 0,
            let croppedImage = cgImage.cropping(to: cropRect)
        else {
            return nil
        }

        return UIImage(
            cgImage: croppedImage,
            scale: scale,
            orientation: orientation
        )
    }

    // MARK: - Text Sticker

    /// OCR 文字生成透明 Sticker
    ///
    /// 使用白色实体文字
    private func makeTextSticker(
        text: String,
        boundingBox: CGRect,
        imageSize: CGSize,
        scale: CGFloat
    ) -> UIImage? {

        guard !text.isEmpty else {
            return nil
        }

        // =========================================================
        // 1. 根据 Vision boundingBox 获取文字高度
        // =========================================================

        let textHeight =
            boundingBox.height *
            imageSize.height

        guard textHeight > 0 else {
            return nil
        }

        // =========================================================
        // 2. 根据文字高度估算字体大小
        // =========================================================

        let fontSize =
            max(
                8,
                textHeight * 0.8
            )

        let font =
            UIFont.boldSystemFont(
                ofSize: fontSize
            )

        // =========================================================
        // 3. 文字属性
        // =========================================================

        let attributes:
            [NSAttributedString.Key: Any] = [
                .foregroundColor:
                    UIColor.white,
                .font:
                    font
            ]

        let attributedString =
            NSAttributedString(
                string: text,
                attributes: attributes
            )

        // =========================================================
        // 4. 计算文字尺寸
        // =========================================================

        let textRect =
            attributedString.boundingRect(
                with: CGSize(
                    width:
                        CGFloat.greatestFiniteMagnitude,
                    height:
                        CGFloat.greatestFiniteMagnitude
                ),
                options: [
                    .usesLineFragmentOrigin,
                    .usesFontLeading
                ],
                context: nil
            )

        guard
            textRect.width > 0,
            textRect.height > 0
        else {
            return nil
        }

        // =========================================================
        // 5. 给文字边缘留出抗锯齿空间
        // =========================================================

        let padding = max(2 / scale, 1)

        let size =
            CGSize(
                width: ceil(
                    textRect.width +
                    padding * 2
                ),
                height: ceil(
                    textRect.height +
                    padding * 2
                )
            )

        guard
            size.width > 0,
            size.height > 0
        else {
            return nil
        }

        // =========================================================
        // 6. 创建透明图片
        // =========================================================

        let format =
            UIGraphicsImageRendererFormat()

        format.scale =
            scale

        format.opaque =
            false

        let renderer =
            UIGraphicsImageRenderer(
                size: size,
                format: format
            )

        // =========================================================
        // 7. 绘制实体文字
        // =========================================================

        return renderer.image { _ in

            let drawRect =
                CGRect(
                    x: padding,
                    y: padding,
                    width: textRect.width,
                    height: textRect.height
                )

            attributedString.draw(
                with: drawRect,
                options: [
                    .usesLineFragmentOrigin,
                    .usesFontLeading
                ],
                context: nil
            )
        }
    }
}

// MARK: - Error

enum StickerError: Error {

    case invalidImage

    case noSubject

    case createFailed
}

