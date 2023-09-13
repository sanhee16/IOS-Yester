//
//  SettingItem2.swift
//  WeatherApp
//
//  Created by sandy on 2023/09/13.
//

import Foundation
import PinLayout
import FlexLayout
import UIKit

class SettingItem2: UIView {
    typealias VM = SettingViewModel
    
    fileprivate lazy var rootFlexContainer: UIView = UIView()
    var title: String = ""
    var subTitle: String? = nil
    var descriptionView: UIView? = nil
    var onClick: (()->())? = nil
    var vm: VM? = nil
    
    init() {
        super.init(frame: .zero)
        
        self.setLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(vm: VM, title: String, subTitle: String? = nil, descriptionView: UIView? = nil, onClick: (()->())? = nil) {
        self.vm = vm
        self.title = title
        self.subTitle = subTitle
        self.descriptionView = descriptionView
        self.onClick = onClick
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        self.rootFlexContainer = UIView()
        self.setLayout()
        
        self.layout()
    }
    
    
    private func layout() {
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.all()
        self.layout()
    }
    
    @objc
    func onTap() {
        self.onClick?()
    }
    
    private func setLayout() {
        self.addSubview(rootFlexContainer)
        rootFlexContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTap)))
        rootFlexContainer.flex
            .width(100%)
            .direction(.column)
            .define { (flex) in
                flex.addItem()
                    .direction(.row)
                    .justifyContent(.spaceBetween)
                    .margin(8, 14)
                    .define { flex in
                        flex.addItem()
                            .justifyContent(.center)
                            .direction(.column)
                            .define { flex in
                                let titleLabel: UILabel = UILabel()
                                
                                titleLabel.font = .en18
                                titleLabel.text = title
                                
                                flex.addItem(titleLabel)
                                if let subTitle = subTitle {
                                    let subTitleLabel: UILabel = UILabel()
                                    
                                    subTitleLabel.font = .en14r
                                    subTitleLabel.text = subTitle
                                    subTitleLabel.textColor = .gray
                                    flex.addItem(subTitleLabel).marginTop(1)
                                }
                            }
                        if let descriptionView = descriptionView {
                            flex.addItem(descriptionView)
                        }
                    }
                divider(flex)
            }
    }
    
    private func divider(_ flex: Flex) {
        flex.addItem()
            .marginHorizontal(14)
            .define { flex in
                let view = UIView()
                view.backgroundColor = .black.withAlphaComponent(0.1)
                view.pin.width(100%).height(1)
                flex.addItem(view)
            }
    }
}
