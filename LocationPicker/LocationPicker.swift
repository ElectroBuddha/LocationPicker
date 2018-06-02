//
//  LocationPicker.swift
//  LocationPicker
//
//  Created by Jerome Tan on 3/28/16.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Jerome Tan
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import MapKit

open class LocationPicker: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: Types
    
    public enum NavigationItemOrientation {
        case left
        case right
    }
    
    public enum LocationType: Int {
        case currentLocation
        case searchLocation
        case alternativeLocation
    }
    
    
    // MARK: - Completion closures
    
    /**
     Completion closure executed after everytime user select a location.
     
     - important:
     If you override `func locationDidSelect(locationItem: LocationItem)` without calling `super`, this closure would not be called.
     
     - Note:
     This closure would be executed multiple times, because user may change selection before final decision.
     
     To get user's final decition, use `var pickCompletion` instead.
     
     Alternatively, the same result can be achieved by:
     * Delegate
     1. conform to `protocol LocationPickerDelegate`
     2. set the `var delegate`
     3. implement `func locationDidSelect(locationItem: LocationItem)`
     * Overrride
     1. create a subclass of `class LocationPicker`
     2. override `func locationDidSelect(locationItem: LocationItem)`
     
     - SeeAlso:
     `var pickCompletion: ((LocationItem) -> Void)?`
     
     `func locationDidSelect(locationItem: LocationItem)`
     
     `protocol LocationPickerDelegate`
     */
    open var selectCompletion: ((LocationItem) -> Void)?
    
    /**
     Completion closure executed after user finally pick a location.
     
     - important:
     If you override `func locationDidPick(locationItem: LocationItem)` without calling `super`, this closure would not be called.
     
     - Note:
     This closure would be executed only once in `func viewWillDisappear(animated: Bool)` before this instance of `LocationPicker` dismissed.
     
     To get user's every selection, use `var selectCompletion` instead.
     
     Alternatively, the same result can be achieved by:
     * Delegate
     1. conform to `protocol LocationPickerDelegate`
     2. set the `var delegate`
     3. implement `func locationDidPick(locationItem: LocationItem)`
     * Override
     1. create a subclass of `class LocationPicker`
     2. override `func locationDidPick(locationItem: LocationItem)`
     
     - SeeAlso:
     `var selectCompletion: ((LocationItem) -> Void)?`
     
     `func locationDidPick(locationItem: LocationItem)`
     
     `protocol LocationPickerDelegate`
     */
    open var pickCompletion: ((LocationItem) -> Void)?
    
    /**
     Completion closure executed after user delete an alternative location.
     
     - important:
     If you override `func alternativeLocationDidDelete(locationItem: LocationItem)` without calling `super`, this closure would not be called.
     
     - Note:
     This closure would be executed when user delete a location cell from `tableView`.
     
     User can only delete the location provided in `var alternativeLocations` or `dataSource` method `alternativeLocationAtIndex(index: Int) -> LocationItem`.
     
     Alternatively, the same result can be achieved by:
     * Delegate
     1. conform to `protocol LocationPickerDataSource`
     2. set the `var dataSource`
     3. implement `func commitAlternativeLocationDeletion(locationItem: LocationItem)`
     * Override
     1. create a subclass of `class LocationPicker`
     2. override `func alternativeLocationDidDelete(locationItem: LocationItem)`
     
     - SeeAlso:
     `func alternativeLocationDidDelete(locationItem: LocationItem)`
     
     `protocol LocationPickerDataSource`
     */
    open var deleteCompletion: ((LocationItem) -> Void)?
    
    /**
     Handler closure executed when user try to fetch current location without location access.
     
     - important:
     If you override `func locationDidDeny(locationPicker: LocationPicker)` without calling `super`, this closure would not be called.
     
     - Note:
     If this neither this closure is not set and the delegate method with the same purpose is not provided, an alert view controller will be presented, you can configure it using `func setLocationDeniedAlertControllerTitle` or provide a fully cutomized `UIAlertController` to `var locationDeniedAlertController`.
     
     Alternatively, the same result can be achieved by:
     * Delegate
     1. conform to `protocol LocationPickerDelegate`
     2. set the `var delegate`
     3. implement `func locationDidDeny(locationPicker: LocationPicker)`
     * Override
     1. create a subclass of `class LocationPicker`
     2. override `func locationDidDeny(locationPicker: LocationPicker)`
     
     - SeeAlso:
     `func locationDidDeny(locationPicker: LocationPicker)`
     
     `protocol LocationPickerDelegate`
     
     `var locationDeniedAlertController`
     
     `func setLocationDeniedAlertControllerTitle`
     
     */
    open var locationDeniedHandler: ((LocationPicker) -> Void)?
    
    
    // MARK: Optional variables
    
    /// Delegate of `protocol LocationPickerDelegate`
    open weak var delegate: LocationPickerDelegate?
    
    /// DataSource of `protocol LocationPickerDataSource`
    open weak var dataSource: LocationPickerDataSource?
    
    /**
     Locations that show in the location list.
     
     - Note:
     Alternatively, `LocationPicker` can obtain locations via DataSource:
     1. conform to `protocol LocationPickerDataSource`
     2. set the `var dataSource`
     3. implement `func numberOfAlternativeLocations() -> Int` to tell the `tableView` how many rows to display
     4. implement `func alternativeLocationAtIndex(index: Int) -> LocationItem`
     
     - SeeAlso:
     `func numberOfAlternativeLocations() -> Int`
     
     `func alternativeLocationAtIndex(index: Int) -> LocationItem`
     
     `protocol LocationPickerDataSource`
     */
    open var alternativeLocations: [LocationItem]?
    
    /**
     Alert Controller shows when user try to fetch current location without location permission.
     
     - Note:
     If you are content with the default alert controller, don't set this property, just change the text in it by calling `func setLocationDeniedAlertControllerTitle` or change the following text directly.
     
            var locationDeniedAlertTitle
            var locationDeniedAlertMessage
            var locationDeniedGrantText
            var locationDeniedCancelText
     
     - SeeAlso:
     `func setLocationDeniedAlertControllerTitle`
     
     `var locationDeniedHandler: ((LocationPicker) -> Void)?`
     
     `func locationDidDeny(locationPicker: LocationPicker)`
     
     `protocol LocationPickerDelegate`
     */
    open var locationDeniedAlertController: UIAlertController?
    
    
    /**
     Allows the selection of locations that did not match or exactly match search results.
     
     - Note:
     If an arbitrary location is selected, its coordinate in `LocationItem` will be `nil`. __Default__ is __`false`__.
    */
    open var isAllowArbitraryLocation = false
    
    
    /**
     Index of preselected location item
     
     - Note:
     To set user's current location as preselected, set this to 0. To preselect a location from alternative locations, set this to the index of that location plus 1
     */
    open var preselectedIndex: Int?
    
    
    // MARK: UI Customizations
    
    /// Text that indicates user's current location. __Default__ is __`"Current Location"`__.
    open var currentLocationText = "Current Location"
    
    /// Text of search bar's placeholder. __Default__ is __`"Search for location"`__.
    open var searchBarPlaceholder = "Search for location"
    
    /// Text of location denied alert title. __Default__ is __`"Location access denied"`__
    open var locationDeniedAlertTitle = "Location access denied"
    
    /// Text of location denied alert message. __Default__ is __`"Grant location access to use current location"`__
    open var locationDeniedAlertMessage = "Grant location access to use current location"
    
    /// Text of location denied alert _Grant_ button. __Default__ is __`"Grant"`__
    open var locationDeniedGrantText = "Grant"
    
    /// Text of location denied alert _Cancel_ button. __Default__ is __`"Cancel"`__
    open var locationDeniedCancelText = "Cancel"
    
    
    /// Longitudinal distance in meters that the map view shows when user select a location and before zoom in or zoom out. __Default__ is __`1000`__.
    open var defaultLongitudinalDistance: Double = 1000
    
    /// Distance in meters that is used to search locations. __Default__ is __`10000`__
    open var searchDistance: Double = 10000
    
        /// Default coordinate to use when current location information is not available. If not set, none is used.
    open var defaultSearchCoordinate: CLLocationCoordinate2D?
    
    
    /// `mapView.zoomEnabled` will be set to this property's value after view is loaded. __Default__ is __`true`__
    open var isMapViewZoomEnabled = true
    
    /// `mapView.showsUserLocation` is set to this property's value after view is loaded. __Default__ is __`true`__
    open var isMapViewShowsUserLocation = true
    
    /// `mapView.scrollEnabled` is set to this property's value after view is loaded. __Default__ is __`true`__
    open var isMapViewScrollEnabled = true
    
    /// Whether redirect to the exact coordinate after queried. __Default__ is __`true`__
    open var isRedirectToExactCoordinate = true
    
    /**
     Whether the locations provided in `var alternativeLocations` or obtained from `func alternativeLocationAtIndex(index: Int) -> LocationItem` can be deleted. __Default__ is __`false`__
     - important:
     If this property is set to `true`, remember to update your models by closure, delegate, or override.
     */
    open var isAlternativeLocationEditable = false
    
    /**
     Whether to force reverse geocoding or not. If this property is set to `true`, the location will be reverse geocoded. This is helpful if you require an exact location (e.g. providing street), but the user just searched for a town name.
     The default behavior is to not geocode any additional search result.
     */
    open var isForceReverseGeocoding = false
    
    
    /// `tableView.backgroundColor` is set to this property's value afte view is loaded. __Default__ is __`UIColor.whiteColor()`__
    open var tableViewBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    /// The color of the icon showed in current location cell. __Default__ is __`UIColor(hue: 0.447, saturation: 0.731, brightness: 0.569, alpha: 1)`__
    open var currentLocationIconColor = #colorLiteral(red: 0.1176470588, green: 0.5098039216, blue: 0.3568627451, alpha: 1)
    
    /// The color of the icon showed in search result location cells. __Default__ is __`UIColor(hue: 0.447, saturation: 0.731, brightness: 0.569, alpha: 1)`__
    open var searchResultLocationIconColor = #colorLiteral(red: 0.1176470588, green: 0.5098039216, blue: 0.3568627451, alpha: 1)
    
    /// The color of the icon showed in alternative location cells. __Default__ is __`UIColor(hue: 0.447, saturation: 0.731, brightness: 0.569, alpha: 1)`__
    open var alternativeLocationIconColor = #colorLiteral(red: 0.1176470588, green: 0.5098039216, blue: 0.3568627451, alpha: 1)
    
    /// The color of the pin showed in the center of map view. __Default__ is __`UIColor(hue: 0.447, saturation: 0.731, brightness: 0.569, alpha: 1)`__
    open var pinColor = #colorLiteral(red: 0.1176470588, green: 0.5098039216, blue: 0.3568627451, alpha: 1)
    
    /// The color of primary text color. __Default__ is __`UIColor(colorLiteralRed: 0.34902, green: 0.384314, blue: 0.427451, alpha: 1)`__
    open var primaryTextColor = #colorLiteral(red: 0.34902, green: 0.384314, blue: 0.427451, alpha: 1)
    
    /// The color of secondary text color. __Default__ is __`UIColor(colorLiteralRed: 0.541176, green: 0.568627, blue: 0.584314, alpha: 1)`__
    open var secondaryTextColor = #colorLiteral(red: 0.541176, green: 0.568627, blue: 0.584314, alpha: 1)
    
    
    /// The image of the icon showed in current location cell. If this property is set, the `var currentLocationIconColor` won't be adopted.
    open var currentLocationIcon: UIImage? = nil
    
    /// The image of the icon showed in search result location cells. If this property is set, the `var searchResultLocationIconColor` won't be adopted.
    open var searchResultLocationIcon: UIImage? = nil
    
    /// The image of the icon showed in alternative location cells. If this property is set, the `var alternativeLocationIconColor` won't be adopted.
    open var alternativeLocationIcon: UIImage? = nil
    
    /// The image of the pin showed in the center of map view. If this property is set, the `var pinColor` won't be adopted.
    open var pinImage: UIImage? = nil
    
        /// The size of the pin's shadow. Set this value to zero to hide the shadow. __Default__ is __`5`__
    open var pinShadowViewDiameter: CGFloat = 5
    
    open var defaultIconResizingBehaviour: StyleKit.ResizingBehavior = .aspectFit
    open var defaultIconSize: CGSize = CGSize(width: 48, height: 48)
    open var searchDelayTimerInterval: TimeInterval = 1.0
    private var searchDelayTimer: Timer?
    open var mapViewHeaderTitle: String = "Select from the map".uppercased()
    open var mapViewHeaderSubtitle: String = "zoom and move the map to select the location"
    open var searchResultSectionTitle: String = "Search results".uppercased()
    open var currentLocationSectionTitle: String = "My location".uppercased()
    open var alternativeLocationsSectionTitle: String = "Quick locations:".uppercased()
    fileprivate var searchBarTopConstraint: NSLayoutConstraint!
    
    // MARK: - UI Elements
    
    public let searchBar = UISearchBar()
    public var tableView: UITableView!
    public let mapView = MKMapView()
    public let pinView = UIImageView()
    public let pinShadowView = UIView()
    
    lazy var mapViewHeaderView: MapViewHeaderView = {
        return MapViewHeaderView(title: mapViewHeaderTitle, subtitle: mapViewHeaderSubtitle, separatorColor: tableView.separatorColor!.withAlphaComponent(0.5))
    }()
    
    open private(set) var barButtonItems: (doneButtonItem: UIBarButtonItem, cancelButtonItem: UIBarButtonItem)?
    
    
    // MARK: Attributes
    
    fileprivate let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    fileprivate var selectedLocationItem: LocationItem?
    fileprivate var searchResultLocations = [LocationItem]()
    
    fileprivate var alternativeLocationCount: Int {
        get {
            return alternativeLocations?.count ?? dataSource?.numberOfAlternativeLocations() ?? 0
        }
    }
    
    
    /// This property is used to record the longitudinal distance of the map view. This is neccessary because when user zoom in or zoom out the map view, func showMapViewWithCenterCoordinate(coordinate: CLLocationCoordinate2D, WithDistance distance: Double) will reset the region of the map view.
    open var longitudinalDistance: Double!
    
    
    /// This property is used to record whether the map view center changes. This is neccessary because private func showMapViewWithCenterCoordinate(coordinate: CLLocationCoordinate2D, WithDistance distance: Double) would trigger func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) which calls func reverseGeocodeLocation(location: CLLocation), and this method calls private func showMapViewWithCenterCoordinate(coordinate: CLLocationCoordinate2D, WithDistance distance: Double) back, this would lead to an infinite loop.
    open var isMapViewCenterChanged = false
    
    private var mapViewHeightConstraint: NSLayoutConstraint!
    private var mapViewHeight: CGFloat {
        get {
            return (view.frame.height / 2) - (self.navigationController?.navigationBar.frame.size.height ?? 0.0) - searchBar.frame.size.height //return view.frame.width / 3 * 2
        }
    }
    
    private var pinViewCenterYConstraint: NSLayoutConstraint!
    fileprivate var pinViewImageHeight: CGFloat {
        get {
            return pinView.image!.size.height
        }
    }

    
    // MARK: Customs
    
    /**
     Add two bar buttons that confirm and cancel user's location pick.
     
     - important:
     If this method is called, only when user tap done button can the pick closure, method and delegate method be called.
     If you don't provide `UIBarButtonItem` object, default system style bar button will be used.
     
     - Note:
     You don't need to set the `target` and `action` property of the buttons, `LocationPicker` will handle the dismission of this view controller.
     
     - parameter doneButtonItem:      An `UIBarButtonItem` tapped to confirm selection, default is a _Done_ `barButtonSystemItem`
     - parameter cancelButtonItem:    An `UIBarButtonITem` tapped to cancel selection, default is a _Cancel_ `barButtonSystemItem`
     - parameter doneButtonOrientation: The direction of the done button, default is `.Right`
     */
    public func addBarButtons(doneButtonItem: UIBarButtonItem? = nil,
                              cancelButtonItem: UIBarButtonItem? = nil,
                              doneButtonOrientation: NavigationItemOrientation = .right) {
        let doneButtonItem = doneButtonItem ?? UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        doneButtonItem.isEnabled = false
        doneButtonItem.target = self
        doneButtonItem.action = #selector(doneButtonDidTap(barButtonItem:))
        
        let cancelButtonItem = cancelButtonItem ?? UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        cancelButtonItem.target = self
        cancelButtonItem.action = #selector(cancelButtonDidTap(barButtonItem:))
        
        switch doneButtonOrientation {
        case .right:
            navigationItem.leftBarButtonItem = cancelButtonItem
            navigationItem.rightBarButtonItem = doneButtonItem
        case .left:
            navigationItem.leftBarButtonItem = doneButtonItem
            navigationItem.rightBarButtonItem = cancelButtonItem
        }
        
        barButtonItems = (doneButtonItem, cancelButtonItem)
    }
    
    /**
     If you are content with the icons provided in `LocaitonPicker` but not with the colors, you can change them by calling this method.
     
     This mehod can also change the color of text color all over the UI.
     
     - Note:
     You can set the color of three icons and the pin in map view by setting the attributes listed below, but to keep the UI consistent, this is not recommanded.
     
            var currentLocationIconColor
            var searchResultLocationIconColor
            var alternativeLocationIconColor
            var pinColor
     
     If you are not satisified with the shape of icons and pin image, you can change them by setting the attributes below.
     
            var currentLocationIconImage
            var searchResultLocationIconImage
            var alternativeLocationIconImage
            var pinImage
     
     - parameter themeColor:         The color of all icons
     - parameter primaryTextColor:   The color of primary text
     - parameter secondaryTextColor: The color of secondary text
     */
    public func setColors(themeColor: UIColor? = nil, primaryTextColor: UIColor? = nil, secondaryTextColor: UIColor? = nil) {
        self.currentLocationIconColor = themeColor ?? self.currentLocationIconColor
        self.searchResultLocationIconColor = themeColor ?? self.searchResultLocationIconColor
        self.alternativeLocationIconColor = themeColor ?? self.alternativeLocationIconColor
        self.pinColor = themeColor ?? self.pinColor
        self.primaryTextColor = primaryTextColor ?? self.primaryTextColor
        self.secondaryTextColor = secondaryTextColor ?? self.secondaryTextColor
    }
    
    /**
     Set text of alert controller presented when user try to get current location but denied app's authorization.
     
     If you are content with the default alert controller provided by `LocationPicker`, just call this method to change the alert text to your any language you like.
     
     - Note: 
     If you are not satisfied with the default alert controller, just set `var locationDeniedAlertController` to your fully customized alert controller. If you don't want to present an alert controller at all in such situation, you can customize the behavior of `LocationPicker` by setting closure, using delegate or overriding.
     
     - parameter title:      Text of location denied alert title
     - parameter message:    Text of location denied alert message
     - parameter grantText:  Text of location denied alert _Grant_ button text
     - parameter cancelText: Text of location denied alert _Cancel_ button text
     */
    public func setLocationDeniedAlertControllerTexts(title: String? = nil, message: String? = nil, grantText: String? = nil, cancelText: String? = nil) {
        self.locationDeniedAlertTitle = title ?? self.locationDeniedAlertTitle
        self.locationDeniedAlertMessage = message ?? self.locationDeniedAlertMessage
        self.locationDeniedGrantText = grantText ?? self.locationDeniedGrantText
        self.locationDeniedCancelText = cancelText ?? self.locationDeniedCancelText
    }
    
    
    /**
     Decide if an item from MKLocalSearch should be displayed or not
     
     - parameter locationItem:      An instance of `LocationItem`
     */
    open func shouldShowSearchResult(for mapItem: MKMapItem) -> Bool {
        return true
    }
    
    
    // MARK: - View Controller
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: .zero, style: .grouped)
        
        longitudinalDistance = defaultLongitudinalDistance
        
        setupLocationManager()
        setupViews()
        layoutViews()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let index = preselectedIndex, index < alternativeLocationCount {
            tableView.selectRow(at: IndexPath(row: index, section: 2), animated: true, scrollPosition: .none)
            tableView(tableView, didSelectRowAt: IndexPath(row: index, section: 2))
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard barButtonItems?.doneButtonItem == nil else { return }
        
        searchDelayTimer?.invalidate()
        searchDelayTimer = nil
        
        if let locationItem = selectedLocationItem {
            locationDidPick(locationItem: locationItem)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapViewHeightConstraint.constant = mapViewHeight
    }
    
    // MARK: Initializations
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        if #available(iOS 9.0, *) {
            locationManager.requestLocation()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func setupViews() {
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)    // the background color of view needs to be set because this color would affect the color of navigation bar if it is translucent.

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = tableViewBackgroundColor
        tableView.contentInset.bottom = 50.0
        tableView.contentInset.top = 64
        // Prevent gap between sections
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        
        searchBar.delegate = self
        searchBar.placeholder = searchBarPlaceholder
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.textColor = primaryTextColor
        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = tableView.backgroundColor
        searchBar.sizeToFit()
        
        let searchBarSubViews = searchBar.subviews.flatMap { $0.subviews }
        if let searchBarTextField = (searchBarSubViews.filter { $0 is UITextField }).first as? UITextField {
            searchBarTextField.layer.borderColor = tableView.separatorColor?.withAlphaComponent(0.5).cgColor
            searchBarTextField.layer.borderWidth = 0.7
            searchBarTextField.layer.cornerRadius = 10.0
            
            searchBarTextField.layer.shadowColor  = UIColor.black.cgColor
            searchBarTextField.layer.shadowRadius  = 3.0
            searchBarTextField.layer.shadowOpacity = 0.09
            searchBarTextField.layer.shadowOffset  = CGSize(width: 0.0, height: 3.0)
        }
        
        mapView.isZoomEnabled = isMapViewZoomEnabled
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.isScrollEnabled = isMapViewScrollEnabled
        mapView.showsUserLocation = isMapViewShowsUserLocation
        mapView.delegate = self
        
        pinView.image = pinImage ?? StyleKit.imageOfPinIconFilled(color: pinColor)
        pinView.tintColor = pinColor
        
        pinShadowView.layer.cornerRadius = pinShadowViewDiameter / 2
        pinShadowView.clipsToBounds = false
        pinShadowView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        pinShadowView.layer.shadowColor = UIColor.black.cgColor
        pinShadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        pinShadowView.layer.shadowRadius = 2
        pinShadowView.layer.shadowOpacity = 1
        
        if isMapViewScrollEnabled {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureInMapViewDidRecognize(panGestureRecognizer:)))
            panGestureRecognizer.delegate = self
            mapView.addGestureRecognizer(panGestureRecognizer)
        }
        
        view.addSubview(tableView)
        view.addSubview(searchBar)
        view.addSubview(mapView)
        view.addSubview(mapViewHeaderView)
        mapView.addSubview(pinShadowView)
        mapView.addSubview(pinView)

    }
    
    private func layoutViews() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        pinView.translatesAutoresizingMaskIntoConstraints = false
        pinShadowView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 9.0, *) {
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            searchBar.heightAnchor.constraint(equalToConstant: 64).isActive = true
            searchBarTopConstraint = searchBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
            searchBarTopConstraint.isActive = true
            
            //searchBar.alpha = 0.0
 
            //tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            
            mapView.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
            mapView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
            mapView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true //mapView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
            
            mapViewHeaderView.bottomAnchor.constraint(equalTo: mapView.topAnchor).isActive = true
            mapViewHeaderView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor).isActive = true
            mapViewHeaderView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor).isActive = true
            
            mapViewHeightConstraint = mapView.heightAnchor.constraint(equalToConstant: 0)
            mapViewHeightConstraint.isActive = true
            
            pinView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
            pinViewCenterYConstraint = pinView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -pinViewImageHeight / 2)
            pinViewCenterYConstraint.isActive = true
            
            pinShadowView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
            pinShadowView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
            pinShadowView.widthAnchor.constraint(equalToConstant: pinShadowViewDiameter).isActive = true
            pinShadowView.heightAnchor.constraint(equalToConstant: pinShadowViewDiameter).isActive = true
        } else {
            NSLayoutConstraint(item: searchBar, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: searchBar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: searchBar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            
            NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: searchBar, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: searchBar, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: searchBar, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            
            NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal, toItem: tableView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: mapView, attribute: .leading, relatedBy: .equal, toItem: tableView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: mapView, attribute: .trailing, relatedBy: .equal, toItem: tableView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true //NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0).isActive = true
            
            mapViewHeightConstraint = NSLayoutConstraint(item: mapView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
            mapViewHeightConstraint.isActive = true
            
            NSLayoutConstraint(item: pinView, attribute: .centerX, relatedBy: .equal, toItem: mapView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
            pinViewCenterYConstraint = NSLayoutConstraint(item: pinView, attribute: .centerY, relatedBy: .equal, toItem: mapView, attribute: .centerY, multiplier: 1, constant: -pinViewImageHeight / 2)
            pinViewCenterYConstraint.isActive = true
            
            NSLayoutConstraint(item: pinShadowView, attribute: .centerX, relatedBy: .equal, toItem: mapView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: pinShadowView, attribute: .centerY, relatedBy: .equal, toItem: mapView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: pinShadowView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: pinShadowViewDiameter).isActive = true
            NSLayoutConstraint(item: pinShadowView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: pinShadowViewDiameter).isActive = true
        }
        
//        searchBar.frame = CGRect(x: searchBar.frame.origin.x, y: searchBar.frame.origin.y, width: tableView.frame.size.width, height: 64.0)
//        tableView.tableHeaderView = searchBar
    }
    
    
    // MARK: Gesture Recognizer
    
    @objc func panGestureInMapViewDidRecognize(panGestureRecognizer: UIPanGestureRecognizer) {
        switch(panGestureRecognizer.state) {
        case .began:
            ////
            // Unfocus searchBar text field when map moved
            searchBar.endEditing(true)
            //
            
            isMapViewCenterChanged = true
            selectedLocationItem = nil
            //showSearchBarActivityIndicator(true)
            //searchBar.text = nil
            geocoder.cancelGeocode()
            if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
            }
            if let doneButtonItem = barButtonItems?.doneButtonItem {
                doneButtonItem.isEnabled = false
            }
        default:
            break
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    // MARK: Buttons
    
    @objc func doneButtonDidTap(barButtonItem: UIBarButtonItem) {
        if let locationItem = selectedLocationItem {
            dismiss(animated: true, completion: nil)
            locationDidPick(locationItem: locationItem)
        }
    }
    
    @objc func cancelButtonDidTap(barButtonItem: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: UI Mainipulations
    
    private func showMapView(withCenter coordinate: CLLocationCoordinate2D, distance: Double) {
        mapViewHeightConstraint.constant = mapViewHeight
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, 0 , distance)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    fileprivate func closeMapView() {
        mapViewHeightConstraint.constant = 0
    }
    
    
    // MARK: Location Handlers
    
    /**
     Set the given LocationItem as the currently selected one. This will update the searchBar and show the map if possible.
     
     - parameter locationItem:      An instance of `LocationItem`
     */
    public func selectLocationItem(_ locationItem: LocationItem) {
        selectedLocationItem = locationItem
        searchBar.text = locationItem.name
        mapViewHeaderView.setSubtitleText(locationItem.name)
        if let coordinate = locationItem.coordinate {
            showMapView(withCenter: coordinateObject(fromTuple: coordinate), distance: longitudinalDistance)
        } else {
            closeMapView()
        }
        
        barButtonItems?.doneButtonItem.isEnabled = true
        locationDidSelect(locationItem: locationItem)
    }
    
    fileprivate func reverseGeocodeLocation(_ location: CLLocation) {
        searchBar.text = nil
        showSearchBarActivityIndicator(true)
        mapViewHeaderView.isActivityIndicatorActive = true
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(location, completionHandler: { [weak self] (placemarks, error) -> Void in
            guard let `self` = self else { return }
            self.showSearchBarActivityIndicator(false)
            self.mapViewHeaderView.isActivityIndicatorActive = false
            
            guard error == nil else {
                print(error!)
                return
            }
            guard let placemarks = placemarks else { return }
            var placemark = placemarks[0]
            if !self.isRedirectToExactCoordinate {
                placemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: placemark.addressDictionary as? [String : NSObject])
            }
            
            if !self.searchBar.isFirstResponder {
                let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                self.selectLocationItem(LocationItem(mapItem: mapItem))
            }
        })
    }
    
}


// MARK: - Callbacks

extension LocationPicker {
    
    /**
     This method would be called everytime user select a location including the change of region of the map view.
     
     - important:
     This method includes the following codes:
     
     selectCompletion?(locationItem)
     delegate?.locationDidSelect?(locationItem)
     
     So, if you override it without calling `super.locationDidSelect(locationItem)`, completion closure and delegate method would not be called.
     
     - Note:
     This method would be called multiple times, because user may change selection before final decision.
     
     To do something with user's final decition, use `func locationDidPick(locationItem: LocationItem)` instead.
     
     Alternatively, the same result can be achieved by:
     * Closure
     1. set `var selectCompletion`
     * Delegate
     1. conform to `protocol LocationPickerDelegate`
     2. set the `var delegate`
     3. implement `func locationDidPick(locationItem: LocationItem)`
     
     - SeeAlso:
     `var selectCompletion: ((LocationItem) -> Void)?`
     
     `func locationDidPick(locationItem: LocationItem)`
     
     `protocol LocationPickerDelegate`
     
     - parameter locationItem: The location item user selected
     */
    @objc open func locationDidSelect(locationItem: LocationItem) {
        selectCompletion?(locationItem)
        delegate?.locationDidSelect?(locationItem: locationItem)
    }
    
    /**
     This method would be called after user finally pick a location.
     
     - important:
     This method includes the following codes:
     
     pickCompletion?(locationItem)
     delegate?.locationDidPick?(locationItem)
     
     So, if you override it without calling `super.locationDidPick(locationItem)`, completion closure and delegate method would not be called.
     
     - Note:
     This method would be called only once in `func viewWillDisappear(animated: Bool)` before this instance of `LocationPicker` dismissed.
     
     To get user's every selection, use `func locationDidSelect(locationItem: LocationItem)` instead.
     
     Alternatively, the same result can be achieved by:
     * Closure
     1. set `var pickCompletion`
     * Delegate
     1. conform to `protocol LocationPickerDelegate`
     2. set the `var delegate`
     3. implement `func locationDidPick(locationItem: LocationItem)`
     
     - SeeAlso:
     `var pickCompletion: ((LocationItem) -> Void)?`
     
     `func locationDidSelect(locationItem: LocationItem)`
     
     `protocol LocationPickerDelegate`
     
     - parameter locationItem: The location item user picked
     */
    @objc open func locationDidPick(locationItem: LocationItem) {
        pickCompletion?(locationItem)
        delegate?.locationDidPick?(locationItem: locationItem)
    }
    
    /**
     This method would be called after user delete an alternative location.
     
     - important:
     This method includes the following codes:
     
     deleteCompletion?(locationItem)
     dataSource?.commitAlternativeLocationDeletion?(locationItem)
     
     So, if you override it without calling `super.alternativeLocationDidDelete(locationItem)`, completion closure and delegate method would not be called.
     
     - Note:
     This method would be called when user delete a location cell from `tableView`.
     
     User can only delete the location provided in `var alternativeLocations` or `dataSource` method `alternativeLocationAtIndex(index: Int) -> LocationItem`.
     
     Alternatively, the same result can be achieved by:
     * Closure
     1. set `var deleteCompletion`
     * Delegate
     1. conform to `protocol LocationPickerDataSource`
     2. set the `var dataSource`
     3. implement `func commitAlternativeLocationDeletion(locationItem: LocationItem)`
     
     - SeeAlso:
     `var deleteCompletion: ((LocationItem) -> Void)?`
     
     `protocol LocationPickerDataSource`
     
     - parameter locationItem: The location item needs to be deleted
     */
    open func alternativeLocationDidDelete(locationItem: LocationItem) {
        deleteCompletion?(locationItem)
        dataSource?.commitAlternativeLocationDeletion?(locationItem: locationItem)
    }
    
    /**
     This method would be called when user try to fetch current location without granting location access.
     
     - important:
     This method includes the following codes:
     
     locationDeniedHandler?(self)
     delegate?.locationDidDeny?(self)
     
     So, if you override it without calling `super.locationDidDeny(locationPicker)`, completion closure and delegate method would not be called.
     
     - Note:
     If you wish to present an alert view controller, just ignore this method. You can provide a fully cutomized `UIAlertController` to `var locationDeniedAlertController`, or configure the alert view controller provided by `LocationPicker` using `func setLocationDeniedAlertControllerTitle`.
     
     Alternatively, the same result can be achieved by:
     * Closure
     1. set `var locationDeniedHandler`
     * Delegate
     1. conform to `protocol LocationPickerDelegate`
     2. set the `var delegate`
     3. implement `func locationDidDeny(locationPicker: LocationPicker)`
     
     - SeeAlso:
     `var locationDeniedHandler: ((LocationPicker) -> Void)?`
     
     `protocol LocationPickerDelegate`
     
     `var locationDeniedAlertController`
     
     `func setLocationDeniedAlertControllerTitle`
     
     - parameter locationPicker `LocationPicker` instance that needs to response to user's location request
     */
    public func locationDidDeny(locationPicker: LocationPicker) {
        locationDeniedHandler?(self)
        delegate?.locationDidDeny?(locationPicker: self)
        
        if locationDeniedHandler == nil && delegate?.locationDidDeny == nil {
            if let alertController = locationDeniedAlertController {
                present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: locationDeniedAlertTitle, message: locationDeniedAlertMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: locationDeniedGrantText, style: .default, handler: { (alertAction) in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                }))
                alertController.addAction(UIAlertAction(title: locationDeniedCancelText, style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
}

// MARK: Search Bar Delegate

extension LocationPicker: UISearchBarDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            showSearchBarActivityIndicator(false)
            mapViewHeaderView.isActivityIndicatorActive = false
            searchDelayTimer?.invalidate()
            searchDelayTimer = Timer.scheduledTimer(timeInterval: searchDelayTimerInterval, target: self, selector: #selector(LocationPicker.search), userInfo: ["searchText" : searchText], repeats: false)
        } else {
            selectedLocationItem = nil
            searchResultLocations.removeAll()
            tableView.reloadData()
            closeMapView()
            
            if let doneButtonItem = barButtonItems?.doneButtonItem {
                doneButtonItem.isEnabled = false
            }
        }
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    @objc func search(timer: Timer) {
        guard let userInfo = timer.userInfo as? [AnyHashable : Any] , let searchText = userInfo["searchText"] as? String else { return }
 
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchText
        
        if let currentCoordinate = locationManager.location?.coordinate {
            localSearchRequest.region = MKCoordinateRegionMakeWithDistance(currentCoordinate, searchDistance, searchDistance)
        } else if let defaultSearchCoordinate = defaultSearchCoordinate, CLLocationCoordinate2DIsValid(defaultSearchCoordinate) {
            localSearchRequest.region = MKCoordinateRegionMakeWithDistance(defaultSearchCoordinate, searchDistance, searchDistance)
        }
        
        showSearchBarActivityIndicator(true)

        MKLocalSearch(request: localSearchRequest).start(completionHandler: { [weak self] (localSearchResponse, error) -> Void in
            guard let `self` = self else { return }

            self.showSearchBarActivityIndicator(false)
            
            guard searchText == self.searchBar.text else {
                // Ensure that the result is valid for the most recent searched text
                return
            }
            guard error == nil,
                let localSearchResponse = localSearchResponse, localSearchResponse.mapItems.count > 0 else {
                    if self.isAllowArbitraryLocation {
                        let locationItem = LocationItem(locationName: searchText)
                        self.searchResultLocations = [locationItem]
                    } else {
                        self.searchResultLocations = []
                    }
                    self.tableView.reloadData()
                    return
            }
            
            self.searchResultLocations = localSearchResponse.mapItems.filter({ (mapItem) -> Bool in
                return self.shouldShowSearchResult(for: mapItem)
            }).map({ LocationItem(mapItem: $0) })
            
            if self.isAllowArbitraryLocation {
                let locationFound = self.searchResultLocations.filter({
                    $0.name.lowercased() == searchText.lowercased()}).count > 0
                
                if !locationFound {
                    // Insert arbitrary location without coordinate
                    let locationItem = LocationItem(locationName: searchText)
                    self.searchResultLocations.insert(locationItem, at: 0)
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    private func showSearchBarActivityIndicator(_ visible: Bool) {
        func textField() -> UITextField? {
            let subViews = searchBar.subviews.flatMap { $0.subviews }
            guard let textField = (subViews.filter { $0 is UITextField }).first as? UITextField else {
                return nil
            }
            return textField
        }
        
        func activityIndicator() -> UIActivityIndicatorView? {
            return textField()?.leftView?.subviews.compactMap{ $0 as? UIActivityIndicatorView }.first
        }
        
        if visible {
            if activityIndicator() == nil {
                let newActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                newActivityIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                newActivityIndicator.startAnimating()
                newActivityIndicator.backgroundColor = UIColor.white
                textField()?.leftView?.addSubview(newActivityIndicator)
                let leftViewSize = textField()?.leftView?.frame.size ?? CGSize.zero
                newActivityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
            }
        }
        else {
            activityIndicator()?.removeFromSuperview()
        }
    }
    
}


// MARK: Table View Delegate and Data Source

extension LocationPicker: UITableViewDelegate, UITableViewDataSource {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var searchBarOffsetY: CGFloat = scrollView.contentOffset.y + scrollView.contentInset.top

        if scrollView.contentOffset.y < -scrollView.contentInset.top {
            searchBarOffsetY = 0.0
        }
        
        searchBarTopConstraint.constant = -searchBarOffsetY
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return searchResultLocations.count > 0 ? searchResultSectionTitle : nil
        case 1:
            return currentLocationSectionTitle
        default:
            return alternativeLocationCount > 0 ? alternativeLocationsSectionTitle : nil
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return searchResultLocations.count > 0 ? 40.0 : 0.01
        case 1:
            return 40.0
        default:
            return alternativeLocationCount > 0 ? 40.0 : 0.01
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return searchResultLocations.count
        case 1:
            return 1
        default:
            return alternativeLocationCount
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: LocationCell!
        
        switch indexPath.section {
        case 0:
            cell = LocationCell(locationType: .searchLocation, locationItem: searchResultLocations[indexPath.row])
            cell.iconView.image = searchResultLocationIcon ?? StyleKit.imageOfSearchIcon(size: defaultIconSize, resizing: defaultIconResizingBehaviour, color: searchResultLocationIconColor)
            cell.iconView.tintColor = searchResultLocationIconColor
        case 1:
            cell = LocationCell(locationType: .currentLocation, locationItem: nil)
            cell.locationNameLabel.text = currentLocationText
            cell.iconView.image = currentLocationIcon ?? StyleKit.imageOfMapPointerIcon(size: defaultIconSize, resizing: defaultIconResizingBehaviour, color: currentLocationIconColor)
            cell.iconView.tintColor = currentLocationIconColor
        default:
            let locationItem = (alternativeLocations?[indexPath.row] ?? dataSource?.alternativeLocation(at: indexPath.row))!
            cell = LocationCell(locationType: .alternativeLocation, locationItem: locationItem)
            cell.iconView.image = alternativeLocationIcon ?? StyleKit.imageOfPinIcon(size: defaultIconSize, resizing: defaultIconResizingBehaviour, color: alternativeLocationIconColor)
            cell.iconView.tintColor = alternativeLocationIconColor
        }
        
        cell.backgroundColor = .white
        cell.iconView.contentMode = .center
        
        cell.locationNameLabel.textColor = primaryTextColor
        cell.locationAddressLabel.textColor = secondaryTextColor
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        longitudinalDistance = defaultLongitudinalDistance
        
        if indexPath.section == 1 {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied:
                locationDidDeny(locationPicker: self)
                tableView.deselectRow(at: indexPath, animated: true)
            default:
                break
            }
            
            if let currentLocation = locationManager.location {
                reverseGeocodeLocation(currentLocation)
            }
        }
        else {
            let cell = tableView.cellForRow(at: indexPath) as! LocationCell
            let locationItem = cell.locationItem!
            let coordinate = locationItem.coordinate
            if (coordinate != nil && self.isForceReverseGeocoding) {
                reverseGeocodeLocation(CLLocation(latitude: coordinate!.latitude, longitude: coordinate!.longitude))
            } else {
                selectLocationItem(locationItem)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isAlternativeLocationEditable && indexPath.section == 2
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! LocationCell
            let locationItem = cell.locationItem!
            alternativeLocations?.remove(at: indexPath.row)
            alternativeLocationDidDelete(locationItem: locationItem)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
}


// MARK: Map View Delegate

extension LocationPicker: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if !animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                self.pinView.frame.origin.y -= self.pinViewImageHeight / 2
                }, completion: nil)
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        longitudinalDistance = getLongitudinalDistance(fromMapRect: mapView.visibleMapRect)
        if isMapViewCenterChanged {
            isMapViewCenterChanged = false
            if #available(iOS 10, *) {
                let coordinate = mapView.centerCoordinate
                reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            } else {
                let adjustedCoordinate = gcjToWgs(coordinate: mapView.centerCoordinate)
                reverseGeocodeLocation(CLLocation(latitude: adjustedCoordinate.latitude, longitude: adjustedCoordinate.longitude))
            }
        }
        
        if !animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                self.pinView.frame.origin.y += self.pinViewImageHeight / 2
                }, completion: nil)
        }
    }
    
}


// MARK: Location Manager Delegate

extension LocationPicker: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
 
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (tableView.indexPathForSelectedRow as NSIndexPath?)?.section == 1 {
            let currentLocation = locations[0]
            reverseGeocodeLocation(currentLocation)
            guard #available(iOS 9.0, *) else {
                locationManager.stopUpdatingLocation()
                return
            }
        }
    }
    
}

//
// Custom view used as mapView header view
//

class MapViewHeaderView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: 11.0, weight: .medium)
        }
        else {
            label.font = UIFont.systemFont(ofSize: 11)
        }
        label.text = title
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .gray
        label.adjustsFontSizeToFitWidth = true
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        }
        else {
            label.font = UIFont.systemFont(ofSize: 14)
        }
        label.text = subtitle
        return label
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        if let activityIndicatorColor = activityIndicatorColor {
            view.color = activityIndicatorColor
        }
        return view
    }()
    
    fileprivate func makeSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        if #available(iOS 9, *) {
            view.heightAnchor.constraint(equalToConstant: 0.7).isActive = true
        }
        else {
            NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0.7).isActive = true
        }
        return view
    }
    
    fileprivate func makeBlurView() -> UIView {
        var blur: UIBlurEffect!
        if #available(iOS 10.0, *) {
            blur = UIBlurEffect(style: UIBlurEffectStyle.light) //prominent,regular,extraLight, light, dark
        } else {
            blur = UIBlurEffect(style: UIBlurEffectStyle.extraLight) //extraLight, light, dark
        }
        
        let view: UIView!
        
        if #available(iOS 10.0, *) {
            view = UIVisualEffectView(effect: blur)
            view.backgroundColor = bgColor.withAlphaComponent(0.8)
        }
        else {
            view = UIView()
            view.backgroundColor = bgColor
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }

    fileprivate var bgColor: UIColor!
    fileprivate var separatorColor: UIColor!
    fileprivate var activityIndicatorColor: UIColor?
    fileprivate var title: String!
    fileprivate var subtitle: String?

    init(title: String, subtitle: String? = " ", backgroundColor: UIColor = .white, separatorColor: UIColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0), activityIndicatorColor: UIColor? = nil) {
        super.init(frame: .zero)
        self.title = title
        self.subtitle = subtitle
        self.bgColor = backgroundColor
        self.separatorColor = separatorColor
        self.activityIndicatorColor = activityIndicatorColor
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        self.backgroundColor = .clear //bgColor
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let blurView = makeBlurView()
        let topSeparatorView = makeSeparatorView()
        let bottomSeparatorView = makeSeparatorView()
        
        self.addSubview(blurView)
        self.addSubview(topSeparatorView)
        self.addSubview(bottomSeparatorView)
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(activityIndicatorView)
  
        if #available(iOS 9, *) {
            blurView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            
            topSeparatorView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            topSeparatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            topSeparatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 6.0).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5.0).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5.0).isActive = true
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1.0).isActive = true
            subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5.0).isActive = true
            subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5.0).isActive = true
            subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5.0).isActive = true
            
            activityIndicatorView.centerXAnchor.constraint(equalTo: subtitleLabel.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: subtitleLabel.centerYAnchor).isActive = true
      
            bottomSeparatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            bottomSeparatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            bottomSeparatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        else {
            NSLayoutConstraint(item: blurView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: blurView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: blurView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: blurView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0.0).isActive = true
            
            NSLayoutConstraint(item: topSeparatorView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: topSeparatorView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: topSeparatorView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 6.0).isActive = true
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 5.0).isActive = true
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -5.0).isActive = true
            
            NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 1.0).isActive = true
            NSLayoutConstraint(item: subtitleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 5.0).isActive = true
            NSLayoutConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -5.0).isActive = true
            NSLayoutConstraint(item: subtitleLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -5.0).isActive = true
            
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: subtitleLabel, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: subtitleLabel, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
  
            NSLayoutConstraint(item: bottomSeparatorView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0.0).isActive = true
            NSLayoutConstraint(item: bottomSeparatorView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0.0).isActive = true
            NSLayoutConstraint(item: bottomSeparatorView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0.0).isActive = true
        }
        
        titleLabel.text = title
    }
    
    func setSubtitleText(_ text: String?) {
        subtitleLabel.text = text
    }
    
    var isActivityIndicatorActive: Bool {
        get {
            return activityIndicatorView.isAnimating
        }
        
        set {
            newValue ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
            subtitleLabel.alpha = newValue ? 0.0 : 1.0
        }
    }
    
}
