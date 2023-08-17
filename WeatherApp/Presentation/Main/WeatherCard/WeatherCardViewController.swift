//
//  WeatherCardViewController.swift
//  WeatherApp
//
//  Created by sandy on 2023/07/17.
//

import Foundation
import UIKit
import SwiftUI
import PinLayout
import FlexLayout

class WeatherCardViewController: UIViewController {
    typealias VM = MainViewModel
    private let vm: VM
    
    var item: WeatherCardItem?
    var isAddCard: Bool {
        item == nil
    }
    
    let addButton: UIButton = UIButton()
    
    fileprivate lazy var rootFlexContainer: UIView = UIView()
    
    // Header
    private lazy var currentTempLabel: UILabel = UILabel()
    private lazy var currentDescriptionLabel: UILabel = UILabel()
    private lazy var currentWeatherImage: UIImageView = UIImageView()
    private lazy var locationLabel: UILabel = UILabel()
    private lazy var tempDescription: UILabel = UILabel()
    
    //Hourly
    fileprivate lazy var hourlyScrollView: UIScrollView = UIScrollView()
    fileprivate lazy var hourlyContentView: UIView = UIView()
    
    init(vm: VM, item: WeatherCardItem?) {
        self.vm = vm
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        rootFlexContainer.pin.all(view.pin.safeArea)
        rootFlexContainer.flex.layout()
        
        // hourlyScrollView
        hourlyScrollView.pin
            .below(of: tempDescription).marginTop(14)
            .left()
            .right()
        
        hourlyContentView.flex.layout(mode: .adjustWidth)
        hourlyScrollView.contentSize = hourlyContentView.frame.size
        
        hourlyScrollView.showsVerticalScrollIndicator = false
        hourlyScrollView.showsHorizontalScrollIndicator = false
        hourlyScrollView.alwaysBounceVertical = false
        hourlyScrollView.alwaysBounceHorizontal = false
    }
    
    private func setLayout() {
        view.addSubview(rootFlexContainer)
        hourlyScrollView.addSubview(hourlyContentView)
        
        rootFlexContainer.flex.backgroundColor(.white.withAlphaComponent(0.13))
        rootFlexContainer.flex.cornerRadius(20)
        
        if let item = self.item, let currentWeather = item.currentWeather {
            let daily = item.daily
            let hourly = item.hourly
            let threeHourly = item.threeHourly
            
            rootFlexContainer.flex
                .padding(16)
                .direction(.column)
                .define { flex in
                    // HEADER
                    drawHeader(flex, item: item, currentWeather: currentWeather, daily: daily)
                    flex.addItem(hourlyScrollView)
                }
            drawHourly(item: item, hourly: hourly)
        } else {
            rootFlexContainer.flex
                .justifyContent(.center)
                .define { flex in
                    let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold, scale: .large)
                    let addImageBold = UIImage(systemName: "plus", withConfiguration: config)?.withTintColor(.black, renderingMode: .alwaysOriginal)
                    addButton.setImage(addImageBold, for: .normal)
                    addButton.addTarget(self, action: #selector(self.onClickAddLocation), for: .touchUpInside)
                    
                    flex.addItem(addButton)
                }
        }
    }
    
    @objc func onClickAddLocation() {
        vm.onClickAddLocation()
    }
    
    
    private func drawHourly(item: WeatherCardItem, hourly: [HourlyWeather]) {
        hourlyContentView.flex
            .direction(.row)
            .justifyContent(.start)
            .alignItems(.center)
            .backgroundColor(.white.withAlphaComponent(0.13))
            .cornerRadius(12)
            .define { flex in
                hourly.indices.forEach { idx in
                    let item = hourly[idx]
                    flex.addItem()
                        .direction(.column)
                        .justifyContent(.center)
                        .alignItems(.center)
                        .padding(14)
                        .define { flex in
                            let time: UILabel = UILabel()
                            let image: UIImageView = UIImageView()
                            let temp: UILabel = UILabel()
                            let pop: UILabel = UILabel()

                            time.font = .en14
                            time.text = "\(Utils.intervalToHour(item.dt))"

                            temp.font = .en14
                            temp.text = String(format: "%.0f", item.temp)

                            pop.font = .en14
                            pop.text = String(format: "%d%%", item.pop)

                            image.contentMode = .scaleAspectFit
                            image.image = UIImage(named: item.weather.first?.icon ?? "")?.resized(toWidth: 34.0)

                            flex.addItem(time)
                            flex.addItem(image)
                            flex.addItem(temp)
                            flex.addItem()
                                .direction(.row)
                                .alignItems(.center)
                                .define { flex in
                                    let waterDrop: UIImageView = UIImageView()
                                    waterDrop.image = UIImage(named: "water_drop")?.resized(toWidth: 12)
                                    flex.addItem(waterDrop)
                                    flex.addItem(pop)
                                }
                        }
                }
            }
    }
    
    private func drawHeader(_ flex: Flex, item: WeatherCardItem, currentWeather: Current, daily: [DailyWeather]) {
        flex.addItem()
            .direction(.row)
            .justifyContent(.spaceBetween)
            .padding(0)
            .define { flex in
                flex.addItem()
                    .direction(.column)
                    .define { flex in
                        currentTempLabel.font = .en38
                        currentTempLabel.text = String(format: "%.1f", currentWeather.temp)
                        
                        currentDescriptionLabel.font = .en20
                        currentDescriptionLabel.text = currentWeather.weather.first?.description
                        
                        currentWeatherImage.contentMode = .scaleAspectFit
                        currentWeatherImage.image = UIImage(named: currentWeather.weather.first?.icon ?? "")?.resized(toWidth: 80.0)
                        
                        locationLabel.font = .en16
                        locationLabel.text = item.location.name
                        
                        flex.addItem(currentTempLabel)
                        flex.addItem(currentDescriptionLabel)
                        flex.addItem()
                            .direction(.row)
                            .marginTop(20)
                            .define { flex in
                                flex.addItem(locationLabel)
                                if item.location.isCurrent {
                                    let locationImage: UIImageView = UIImageView()
                                    locationImage.contentMode = .scaleAspectFit
                                    locationImage.image = UIImage(systemName: "location.fill")?.resized(toWidth: 13)
                                    flex.addItem(locationImage).marginLeft(4)
                                }
                            }
                        
                        tempDescription.font = .en16
                        tempDescription.text = String(format: "%.1f / %.1f  체감 온도 %.1f", daily.first?.temp.min ?? 0.0, daily.first?.temp.max ?? 0.0, currentWeather.feels_like)
                        flex.addItem(tempDescription).marginTop(2)
                    }
                flex.addItem(currentWeatherImage).alignSelf(.start)
            }
    }
}
