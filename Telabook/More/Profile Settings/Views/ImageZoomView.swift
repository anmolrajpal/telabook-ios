//
//  ImageZoomView.swift
//  Telabook
//
//  Created by Anmol Rajpal on 09/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import UIKit
extension UIImageView {
  func enableZoom() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
    isUserInteractionEnabled = true
    addGestureRecognizer(pinchGesture)
  }

  @objc
  private func startZooming(_ sender: UIPinchGestureRecognizer) {
    let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
    guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
    sender.view?.transform = scale
    sender.scale = 1
  }
}
class ImageZoomView: UIScrollView, UIScrollViewDelegate {
    
    lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage())
        return view
    }()
    var gestureRecognizer: UITapGestureRecognizer!
    
    var image:UIImage? {
        didSet {
            guard let image = image else { return }
            imageView.image = image
            setupScrollView(image: image)
        }
    }
    
    required init(image:UIImage? = nil, frame:CGRect = UIScreen.main.bounds) {
        super.init(frame: frame)
        imageView = UIImageView(image: image)
        configureHierarchy()
        if let image = image {
            setupScrollView(image: image)
        }
        setupGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configureHierarchy() {
        imageView.frame = bounds
        addSubview(imageView)
//        imageView.fillSuperview()
    }
    
    // Sets the scroll view delegate and zoom scale limits.
    // Change the `maximumZoomScale` to allow zooming more than 2x.
    func setupScrollView(image: UIImage) {
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        setMinZoomScaleForImageSize(image.size)
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    // Sets up the gesture recognizer that receives double taps to auto-zoom
    func setupGestureRecognizer() {
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        gestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(gestureRecognizer)
    }

    // Handles a double tap by either resetting the zoom or zooming to where was tapped
    @objc
    func handleDoubleTap(_ sender:UITapGestureRecognizer) {
        if zoomScale == minimumZoomScale {
            zoom(to: zoomRectangle(scale: maximumZoomScale, center: sender.location(in: sender.view)), animated: true)
        } else {
            setZoomScale(minimumZoomScale, animated: true)
        }
        
//        if zoomScale == 1 {
//            zoom(to: zoomRectForScale(maximumZoomScale, center: gestureRecognizer.location(in: gestureRecognizer.view)), animated: true)
//        } else {
//            setZoomScale(1, animated: true)
//        }
    }
    private func zoomRectangle(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        zoomRect.origin.x = center.x - (center.x * zoomScale)
        zoomRect.origin.y = center.y - (center.y * zoomScale)
        
        return zoomRect
    }
    // Calculates the zoom rectangle for the scale
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        let newCenter = convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    // Tell the scroll view delegate which view to use for zooming and scrolling
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    
    
    
    private func centerImage() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = frame.size
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    
    private func setMinZoomScaleForImageSize(_ imageSize: CGSize) {
        let widthScale = frame.width / imageSize.width
        let heightScale = frame.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        // Scale the image down to fit in the view
        minimumZoomScale = minScale
        zoomScale = minScale
        
        // Set the image frame size after scaling down
        let imageWidth = imageSize.width * minScale
        let imageHeight = imageSize.height * minScale
        let newImageFrame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)

        imageView.frame = newImageFrame
        
        centerImage()
    }
}
