//
//  HomeViewController.swift
//  29thAssignment
//
//  Created by taehy.k on 2021/10/19.
//

import UIKit

import SnapKit
import Then
import SwiftUI

// MARK: - HomeVC에서 사용될 셀 타입

private enum CellType {
    case channel
    case category
    case feed
}

class HomeViewController: UIViewController {
    
    // MARK: - UI properties
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: createLayout()
    )
    var tableView = UITableView()
    
    // MARK: - Properties
    fileprivate let layout: [CellType] = [.channel, .category, .feed]
    private let channels: [Channel] = Channel.loadDummyList()
    private let categoryTitles = [ "전체", "오늘", "이어서 시청하기", "시청하지 않음", "실시간", "게시물"]
    private let feeds: [Feed] = Feed.loadDummyList()

    // MARK: - Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupNavigationItems()
        setupHierarchy()
        setupLayout()
        setupCollectionView()
        registerCollectionViewCell()
    }
    
    // 네비게이션 바 세팅

    private func setupNavigationBar() {
        navigationController?.hidesBarsOnSwipe = true
    }
    
    // 네비게이션 바 아이템 세팅
    // Left Item, Right Items
    private func setupNavigationItems() {
        let shareItem = UIBarButtonItem(customView: UIImageView(image: Const.Image.windowSharingIcon))
        let notificationItem = UIBarButtonItem(customView: UIImageView(image: Const.Image.notificationIcon))
        let searchItem = UIBarButtonItem(customView: UIImageView(image: Const.Image.searchIcon))
        let profileItem = UIBarButtonItem(customView: UIImageView(image: Const.Image.wesoptProfile24))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: Const.Image.youtubePremiumLogo))
        self.navigationItem.rightBarButtonItems = [profileItem, searchItem, notificationItem, shareItem]
    }
    
    // 레이아웃 세팅
    private func setupHierarchy() {
        view.addSubviews(collectionView)
    }
    
    private func setupLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // 컬렉션뷰 세팅
    private func setupCollectionView() {
        collectionView.dataSource = self
    }
    
    private func registerCollectionViewCell() {
        collectionView.register(ChannelCollectionViewCell.self)
        collectionView.register(CategoryCollectionViewCell.self)
        collectionView.register(FeedCollectionViewCell.self)
        collectionView.register(SeparatorCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: SeparatorCollectionReusableView.reuseIdentifier)
    }
}

extension HomeViewController {
    // MARK: - Composional Layout
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { (sectionIndex, env)
            -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0: return self.createChannelSection()
            case 1: return self.createCategorySection()
            case 2: return self.createFeedSection(env)
            default: return nil
            }
        }
    }
    
    fileprivate func supplementaryFooterSeparatorItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(1)),
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom)
    }
    
    private func createChannelSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .estimated(1),
                heightDimension: .estimated(1)
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .absolute(72),
                heightDimension: .absolute(104)
            ), subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.supplementariesFollowContentInsets = false
        section.boundarySupplementaryItems = [supplementaryFooterSeparatorItem()]
        return section
    }
    
    private func createCategorySection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .estimated(1),
                heightDimension: .absolute(32)
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .estimated(1),
                heightDimension: .absolute(48)
            ), subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 9
        section.contentInsets = .init(top: 9, leading: 13, bottom: -9, trailing: 13)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    private func createFeedSection(_ env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        return NSCollectionLayoutSection.list(using: listConfig,layoutEnvironment: env)
    }
}

// MARK: - CollectionView DataSource

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        layout.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch layout[section] {
        case .channel:
            return channels.count
        case .category:
            return categoryTitles.count
        default:
            return feeds.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch layout[indexPath.section] {
        case .channel:
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as ChannelCollectionViewCell
            let channel = channels[indexPath.row]
            cell.configure(subscriptionImage: channel.channelImage,
                           title: channel.channelTitle)
            return cell
        case .category:
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as CategoryCollectionViewCell
            cell.categoryTitleLabel.text = categoryTitles[indexPath.row]
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as FeedCollectionViewCell
            let feed = feeds[indexPath.row]
            cell.configure(thumbnailImage: feed.thumbnailImage,
                           profileImage: feed.profileImage,
                           feedTitle: feed.feedTitle,
                           feedSubInformation: feed.feedSubtitle)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                           withReuseIdentifier: SeparatorCollectionReusableView.reuseIdentifier,
                                                                           for: indexPath) as? SeparatorCollectionReusableView
        else {
            return UICollectionReusableView()
        }
        return footer
    }
}
