//
//  ALKTemplateButtonsView.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 27/12/17.
//

import UIKit


/*
 It's responsible to display template buttons.
 Currently only textual buttons are present.
 It gives the callback outside
 */
open class ALKTemplateButtonsView: UIView {


    open var viewModel: ALKTemplateButtonsViewModel!

    open let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    public init(frame: CGRect, viewModel: ALKTemplateButtonsViewModel) {
        super.init(frame: frame)
        self.viewModel = viewModel
        setupViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        setupCollectionView()
    }

    private func setupCollectionView() {

        // Set datasource and delegate
        collectionView.dataSource = self
        collectionView.delegate = self

        // Register cells
        collectionView.register(ALKTemplateButtonsCell.self, forCellWithReuseIdentifier: "cell")

        // Set constaints
        addViewsForAutolayout(views: [collectionView])

        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

}

extension ALKTemplateButtonsView: UICollectionViewDelegate, UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ALKTemplateButtonsCell else {return UICollectionViewCell()}
        cell.backgroundColor = UIColor.brown
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}
