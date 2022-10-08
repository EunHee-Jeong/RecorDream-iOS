//
//  DreamWriteHeaderView.swift
//  Presentation
//
//  Created by Junho Lee on 2022/10/06.
//  Copyright © 2022 RecorDream. All rights reserved.
//

import UIKit

import RD_Core

public class DreamWriteHeader: UICollectionReusableView, UICollectionReusableViewRegisterable {
    
    // MARK: - Properties
    
    public static var isFromNib: Bool = false
    
    public lazy var title = "" {
        didSet {
            self.titleLabel.text = self.title
        }
    }
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = RDDSKitFontFamily.Pretendard.bold.font(size: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return label
    }()
    
    // MARK: - View Life Cycles
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: UI & Layout

extension DreamWriteHeader {
    private func setLayout() {
        self.addSubviews(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
    }
}
