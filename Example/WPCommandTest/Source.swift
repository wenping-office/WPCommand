
/*
 import UIKit
 import Combine
 import CombineCocoa

 nonisolated enum EdgeDirection: Sendable {
     case top(CGFloat)
     case leading(CGFloat)
     case bottom(CGFloat)
     case trailing(CGFloat)
     case topAndBottom(CGFloat)
     case leadingAndTrailing(CGFloat)
     case all(CGFloat)
 }

 nonisolated extension Array where Element == EdgeDirection {
     func asDirectionalEdgeInsets() -> NSDirectionalEdgeInsets {
         reduce(into: .zero) { insets, direction in
             switch direction {
             case .top(let value): insets.top = value
             case .leading(let value): insets.leading = value
             case .bottom(let value): insets.bottom = value
             case .trailing(let value): insets.trailing = value
             case .topAndBottom(let value):
                 insets.top = value
                 insets.bottom = value
             case .leadingAndTrailing(let value):
                 insets.leading = value
                 insets.trailing = value
             case .all(let value):
                 insets = .init(top: value, leading: value, bottom: value, trailing: value)
             }
         }
     }
 }

 /// Section 的横向滚动行为，对应 Compositional Layout 的正交滚动模式。
 nonisolated enum SectionScrollingBehavior: Sendable {
     /// 不启用正交滚动，内容沿 Collection View 的主方向排列。
     case none

     /// 连续自由滚动，停止位置不自动对齐 Item 或 Group。
     case continuous

     /// 连续滚动，停止后自动将最近的 Group 对齐到 Section 起始位置。
     case continuousGroupLeadingBoundary

     /// 按 Group 分页滚动，每次滑动停留在完整的 Group 页面。
     case groupPaging

     /// 按 Group 分页滚动，并将当前 Group 对齐到可视区域中心。
     case groupPagingCentered
 }

 nonisolated enum SectionLayout: Sendable {
     case hero(minimumHeight: CGFloat, aspectRatio: CGFloat)
     case carousel(itemWidth: CGFloat, itemHeight: CGFloat, scrolling: SectionScrollingBehavior)
     case verticalPairCarousel(groupWidth: CGFloat, groupHeight: CGFloat, itemSpacing: CGFloat)
     case banner(height: CGFloat)
     case fixedGrid(columns: Int, height: CGFloat, spacing: CGFloat)
 }

 nonisolated struct Section<ID: Hashable & Sendable>: Hashable, @unchecked Sendable {
     let id: ID
     let layout: SectionLayout
     let sectionEdges: [EdgeDirection]
     let interGroupSpacing: CGFloat
     let supplementaryViews: [SectionSupplementary<ID>]

     @MainActor
     init(
         id: ID,
         layout: SectionLayout,
         sectionEdges: [EdgeDirection] = [],
         interGroupSpacing: CGFloat = 0,
         supplementaryViews: [SectionSupplementary<ID>] = []
     ) {
         self.id = id
         self.layout = layout
         self.sectionEdges = sectionEdges
         self.interGroupSpacing = interGroupSpacing
         self.supplementaryViews = supplementaryViews
     }

     static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
     func hash(into hasher: inout Hasher) { hasher.combine(id) }

     @MainActor
     func layoutSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
         let insets = sectionEdges.asDirectionalEdgeInsets()
         let section: NSCollectionLayoutSection
         let fullItem = { NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))) }

         switch layout {
         case .hero(let minimumHeight, let ratio):
             let height = max(minimumHeight, environment.container.effectiveContentSize.width * ratio)
             section = .init(group: .vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)), subitems: [fullItem()]))
         case .carousel(let width, let height, let scrolling):
             section = .init(group: .horizontal(layoutSize: .init(widthDimension: .absolute(width), heightDimension: .absolute(height)), subitems: [fullItem()]))
             section.orthogonalScrollingBehavior = scrolling.collectionViewBehavior
         case .verticalPairCarousel(let width, let height, let spacing):
             let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
             item.contentInsets.bottom = spacing
             section = .init(group: .vertical(layoutSize: .init(widthDimension: .absolute(width), heightDimension: .absolute(height)), subitem: item, count: 2))
             section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
         case .banner(let height):
             section = .init(group: .vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)), subitems: [fullItem()]))
         case .fixedGrid(let columns, let height, let spacing):
             let count = max(columns, 1)
             let width = (environment.container.effectiveContentSize.width - insets.leading - insets.trailing - CGFloat(count - 1) * spacing) / CGFloat(count)
             let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(width), heightDimension: .fractionalHeight(1)))
             let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)), subitem: item, count: count)
             group.interItemSpacing = .fixed(spacing)
             section = .init(group: group)
         }

         section.interGroupSpacing = interGroupSpacing
         section.contentInsets = insets
         section.boundarySupplementaryItems = supplementaryViews.map(\.layoutItem)
         return section
     }
 }

 nonisolated struct SectionSupplementary<ID: Hashable & Sendable>: @unchecked Sendable {
     let elementKind: String
     let viewClass: UICollectionReusableView.Type
     let layoutItem: NSCollectionLayoutBoundarySupplementaryItem
     let configure: @MainActor (UICollectionReusableView, Section<ID>) -> Void

     @MainActor
     static func header<View: UICollectionReusableView>(
         _ view: View.Type,
         height: NSCollectionLayoutDimension,
         configure: @escaping @MainActor (View, Section<ID>) -> Void
     ) -> Self {
         make(view, kind: UICollectionView.elementKindSectionHeader, height: height, alignment: .top, configure: configure)
     }

     @MainActor
     static func footer<View: UICollectionReusableView>(
         _ view: View.Type,
         height: NSCollectionLayoutDimension,
         configure: @escaping @MainActor (View, Section<ID>) -> Void
     ) -> Self {
         make(view, kind: UICollectionView.elementKindSectionFooter, height: height, alignment: .bottom, configure: configure)
     }

     @MainActor
     private static func make<View: UICollectionReusableView>(
         _ view: View.Type,
         kind: String,
         height: NSCollectionLayoutDimension,
         alignment: NSRectAlignment,
         configure: @escaping @MainActor (View, Section<ID>) -> Void
     ) -> Self {
         let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: height), elementKind: kind, alignment: alignment)
         return .init(elementKind: kind, viewClass: view, layoutItem: item) { reusableView, section in
             guard let typedView = reusableView as? View else { return }
             configure(typedView, section)
         }
     }
 }

 private nonisolated extension SectionScrollingBehavior {
     @MainActor
     var collectionViewBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior {
         switch self {
         case .none: return .none
         case .continuous: return .continuous
         case .continuousGroupLeadingBoundary: return .continuousGroupLeadingBoundary
         case .groupPaging: return .groupPaging
         case .groupPagingCentered: return .groupPagingCentered
         }
     }
 }

 /// Diffable Item：只保存业务数据与稳定标识，不依赖 UIKit Cell。
 nonisolated struct Item: Hashable, Sendable {
     nonisolated enum Content: Hashable, Sendable {
         case hero(MediaModel)
         case trending(MediaModel)
         case actor(Actor)
         case category(Category)
         case whatsPopular(MediaModel)
         case popularMovie(MediaModel)
         case popularTV(MediaModel)
         case editorsPick(MediaModel)
     }

     nonisolated enum Identifier: Hashable, Sendable {
         case hero(Int)
         case trending(Int)
         case actor(UUID)
         case category(Category)
         case whatsPopular(Int)
         case popularMovie(Int)
         case popularTV(Int)
         case editorsPick(Int)
     }

     let content: Content

     init(_ content: Content) {
         self.content = content
     }

     var id: Identifier {
         switch content {
         case .hero(let movie): return .hero(movie.id)
         case .trending(let movie): return .trending(movie.id)
         case .actor(let actor): return .actor(actor.id)
         case .category(let category): return .category(category)
         case .whatsPopular(let movie): return .whatsPopular(movie.id)
         case .popularMovie(let movie): return .popularMovie(movie.id)
         case .popularTV(let movie): return .popularTV(movie.id)
         case .editorsPick(let movie): return .editorsPick(movie.id)
         }
     }

     static func == (lhs: Item, rhs: Item) -> Bool { lhs.id == rhs.id }
     func hash(into hasher: inout Hasher) { hasher.combine(id) }

 }

 nonisolated enum Category: String, CaseIterable, Hashable, Sendable {
     case popular = "POPULAR"
     case movies = "MOVIES"
     case tvShows = "TV SHOWS"
     case nowPlaying = "NOW PLAYING"
     case topRated = "TOP RATED"

     var iconName: String {
         switch self {
         case .popular: return "person.2"
         case .movies: return "film"
         case .tvShows: return "tv"
         case .nowPlaying: return "play.rectangle"
         case .topRated: return "hand.thumbsup"
         }
     }
 }

 @MainActor
 extension UICollectionView {
     static func source<SectionID: Hashable & Sendable>(
         _ collectionView: UICollectionView,
         sections: [Section<SectionID>],
         cellProvider: @escaping UICollectionViewDiffableDataSource<Section<SectionID>, Item>.CellProvider
     ) -> UICollectionViewDiffableDataSource<Section<SectionID>, Item> {
         collectionView.registerSupplementaryViews(for: sections)
         let source = UICollectionViewDiffableDataSource<Section<SectionID>, Item>(
             collectionView: collectionView,
             cellProvider: cellProvider
         )
         source.supplementaryViewProvider = { [weak source] collectionView, kind, indexPath in
             guard let section = source?.sectionIdentifier(for: indexPath.section),
                   let supplementary = section.supplementaryViews.first(where: { $0.elementKind == kind }) else { return nil }
             let identifier = String(describing: supplementary.viewClass)
             let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
             supplementary.configure(view, section)
             return view
         }
         return source
     }

     private func registerSupplementaryViews<SectionID>(for sections: [Section<SectionID>]) where SectionID: Hashable & Sendable {
         for section in sections {
             for supplementary in section.supplementaryViews {
                 register(supplementary.viewClass, forSupplementaryViewOfKind: supplementary.elementKind, withReuseIdentifier: String(describing: supplementary.viewClass))
             }
         }
     }

     func didSelectItemFilter<SectionID, ItemIdentifier>(
         _ source: UICollectionViewDiffableDataSource<Section<SectionID>, ItemIdentifier>,
         where isIncluded: @escaping (ItemIdentifier) -> Bool = { _ in true }
     ) -> AnyPublisher<(section: Section<SectionID>, item: ItemIdentifier, indexPath: IndexPath), Never>
     where SectionID: Hashable & Sendable, ItemIdentifier: Hashable & Sendable {

         return didSelectItemPublisher
             .compactMap { indexPath in
                 guard let section = source.sectionIdentifier(for: indexPath.section),
                       let item = source.itemIdentifier(for: indexPath),
                       isIncluded(item) else {
                     return nil
                 }

                 return (section: section, item: item, indexPath: indexPath)
             }
             .eraseToAnyPublisher()
     }
 }

 */
