//
//  ZoomingImageView.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/10/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

/// 缩放图片视图
final class ZoomingImageView: UIView, UIScrollViewDelegate {

    // MARK: - 缩放模式
    enum DefaultZoomMode {
        case fit(defaultScale:CGFloat = 1.0,scalePoint:CGPoint = .zero,animate:Bool = false,)
        case original(defaultScale:CGFloat = 1.0,scalePoint:CGPoint = .zero,animate:Bool = false)
    }

    // MARK: - 对齐模式
    enum ContentAlignmentMode {
        case topLeft   // 左上角对齐
        case center    // 居中对齐
    }

    // MARK: - Public
    var defaultZoomMode: DefaultZoomMode = .fit()
    var contentAlignment: ContentAlignmentMode = .center

    // MARK: - Private
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)

        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)

        // 双击手势
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        updateZoomAndLayout()
    }

    // MARK: - Public
    func setImage(_ image: UIImage?) {
        imageView.image = image
        updateZoomAndLayout()
    }

    // MARK: - Private Helpers
    private func updateZoomAndLayout() {
        guard let image = imageView.image else { return }

        let scrollSize = scrollView.bounds.size
        let widthScale = scrollSize.width / image.size.width
        let heightScale = scrollSize.height / image.size.height
        let fitScale = min(widthScale, heightScale)

        switch defaultZoomMode {
        case .fit(let value,let point,let animate):
            scrollView.minimumZoomScale = fitScale
            scrollView.zoomScale = fitScale
            let imageWidth = image.size.width * scrollView.zoomScale
            let imageHeight = image.size.height * scrollView.zoomScale
            imageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)

            if value != 1{
                let newScale = min(scrollView.maximumZoomScale, scrollView.minimumZoomScale * value)
                zoom(to: point, scale: newScale, animated: animate)
            }

            
        case .original(let value,let point,let animate):
            scrollView.minimumZoomScale = value
            scrollView.zoomScale = value
            let imageWidth = image.size.width * scrollView.zoomScale
            let imageHeight = image.size.height * scrollView.zoomScale
            imageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
            
            if value != 1{
                let newScale = min(scrollView.maximumZoomScale, scrollView.minimumZoomScale * value)
                zoom(to: point, scale: newScale, animated: animate)
            }
        }

        centerImageView()
    }

    private func centerImageView() {
        let scrollBounds = scrollView.bounds
        var frame = imageView.frame

        switch contentAlignment {
        case .topLeft:
            frame.origin.x = 0
            frame.origin.y = 0

        case .center:
            let offsetX = max((scrollBounds.width - frame.width) / 2, 0)
            let offsetY = max((scrollBounds.height - frame.height) / 2, 0)
            frame.origin.x = offsetX
            frame.origin.y = offsetY
        }

        imageView.frame = frame
    }

    // MARK: - Double Tap Zoom
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            // 放大到最大缩放的一半
            let newScale = min(scrollView.maximumZoomScale, scrollView.minimumZoomScale * 2)
            let tapPoint = gesture.location(in: imageView)
            zoom(to: tapPoint, scale: newScale, animated: true)
        } else {
            // 还原
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }

    private func zoom(to point: CGPoint, scale: CGFloat, animated: Bool) {
        let size = scrollView.bounds.size
        let width = size.width / scale
        let height = size.height / scale
        let rect = CGRect(x: point.x - width/2, y: point.y - height/2, width: width, height: height)
        scrollView.zoom(to: rect, animated: animated)
    }

    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }
}

