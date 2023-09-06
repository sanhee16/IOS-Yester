//
//  MainViewController.swift
//  WeatherApp
//
//  Created by sandy on 2023/07/10.
//

import UIKit
import SwiftUI
import Combine
//import SnapKit
import PinLayout
import FlexLayout

// https://marlonjames.medium.com/uipageviewcontroller-with-dynamic-data-d5eedadccce6
class MainViewController: BaseViewController {
    typealias VM = MainViewModel
    
    private let vm: VM
    
    fileprivate lazy var rootFlexContainer: UIView = UIView()
    fileprivate var pageVC: UIPageViewController
    fileprivate var pages: [WeatherCardViewController]
    
    
    var currentIdx: Int {
        guard let vc = pageVC.viewControllers?.first else { return 0 }
        return pages.firstIndex(of: vc as! WeatherCardViewController) ?? 0
    }
    
    var lottieVC: LottieVC = {
        let lottieVC = LottieVC(type: .progressing)
        lottieVC.modalPresentationStyle = .overFullScreen
        lottieVC.modalTransitionStyle = .crossDissolve
        lottieVC.view.backgroundColor = .clear
        return lottieVC
    }()
    
    init(vm: VM) {
        self.vm = vm
        self.pages = []
        let options: [UIPageViewController.OptionsKey : Any] = [
            .interPageSpacing: 20,
            .spineLocation: UIPageViewController.SpineLocation.mid
        ]
        self.pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
        
        super.init()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        vm.updateStatus.observe(on: self) { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .none:
                break
            case .load(let idx, let item):
                self.pages[idx] = WeatherCardViewController(vm: self.vm, item: item)
                self.loadPages(status)
                break
            case .reload(let items):
                self.pages.removeAll()
                for item in items {
                    self.pages.append(WeatherCardViewController(vm: self.vm, item: item))
                }
                self.pages.append(WeatherCardViewController(vm: self.vm, item: nil))

                self.loadPages(status)
                break
            }
        }
        
        vm.isLoading.observe(on: self) {[weak self] isLoading in
            DispatchQueue.main.asyncAfter(deadline: .now() + (isLoading ? 0.0 : 0.6) ) { [weak self] in
                self?.lottieVC.view.isHidden = !isLoading
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.setLayout()
        
        vm.viewDidLoad()
    }
    
    private func loadPages(_ status: UpdateStatus) {
        if case .reload(_) = status {
            self.pageVC.delegate = self
        }
        self.pageVC.dataSource = nil
        self.pageVC.dataSource = self
        
        if case .reload(_) = status {
            if let firstVC = cardViewControllerAtIndex(self.currentIdx) {
                let viewControllers = [firstVC]
                // 현재 페이지를 설정하는 것
                self.pageVC.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
            }
        }
    }
    
    private func setLayout() {
        //addChild: self.lottieVC(VC)를 현재 VC(MainVC)의 자식으로 설정
        self.addChild(self.lottieVC)
        self.addChild(self.pageVC)
        
        //addSubview: 추가된 childVC의 View가 보일 수 있도록 맨 앞으로 등장하게 하는 것
        view.addSubview(rootFlexContainer)
        view.addSubview(self.lottieVC.view)
        view.backgroundColor = .primeColor2
        
        rootFlexContainer.flex
            .justifyContent(.center)
            .alignItems(.center)
            .define { flex in
                flex.addItem(self.pageVC.view)
            }
    }
    
    private func cardViewControllerAtIndex(_ index: Int) -> WeatherCardViewController? {
        if self.pages.count <= index { return nil }
        vm.onChangePage(index, onDone: nil)
        return self.pages[index]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.viewWillAppear()
        
        // 1. container의 Layout을 먼저 잡아줌
        rootFlexContainer.pin.all(view.pin.safeArea)
        
        // 2. flexbox child를 layout한다(child의 layout을 잡아준다).
        // default is '.fitContainer'. 자식뷰들이 컨테이너의 크기 안에 배치(child는 container의 크기(width, height)내에 배치된다).
        rootFlexContainer.flex.layout()
    }
}

extension MainViewController: UIPageViewControllerDataSource {
    // 현재 페이지 뷰의 이전 뷰를 미리 로드
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard self.currentIdx > 0 else { return nil }
        return cardViewControllerAtIndex(self.currentIdx - 1)
    }
    
    // 현재 페이지 뷰의 다음 뷰를 미리 로드
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard self.currentIdx < self.pages.count - 1 else { return nil }
        return cardViewControllerAtIndex(self.currentIdx + 1)
    }
    
    // 인디케이터의 개수
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pages.count
    }
    
    // 인디케이터의 초기 값
    func presentationIndex(for _: UIPageViewController) -> Int {
        return 0
    }
}

extension MainViewController: UIPageViewControllerDelegate {
    // 현재 페이지 로드가 끝났을 때
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed { return }
    }
}
