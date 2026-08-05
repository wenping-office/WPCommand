//import UIKit
//import Kingfisher
//
// 电影胶卷特效View
//final class FilmRollView: UIView {
//    
//    enum ImageSource {
//        case url(URL)
//        case image(UIImage)
//    }
//    
//    
//    private var collections: [UICollectionView] = []
//    
//    private var data: [[ImageSource]] = []
//    
//    private var displayLink: CADisplayLink?
//    
//    
//    /// 每秒移动距离
//    var speed: CGFloat = 20
//    
//    
//    /// 列间距
//    private let columnSpacing: CGFloat
//    
//    
//    // MARK: - Init
//    override init(frame: CGRect) {
//        self.columnSpacing = 8
//        super.init(frame: frame)
//        clipsToBounds = true
//    }
//    
//    
//    init(
//        frame: CGRect = .zero,
//        columnSpacing: CGFloat = 8
//    ) {
//        self.columnSpacing = columnSpacing
//        super.init(frame: frame)
//        clipsToBounds = true
//    }
//    
//    
//    required init?(coder: NSCoder) {
//        self.columnSpacing = 8
//        super.init(coder: coder)
//        clipsToBounds = true
//    }
//    
//    
//    
//    // MARK: - Public
//    
//    
//    func setImages(
//        _ images: [[ImageSource]]
//    ) {
//        
//        stop()
//        
//        data = images
//        
//        
//        collections.forEach {
//            $0.removeFromSuperview()
//        }
//        
//        collections.removeAll()
//        
//        
//        for _ in images {
//            
//            let layout = UICollectionViewFlowLayout()
//            
//            layout.scrollDirection = .vertical
//            layout.minimumLineSpacing = 8
//            
//            
//            let collection = UICollectionView(
//                frame: .zero,
//                collectionViewLayout: layout
//            )
//            
//            
//            collection.backgroundColor = .clear
//            
//            collection.showsVerticalScrollIndicator = false
//            
//            collection.isScrollEnabled = false
//            
//            
//            collection.register(
//                FilmRollCell.self,
//                forCellWithReuseIdentifier: "FilmRollCell"
//            )
//            
//            
//            collection.dataSource = self
//            collection.delegate = self
//            
//            
//            addSubview(collection)
//            
//            collections.append(collection)
//        }
//        
//        
//        setNeedsLayout()
//        layoutIfNeeded()
//        
//        
//        collections.forEach {
//            $0.reloadData()
//        }
//        
//        
//        start()
//    }
//    
//    
//    
//    // MARK: - Layout
//    
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        
//        guard !collections.isEmpty else {
//            return
//        }
//        
//        
//        let count = CGFloat(collections.count)
//        
//        
//        let totalSpacing =
//        columnSpacing * (count - 1)
//        
//        
//        let width =
//        (bounds.width - totalSpacing) / count
//        
//        
//        for (index, collection) in collections.enumerated() {
//            
//            let x =
//            CGFloat(index) *
//            (width + columnSpacing)
//            
//            
//            collection.frame = CGRect(
//                x: x,
//                y: 0,
//                width: width,
//                height: bounds.height
//            )
//        }
//    }
//    
//    
//    
//    // MARK: - Scroll
//    
//    
//    private func start() {
//        
//        displayLink?.invalidate()
//        
//        
//        displayLink = CADisplayLink(
//            target: self,
//            selector: #selector(updateScroll)
//        )
//        
//        
//        displayLink?.add(
//            to: .main,
//            forMode: .common
//        )
//    }
//    
//    
//    
//    @objc
//    private func updateScroll() {
//        
//        
//        let move = speed / 60
//        
//        
//        for (index, collection) in collections.enumerated() {
//            
//            
//            // 偶数列向下 奇数列向上
//            let direction: CGFloat =
//            index % 2 == 0 ? 1 : -1
//            
//            
//            var offset =
//            collection.contentOffset.y
//            
//            
//            offset += move * direction
//            
//            
//            let maxOffset =
//            collection.contentSize.height -
//            collection.bounds.height
//            
//            
//            guard maxOffset > 0 else {
//                continue
//            }
//            
//            
//            if offset >= maxOffset {
//                offset = 0
//            }
//            
//            
//            if offset <= 0 {
//                offset = maxOffset
//            }
//            
//            
//            collection.contentOffset.y = offset
//        }
//    }
//    
//    
//    private func stop() {
//        
//        displayLink?.invalidate()
//        
//        displayLink = nil
//    }
//    
//    
//    deinit {
//        stop()
//    }
//}
//
//
//
//// MARK: - UICollectionViewDataSource
//
//
//extension FilmRollView: UICollectionViewDataSource {
//    
//    
//    func collectionView(
//        _ collectionView: UICollectionView,
//        numberOfItemsInSection section: Int
//    ) -> Int {
//        
//        guard let index =
//                collections.firstIndex(of: collectionView)
//        else {
//            return 0
//        }
//        
//        
//        return data[index].count * 100
//    }
//    
//    
//    
//    func collectionView(
//        _ collectionView: UICollectionView,
//        cellForItemAt indexPath: IndexPath
//    ) -> UICollectionViewCell {
//        
//        
//        let cell =
//        collectionView.dequeueReusableCell(
//            withReuseIdentifier: "FilmRollCell",
//            for: indexPath
//        ) as! FilmRollCell
//        
//        
//        guard let column =
//                collections.firstIndex(of: collectionView)
//        else {
//            return cell
//        }
//        
//        
//        let images = data[column]
//        
//        
//        let item =
//        images[indexPath.item % images.count]
//        
//        
//        cell.setImage(item)
//        
//        
//        return cell
//    }
//}
//
//
//
//// MARK: - Layout
//
//
//extension FilmRollView:
//UICollectionViewDelegateFlowLayout {
//    
//    
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath
//    ) -> CGSize {
//        
//        let width =
//        collectionView.bounds.width
//        
//        
//        return CGSize(
//            width: width,
//            height: width * 1.5
//        )
//    }
//}
//
//
//
//// MARK: - Cell
//
//
//final class FilmRollCell: UICollectionViewCell {
//    
//    
//    private let imageView = UIImageView()
//    
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        
//        imageView.contentMode = .scaleAspectFill
//        
//        imageView.clipsToBounds = true
//        
//        contentView.addSubview(imageView)
//    }
//    
//    
//    required init?(coder: NSCoder) {
//        fatalError()
//    }
//    
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        imageView.frame = bounds
//    }
//    
//    
//    func setImage(
//        _ source: FilmRollView.ImageSource
//    ) {
//        
//        switch source {
//            
//        case .url(let url):
//            
//            imageView.kf.setImage(
//                with: url
//            )
//            
//            
//        case .image(let image):
//            
//            imageView.image = image
//        }
//    }
//}
