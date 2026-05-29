//
//  EditSplitControl.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/29/26.
//

private let DIVIDER_WIDTH: CGFloat = 1.5
private let DIVIDER_EXTENT: CGFloat = 16
private let DIVIDER_DRAG_RANGE: CGFloat = 16
private let BUTTON_SIZE: CGSize = CGSize(width: 24, height: 24)
private let BUTTON_SPACING: CGFloat = 32

class EditSplitControl: UIViewPointSubview {
    private var removeViews: [EditSplitDeletor] = []
    private let holdRemoveView = UIViewPointSubview()
    
    private let splitView = UIViewPointSubview()
    private let splitDivider = EditSplitDivider()
    private let splitButton = UIView()
    
    weak var segmentStack: UIStackView?
    
    private var beginPosition: CGFloat = 0
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setup()
        noti()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateControl()
    }
}

extension EditSplitControl {
    private func setup() {
        addSubview(holdRemoveView)
        holdRemoveView.addConstraintFitBoundsTo(self)
        
        addSubview(splitView)
        splitView.addConstraintFitBoundsTo(self)
        splitView.addSubview(splitDivider)
        splitView.addSubview(splitButton)
        
        splitButton.addSubview(UIView())
        splitButton.addSubview(UIImageView())
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: cEdit.getMode() == .vel ? -10000 : DIVIDER_DRAG_RANGE,
                              y: cEdit.getMode() == .hoz ? -10000 : DIVIDER_DRAG_RANGE))
        path.addLine(to: CGPoint(x: cEdit.getMode() == .vel ? 10000 : DIVIDER_DRAG_RANGE,
                                 y: cEdit.getMode() == .hoz ? 10000 : DIVIDER_DRAG_RANGE))
        
        splitDivider.layer.path = path.cgPath
            .copy(dashingWithPhase: .zero, lengths: [2, 2])
            .copy(strokingWithWidth: DIVIDER_WIDTH, lineCap: .round, lineJoin: .round, miterLimit: .pi)
        splitDivider.layer.fillColor = ._primary
        splitDivider.clipsToBounds = true
        splitDivider.gestureRecognizers = [
            UIPanGestureRecognizer(target: self, action: #selector(move))
        ]
    }
}

extension EditSplitControl {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateControl), name: CSplit.splitUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateControl), name: CEdit.controlUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateControl), name: CEdit.scrollUpdate, object: nil)
        
        updateControl()
    }
    
    @objc private func updateControl(_ noti: Notification? = nil) {
        guard let stack = segmentStack else { return }
        
        func update() {
//            holdRemoveView.alpha = cEdit.getTab() == .delete ? 1 : 0
//            splitView.alpha = cEdit.getTab() == .split ? 1 : 0
            
            let oldCount = removeViews.count
            let removeCounts = cEdit.getSegments().count
            
            if oldCount < removeCounts {
                for _ in oldCount..<removeCounts {
                    let removeView = EditSplitDeletor()
                    removeViews.append(removeView)
                    holdRemoveView.addSubview(removeView)
                }
            }
            
            if oldCount > removeCounts {
                for _ in removeCounts..<oldCount {
                    removeViews.last?.removeFromSuperview()
                    removeViews.removeLast()
                }
            }
            
            for (index, view) in stack.arrangedSubviews.enumerated() {
                guard removeViews.indices.contains(index),
                      let view = view as? EditItem,
                      let segment = view.segment
                else { continue }
                
                let removeView = removeViews[index]
                
                removeView.frame = view.convert(view.bounds, to: holdRemoveView)
                removeView.segmentStack = segmentStack
                removeView.update(segment)
            }
            
            let rect = stack.convert(stack.bounds, to: self)
            let position = cSplit.getSplitPosition()
            
            splitDivider.frame = CGRect(x: cEdit.getMode() == .hoz ? (rect.width * position - DIVIDER_DRAG_RANGE + rect.minX) : rect.minX,
                                        y: cEdit.getMode() == .vel ? (rect.height * position - DIVIDER_DRAG_RANGE + rect.minY) : rect.minY,
                                        width: cEdit.getMode() == .hoz ? (DIVIDER_DRAG_RANGE * 2) : (rect.width + DIVIDER_EXTENT),
                                        height: cEdit.getMode() == .vel ? (DIVIDER_DRAG_RANGE * 2) : (rect.height + DIVIDER_EXTENT))
            
            let centerSpacing = BUTTON_SPACING + BUTTON_SIZE.width / 2
            
            splitButton.frame.size = BUTTON_SIZE * 1.5
            splitButton.center = CGPoint(x: cEdit.getMode() == .vel ? (rect.maxX + centerSpacing) : splitDivider.frame.midX,
                                         y: cEdit.getMode() == .hoz ? (rect.maxY + centerSpacing) : splitDivider.frame.midY)
            
            splitButton.gestureRecognizers = splitAble() ? [
                UITapGestureRecognizer(target: self, action: #selector(split))
            ] : []
            
            guard let backB = splitButton.subviews.first(where: { !($0 is UIImageView) }),
                  let iconB = splitButton.subviews.first(where: { $0 is UIImageView }) as? UIImageView
            else { return }
            
            backB.frame.size = BUTTON_SIZE
            backB.center = splitButton.bounds.mid
            backB.layer.cornerRadius = BUTTON_SIZE.width / 2
            backB.backgroundColor = splitAble() ? ._primary : ._primary15
            
            iconB.image = UIImage.cut
            iconB.frame.size = BUTTON_SIZE * 2 / 3
            iconB.center = splitButton.bounds.mid
            iconB.tintColor = ._white
        }
        
        if noti?.name == CEdit.scrollUpdate || noti?.name == CSplit.splitUpdate {
            update()
        } else {
            UIView.animate(withDuration: Defaults.ANIM_DURATION, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseInOut]) {
                
                update()
            }
        }
    }
    
    @objc private func move(g: UIPanGestureRecognizer) {
        if g.state == .began {
            beginPosition = cSplit.getSplitPosition()
        }
        
        guard let stack = segmentStack else { return }
        
        if cEdit.getMode() == .vel {
            cSplit.setSplitPosition(beginPosition + g.translation(in: stack).y / stack.bounds.height)
        } else {
            cSplit.setSplitPosition(beginPosition + g.translation(in: stack).x / stack.bounds.width)
        }
    }
    
    @objc private func split() {
        guard let stack = segmentStack else {
            return
        }
        
        for view in stack.arrangedSubviews {
            let mid = splitDivider.convert(splitDivider.bounds.mid, to: view)
            
            guard let view = view as? EditItem,
                  let segment = view.segment
            else { continue }
            
            if view.bounds.contains(mid) {
                cEdit.setSplit(at: cEdit.getMode() == .hoz ? (mid.x / view.bounds.width) : (mid.y / view.bounds.height), of: segment)
                return
            }
        }
    }
    
    private func splitAble() -> Bool {
        guard let stack = segmentStack else {
            return false
        }
        
        for view in stack.arrangedSubviews {
            let delta = Defaults.MIN_DELTA
            
            if (Defaults.RECT_0011.insetBy(dx: delta, dy: delta) * view.bounds.size)
                .contains(splitDivider.convert(splitDivider.bounds.mid, to: view)) {
                return true
            }
        }
        
        return false
    }
}

class EditSplitDeletor: UIViewPointSubview {
    private var buttonViews: [UIView] = []
    private var highlightViews: [UIView] = []
    
    private let lowButton = UIView()
    private let lowHighlight = UIView()
    private let highButton = UIView()
    private let highHighlight = UIView()
    
    fileprivate weak var segmentStack: UIStackView?
    
    private weak var segment: Segment?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        addSubview(lowButton)
        lowButton.addSubview(UIView())
        lowButton.addSubview(UIImageView())
        addSubview(lowHighlight)
        lowHighlight.addSubview(UIView())
        lowHighlight.addSubview(UIView())
        addSubview(highButton)
        highButton.addSubview(UIView())
        highButton.addSubview(UIImageView())
        addSubview(highHighlight)
        highHighlight.addSubview(UIView())
        highHighlight.addSubview(UIView())
    }
    
    func update(_ segment: Segment) {
        self.segment = segment
        
        for type in SegmentRemoveType.allCases {
            var imageSize: CGSize
            
            if cEdit.getMode() == .hoz {
                let imageHeight = bounds.size.height / segment.getFrame().height
                imageSize = segment.getImageSize() * imageHeight / segment.getImageSize().height
            } else {
                let imageWidth = bounds.size.width / segment.getFrame().width
                imageSize = segment.getImageSize() * imageWidth / segment.getImageSize().width
            }
            
            let imagePosi = segment.getFrame().origin * imageSize * -1
            
            let removeFrame = segment.getRemove(type: type).intersection(segment.getFrame())
            let rect = CGRect(origin: imagePosi + (removeFrame.origin * imageSize),
                              size: removeFrame.size * imageSize)
            
            let highlightView = type == .low ? lowHighlight : highHighlight
            
            highlightView.frame = rect
            highlightView.backgroundColor = ._red15
            highlightView.isUserInteractionEnabled = false
            highlightView.alpha = segment.contains(removeFrame) ? 1 : 0
            
            let topDivider = highlightView.subviews[0]
            topDivider.backgroundColor = ._red
            topDivider.isUserInteractionEnabled = false
            topDivider.frame = CGRect(x: 0, y: 0,
                                      width: cEdit.getMode() == .vel ? rect.width : DIVIDER_WIDTH,
                                      height: cEdit.getMode() == .hoz ? rect.height : DIVIDER_WIDTH)
            
            let bottomDivider = highlightView.subviews[1]
            bottomDivider.backgroundColor = ._red
            bottomDivider.isUserInteractionEnabled = false
            bottomDivider.frame = CGRect(x: cEdit.getMode() == .vel ? 0 : (rect.width - DIVIDER_WIDTH),
                                         y: cEdit.getMode() == .hoz ? 0 : (rect.height - DIVIDER_WIDTH),
                                         width: cEdit.getMode() == .vel ? rect.width : DIVIDER_WIDTH,
                                         height: cEdit.getMode() == .hoz ? rect.height : DIVIDER_WIDTH)
            
            let centerSpacing = BUTTON_SPACING + BUTTON_SIZE.width / 2
            
            let button = type == .low ? lowButton : highButton
            button.frame.size = BUTTON_SIZE * 1.5
            button.center = CGPoint(x: cEdit.getMode() == .vel ? (rect.minX - centerSpacing) : rect.midX,
                                    y: cEdit.getMode() == .hoz ? (rect.minY - centerSpacing) : rect.midY)
            button.alpha = segment.contains(removeFrame) ? 1 : 0
            
            button.gestureRecognizers = [
                UITapGestureRecognizer(target: self, action: #selector(remove))
            ]
            
            guard let backB = button.subviews.first(where: { !($0 is UIImageView) }),
                  let iconB = button.subviews.first(where: { $0 is UIImageView }) as? UIImageView
            else { continue }
            
            backB.frame.size = BUTTON_SIZE
            backB.center = button.bounds.mid
            backB.layer.cornerRadius = BUTTON_SIZE.width / 2
            backB.backgroundColor = ._red
            
            iconB.image = UIImage.delete
            iconB.frame.size = BUTTON_SIZE * 2 / 3
            iconB.center = button.bounds.mid
            iconB.tintColor = ._white
        }
    }
    
    @objc private func remove(_ g: UITapGestureRecognizer) {
        guard let view = g.view,
              let segment = segment
        else { return }
        
        cEdit.setRemove(type: view == lowButton ? .low : .high, of: segment)
    }
}

class EditSplitDivider: UIView {
    override final class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override var layer: CAShapeLayer {
        return super.layer as! CAShapeLayer
    }
}
