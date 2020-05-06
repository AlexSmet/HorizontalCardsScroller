//
//  HorizontalCollectionView.swift
//  HorizontalCollectionView
//
//  Created by Aleksandr Smetannikov on 27/04/2020.
//  Copyright © 2020 AlexSmetannikov. All rights reserved.
//

import UIKit

public class HorizontalCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    private let flowLayout = UICollectionViewFlowLayout()
    private var collectionView: UICollectionView!
    private let reuseIdentifier = "horizontalCollectionCell"

    private var indexOfCellBeforeDragging = 0

    /// Источник view для отображния в коллекции
    public var viewsSource: PHorizontalCollectionViewsSource!

    private var cellSize: CGSize {
        get { return flowLayout.itemSize }
        set { flowLayout.itemSize = newValue }
    }

    /// Расстояние между ячейками
    public var cellSpacing: CGFloat {
        get { return flowLayout.minimumLineSpacing }
        set { flowLayout.minimumLineSpacing = newValue }
    }

    /// Отступы от границ
    public var inset: UIEdgeInsets {
        get { return flowLayout.sectionInset }
        set { flowLayout.sectionInset = newValue }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initCollectionView()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initCollectionView()
    }

    private func initCollectionView() {
        flowLayout.scrollDirection = .horizontal

        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(HorizontalCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        setCellSize()
    }

    ///  Обновление данных в коллекции
    public func reloadData() {
        setCellSize()
        collectionView.reloadData()
    }

    private func setCellSize() {
        let singleCellWidth = bounds.width - (inset.left + inset.right)
        let multiCellsWidth = bounds.width * 12 / 15
        let cellWidth = viewsSource.count > 1 ? multiCellsWidth : singleCellWidth
        let cellHeght = collectionView.bounds.height - inset.top - inset.bottom
        cellSize = CGSize(width: cellWidth, height: cellHeght)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewsSource.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HorizontalCollectionCell
        let view = viewsSource.getView(index: indexPath.row)
        cell.embedView(view)

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewsSource.onSelect(index: indexPath.row)
    }
}

// MARK: - Центрирование на ячейке при скроллинге
extension HorizontalCollectionView {

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = getIndexOfMajorCell()
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        let cellIndexOffset = velocity.x == 0 ? 0 : (velocity.x > 0 ? 1: -1)
        let indexOfDestinationCell = max(0, min(viewsSource.count - 1, indexOfCellBeforeDragging + cellIndexOffset))
        let indexPath = IndexPath(row: indexOfDestinationCell, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    private func getIndexOfMajorCell() -> Int {
        let itemWidth = flowLayout.itemSize.width
        let proportionalOffset = flowLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let safeIndex = max(0, min(numberOfItems - 1, index))
        return safeIndex
    }
}
