//import UIKit
//import Combine
//import CombineCocoa
//import WPCommand
//import SnapKit
//
//final class AIRecommendController: BaseController {
//    private let sphereLayout = SphereCollectionViewLayout()
//    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: sphereLayout)
//    private let startButton = UIButton(type: .system)
//    private var media: [MediaModel] = []
//    private var cancellables = Set<AnyCancellable>()
//    private var displayLink: CADisplayLink?
//    private var lastTimestamp: CFTimeInterval = 0
//    private var rotationSpeed: CGFloat = 0.12
//    private var isRecommending = false
//    private var dragVelocity = CGPoint.zero
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .appBackground
//        navigationBarBackgroundColor = .appBackground
//        setNavigationTitle("AI RECOMMEND".language())
//        configureCollectionView()
//        configureStartButton()
//        bindEvents()
//        loadMedia()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        startRotating()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        stopRotating()
//    }
//
//    private func configureCollectionView() {
//        collectionView.backgroundColor = .clear
//        collectionView.clipsToBounds = false
//        collectionView.isScrollEnabled = false
//        collectionView.register(AISphereCell.self, forCellWithReuseIdentifier: AISphereCell.reuseIdentifier)
//        collectionView.dataSource = self
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSpherePan(_:)))
//        panGesture.cancelsTouchesInView = false
//        collectionView.addGestureRecognizer(panGesture)
//
//        view.addSubview(collectionView)
//        collectionView.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
//            make.leading.trailing.equalToSuperview().inset(8)
//            make.height.equalTo(collectionView.snp.width)
//        }
//    }
//
//    private func configureStartButton() {
//        startButton.setTitle("Start".language(), for: .normal)
//        startButton.setTitleColor(.white, for: .normal)
//        startButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
//        startButton.backgroundColor = .systemRed
//        startButton.layer.cornerRadius = 23
//        startButton.isHidden = true
//
//        view.addSubview(startButton)
//        startButton.snp.makeConstraints { make in
//            make.top.equalTo(collectionView.snp.bottom).offset(24)
//            make.centerX.equalToSuperview()
//            make.width.equalTo(156)
//            make.height.equalTo(46)
//        }
//    }
//
//    private func bindEvents() {
//        startButton.tapPublisher
//            .sink { [weak self] in self?.startRecommendation() }
//            .store(in: &cancellables)
//
//        collectionView.didSelectItemPublisher
//            .compactMap { [weak self] indexPath -> MediaModel? in
//                guard let self, media.indices.contains(indexPath.item) else { return nil }
//                return media[indexPath.item]
//            }
//            .sink { [weak self] selectedMedia in
//                guard let mediaType = selectedMedia.media_type, mediaType != .person else { return }
//                self?.navigationController?.pushViewController(
//                    DetailController(media_type: mediaType, id: selectedMedia.id),
//                    animated: true
//                )
//            }
//            .store(in: &cancellables)
//    }
//
//    private func loadMedia() {
//        Publishers.Zip4(
//            request(.trending(mdeiaType: .movie), type: .movie),
//            request(.trending(mdeiaType: .tv), type: .tv),
//            request(.popular(mdeiaType: .movie), type: .movie),
//            request(.popular(mdeiaType: .tv), type: .tv)
//        )
//        .map { movieTrending, tvTrending, popularMovies, popularTV in
//            let combined = movieTrending + tvTrending + popularMovies + popularTV
//            var identifiers = Set<String>()
//            return combined.shuffled().filter { item in
//                let key = "\(item.media_type?.rawValue ?? "media")-\(item.id)"
//                return identifiers.insert(key).inserted && item.imageURL != nil
//            }
//        }
//        .asRequest()
//        .sink { [weak self] state in
//            guard let self else { return }
//            switch state {
//            case .loading:
//                collectionView.showLoading()
//            case .success(let media):
//                collectionView.hideLoading()
//                self.media = media
//                sphereLayout.itemCount = media.count
//                collectionView.reloadData()
//                sphereLayout.invalidateLayout()
//            case .failure(let error):
//                collectionView.hideLoading()
//                print("AI Recommend 加载失败：", error.localizedDescription)
//            }
//        }
//        .store(in: &cancellables)
//    }
//
//    private func request(_ network: AppNetwork, type: AppNetwork.MediaType) -> AnyPublisher<[MediaModel], Error> {
//        network.request()
//            .mapTo(MediaListResponse.self)
//            .map { $0.filterIds().fillingMediaType(type).results }
//            .mapError { $0 as Error }
//            .eraseToAnyPublisher()
//    }
//
//    private func startRecommendation() {
//        guard !isRecommending, !media.isEmpty else { return }
//        isRecommending = true
//        startButton.isEnabled = false
//        rotationSpeed = 12
//        UIView.animate(withDuration: 0.15) { [weak self] in
//            self?.collectionView.alpha = 0.72
//        }
//        collectionView.layer.shouldRasterize = true
//        collectionView.layer.rasterizationScale = UIScreen.main.scale * 0.55
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
//            guard let self else { return }
//            rotationSpeed = 0.12
//            collectionView.layer.shouldRasterize = false
//            collectionView.layer.rasterizationScale = UIScreen.main.scale
//            UIView.animate(withDuration: 0.18) {
//                self.collectionView.alpha = 1
//            }
//            isRecommending = false
//            startButton.isEnabled = true
//            showRandomDetail()
//        }
//    }
//
//    private func showRandomDetail() {
//        guard let selectedMedia = media.randomElement(),
//              let mediaType = selectedMedia.media_type,
//              mediaType != .person else { return }
//        navigationController?.pushViewController(
//            DetailController(media_type: mediaType, id: selectedMedia.id),
//            animated: true
//        )
//    }
//
//    private func startRotating() {
//        guard displayLink == nil else { return }
//        lastTimestamp = 0
//        let link = CADisplayLink(target: self, selector: #selector(rotateSphere(_:)))
//        link.preferredFrameRateRange = CAFrameRateRange(minimum: 20, maximum: 30, preferred: 30)
//        link.add(to: .main, forMode: .common)
//        displayLink = link
//    }
//
//    private func stopRotating() {
//        displayLink?.invalidate()
//        displayLink = nil
//        lastTimestamp = 0
//    }
//
//    @objc private func rotateSphere(_ link: CADisplayLink) {
//        guard !media.isEmpty else { return }
//        if lastTimestamp > 0 {
//            let delta = CGFloat(link.timestamp - lastTimestamp)
//            sphereLayout.rotationY += delta * rotationSpeed + dragVelocity.x * delta
//            sphereLayout.rotationX += dragVelocity.y * delta
//            dragVelocity.x *= pow(0.05, delta)
//            dragVelocity.y *= pow(0.05, delta)
//            sphereLayout.invalidateLayout()
//        }
//        lastTimestamp = link.timestamp
//    }
//
//    @objc private func handleSpherePan(_ gesture: UIPanGestureRecognizer) {
//        let size = max(min(collectionView.bounds.width, collectionView.bounds.height), 1)
//        switch gesture.state {
//        case .began:
//            dragVelocity = .zero
//        case .changed:
//            let translation = gesture.translation(in: collectionView)
//            sphereLayout.rotationY += translation.x / size * .pi * 1.5
//            sphereLayout.rotationX -= translation.y / size * .pi * 1.5
//            sphereLayout.rotationX = min(max(sphereLayout.rotationX, -.pi), .pi)
//            gesture.setTranslation(.zero, in: collectionView)
//            sphereLayout.invalidateLayout()
//        case .ended, .cancelled:
//            let velocity = gesture.velocity(in: collectionView)
//            dragVelocity = CGPoint(
//                x: velocity.x / size * .pi * 0.45,
//                y: -velocity.y / size * .pi * 0.45
//            )
//        default:
//            break
//        }
//    }
//}
//
//extension AIRecommendController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        media.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: AISphereCell.reuseIdentifier,
//            for: indexPath
//        ) as! AISphereCell
//        cell.configure(media[indexPath.item])
//        return cell
//    }
//}
//
//private final class AISphereCell: UICollectionViewCell {
//    static let reuseIdentifier = "AISphereCell"
//    private let imageView = UIImageView()
//    private let artworkObserver = MediaArtworkObserver()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        contentView.backgroundColor = UIColor(white: 0.08, alpha: 1)
//        contentView.layer.cornerRadius = 6
//        contentView.layer.borderWidth = 0.5
//        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
//        contentView.clipsToBounds = true
//        imageView.contentMode = .scaleAspectFill
//        contentView.addSubview(imageView)
//        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
//    }
//
//    required init?(coder: NSCoder) { fatalError() }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        artworkObserver.unbind()
//        imageView.image = nil
//    }
//
//    func configure(_ media: MediaModel) {
//        artworkObserver.bind(media: media, imageView: imageView, type: .poster, size: CGSize(width: 84, height: 112))
//    }
//}
//
//private final class SphereCollectionViewLayout: UICollectionViewLayout {
//    var itemCount = 0
//    var rotationX: CGFloat = 0
//    var rotationY: CGFloat = 0
//    private let itemSize = CGSize(width: 48, height: 64)
//
//    override var collectionViewContentSize: CGSize {
//        collectionView?.bounds.size ?? .zero
//    }
//
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }
//
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        guard itemCount > 0 else { return [] }
//        return (0..<itemCount).compactMap {
//            layoutAttributesForItem(at: IndexPath(item: $0, section: 0))
//        }
//    }
//
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        guard let collectionView, itemCount > 0 else { return nil }
//        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//        let bounds = collectionView.bounds
//        let radius = min(bounds.width, bounds.height) * 0.38
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//
//        // Fibonacci sphere：数据多少都能均匀铺满球面，无固定行列上限。
//        let count = CGFloat(itemCount)
//        let index = CGFloat(indexPath.item) + 0.5
//        let baseY = 1 - 2 * index / count
//        let horizontalRadius = sqrt(max(0, 1 - baseY * baseY))
//        let longitude = index * .pi * (3 - sqrt(5))
//        let baseX = cos(longitude) * horizontalRadius
//        let baseZ = sin(longitude) * horizontalRadius
//
//        // 先绕纵轴、再绕横轴旋转，使拖拽可以沿任意方向转动球体。
//        let yawX = baseX * cos(rotationY) + baseZ * sin(rotationY)
//        let yawZ = -baseX * sin(rotationY) + baseZ * cos(rotationY)
//        let x = yawX
//        let y = baseY * cos(rotationX) - yawZ * sin(rotationX)
//        let z = baseY * sin(rotationX) + yawZ * cos(rotationX)
//
//        let perspective = 0.72 + (z + 1) * 0.14
//        attributes.size = itemSize
//        attributes.center = CGPoint(
//            x: center.x + x * radius,
//            y: center.y + y * radius
//        )
//        attributes.transform3D = CATransform3DMakeScale(perspective, perspective, 1)
//        attributes.alpha = 0.28 + (z + 1) * 0.36
//        attributes.zIndex = Int((z + 1) * 1_000)
//        return attributes
//    }
//}
