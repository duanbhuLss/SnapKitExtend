//
//  SnapKitExtend
//
//  MIT License
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
//
//  Created by charles on 2017/8/2.
//  Copyright © 2017年 charles. All rights reserved.
//

import SnapKit

public enum ConstraintAxis: Int {
    case horizontal
    case vertical
}

#if os(iOS) || os(tvOS)
import UIKit
public typealias ConstraintEdgeInsets = UIEdgeInsets
#else
import AppKit
extension NSEdgeInsets {
    public static let zero = NSEdgeInsetsZero
}
public typealias ConstraintEdgeInsets = NSEdgeInsets


#endif

public struct ConstraintArrayDSL {
    @discardableResult
    public func prepareConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> [Constraint] {
        var constraints = Array<Constraint>()
        for view in self.array {
            constraints.append(contentsOf: view.snp.prepareConstraints(closure))
        }
        return constraints
    }
    
    public func makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.makeConstraints(closure)
        }
    }
    
    public func remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.remakeConstraints(closure)
        }
    }
    
    public func updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.updateConstraints(closure)
        }
    }
    
    public func removeConstraints() {
        for view in self.array {
            view.snp.removeConstraints()
        }
    }
    
    /// distribute with fixed spacing
    ///
    /// - Parameters:
    ///   - axisType: which axis to distribute items along
    ///   - fixedSpacing: the spacing between each item
    ///   - leadSpacing: the spacing before the first item and the container
    ///   - tailSpacing: the spacing after the last item and the container
    public func distributeViewsAlong(axisType: ConstraintAxis, fixedSpacing: CGFloat = 0, leadSpacing: CGFloat = 0, tailSpacing: CGFloat = 0) {
        
        guard self.array.count > 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        if axisType == .horizontal {
            var prev: ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints({ (make) in
                    guard let prev = prev else {//first one
                        make.left.equalTo(tempSuperView).offset(leadSpacing)
                        return
                    }
                    make.width.equalTo(prev)
                    make.left.equalTo(prev.snp.right).offset(fixedSpacing)
                    if (i == self.array.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(-tailSpacing)
                    }
                })
                prev = v;
            }
        }else {
            var prev: ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints({ (make) in
                    guard let prev = prev else {//first one
                        make.top.equalTo(tempSuperView).offset(leadSpacing);
                        return
                    }
                    make.height.equalTo(prev)
                    make.top.equalTo(prev.snp.bottom).offset(fixedSpacing)
                    if (i == self.array.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                })
                prev = v;
            }
        }
    }
    
    /// distribute with fixed item size
    ///
    /// - Parameters:
    ///   - axisType: which axis to distribute items along
    ///   - fixedItemLength: the fixed length of each item
    ///   - leadSpacing: the spacing before the first item and the container
    ///   - tailSpacing: the spacing after the last item and the container
    public func distributeViewsAlong(axisType: ConstraintAxis, fixedItemLength: CGFloat = 0, leadSpacing: CGFloat = 0, tailSpacing: CGFloat = 0) {
        
        guard self.array.count > 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        if axisType == .horizontal {
            var prev : ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints({ (make) in
                    make.width.equalTo(fixedItemLength)
                    if prev != nil {
                        if (i == self.array.count - 1) {//last one
                            make.right.equalTo(tempSuperView).offset(-tailSpacing);
                        } else {
                            let offset = (CGFloat(1) - (CGFloat(i) / CGFloat(self.array.count - 1))) *
                                (fixedItemLength + leadSpacing) -
                                CGFloat(i) * tailSpacing / CGFloat(self.array.count - 1)
                            make.right.equalTo(tempSuperView).multipliedBy(CGFloat(i) / CGFloat(self.array.count - 1)).offset(offset)
                        }
                    }else {//first one
                        make.left.equalTo(tempSuperView).offset(leadSpacing);
                    }
                })
                prev = v;
            }
        }else {
            var prev : ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints({ (make) in
                    make.height.equalTo(fixedItemLength)
                    if prev != nil {
                        if (i == self.array.count - 1) {//last one
                            make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                        }else {
                            let offset = (CGFloat(1) - (CGFloat(i) / CGFloat(self.array.count - 1))) *
                                (fixedItemLength + leadSpacing) -
                                CGFloat(i) * tailSpacing / CGFloat(self.array.count - 1)
                            make.bottom.equalTo(tempSuperView).multipliedBy(CGFloat(i) / CGFloat(self.array.count-1)).offset(offset)
                        }
                    }else {//first one
                        make.top.equalTo(tempSuperView).offset(leadSpacing);
                    }
                })
                prev = v;
            }
        }
    }
    
    /// distribute Sudoku with fixed item size
    ///
    /// - Parameters:
    ///   - fixedItemWidth: the fixed width of each item
    ///   - fixedItemLength: the fixed length of each item
    ///   - warpCount: the warp count in the super container
    ///   - edgeInset: the padding in the super container
    public func distributeSudokuViews(fixedItemWidth: CGFloat, fixedItemHeight: CGFloat, warpCount: Int, edgeInset: ConstraintEdgeInsets = .zero) {
        
        guard self.array.count > 1, warpCount >= 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        let remainder = self.array.count % warpCount
        let quotient = self.array.count / warpCount
        
        let rowCount = (remainder == 0) ? quotient : (quotient + 1)
        let columnCount = warpCount
        
        for (i,v) in self.array.enumerated() {
            
            let currentRow = i / warpCount
            let currentColumn = i % warpCount
            
            v.snp.makeConstraints({ (make) in
                make.width.equalTo(fixedItemWidth)
                make.height.equalTo(fixedItemHeight)
                if currentRow == 0 {//fisrt row
                    make.top.equalTo(tempSuperView).offset(edgeInset.top)
                }
                if currentRow == rowCount - 1 {//last row
                    make.bottom.equalTo(tempSuperView).offset(-edgeInset.bottom)
                }
                
                if currentRow != 0 && currentRow != rowCount - 1 {//other row
                    let offset = (CGFloat(1) - CGFloat(currentRow) / CGFloat(rowCount - 1)) *
                        (fixedItemHeight + edgeInset.top) -
                        CGFloat(currentRow) * edgeInset.bottom / CGFloat(rowCount - 1)
                    make.bottom.equalTo(tempSuperView).multipliedBy(CGFloat(currentRow) / CGFloat(rowCount - 1)).offset(offset);
                }
                
                if currentColumn == 0 {//first col
                    make.left.equalTo(tempSuperView).offset(edgeInset.left)
                }
                if currentColumn == columnCount - 1 {//last col
                    make.right.equalTo(tempSuperView).offset(-edgeInset.right)
                }
                
                if currentColumn != 0 && currentColumn != columnCount - 1 {//other col
                    let offset = (CGFloat(1) - CGFloat(currentColumn) / CGFloat(columnCount - 1)) *
                        (fixedItemWidth + edgeInset.left) -
                        CGFloat(currentColumn) * edgeInset.right / CGFloat(columnCount - 1)
                    make.right.equalTo(tempSuperView).multipliedBy(CGFloat(currentColumn) / CGFloat(columnCount - 1)).offset(offset);
                }
            })
        }
    }
    
    /// distribute Sudoku with fixed item spacing
    ///
    /// - Parameters:
    ///   - fixedLineSpacing: the line spacing between each item
    ///   - fixedInteritemSpacing: the Interitem spacing between each item
    ///   - warpCount: the warp count in the super container
    ///   - edgeInset: the padding in the super container
    public func distributeSudokuViews(fixedLineSpacing: CGFloat, fixedInteritemSpacing: CGFloat, warpCount: Int, edgeInset: ConstraintEdgeInsets = .zero) {
        
        guard self.array.count > 1, warpCount >= 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        let remainder = self.array.count % warpCount
        let quotient = self.array.count / warpCount
        
        let rowCount = (remainder == 0) ? quotient : (quotient + 1)
        let columnCount = warpCount
        
        
        var prev: ConstraintView?
        
        for (i,v) in self.array.enumerated() {
            
            let currentRow = i / warpCount
            let currentColumn = i % warpCount
            
            v.snp.makeConstraints({ (make) in
                guard let prev = prev else {//first row & first col
                    make.top.equalTo(tempSuperView).offset(edgeInset.top)
                    make.left.equalTo(tempSuperView).offset(edgeInset.left)
                    return
                }
                make.width.height.equalTo(prev)
                //最后一行
                if currentRow == rowCount - 1 {//last row
                    if currentRow != 0 && i - columnCount >= 0 {//just one row
                        make.top.equalTo(self.array[i-columnCount].snp.bottom).offset(fixedLineSpacing)
                    }
                    make.bottom.equalTo(tempSuperView).offset(-edgeInset.bottom)
                }
                //中间行
                if currentRow != 0 && currentRow != rowCount - 1 {//other row
                    make.top.equalTo(self.array[i-columnCount].snp.bottom).offset(fixedLineSpacing);
                }
                //最后一列
                if currentColumn == warpCount - 1 {//last col
                    if currentColumn != 0 {//just one line
                        make.left.equalTo(prev.snp.right).offset(fixedInteritemSpacing)
                    }
                    make.right.equalTo(tempSuperView).offset(-edgeInset.right)
                }
                //中间列
                if currentColumn != 0 && currentColumn != warpCount - 1 {//other col
                    make.left.equalTo(prev.snp.right).offset(fixedInteritemSpacing);
                }
                
                if currentRow == 0 {
                    make.top.equalTo(tempSuperView).offset(edgeInset.top);
                }
                
                if currentColumn == 0 {
                    make.left.equalTo(tempSuperView).offset(edgeInset.left);
                }
            })
            prev = v
        }
    }
    
    public func distributeSudokuViewsReverse(fixedLineSpacing: CGFloat, fixedInteritemSpacing: CGFloat, warpCount: Int, edgeInset: ConstraintEdgeInsets = .zero) {
        
        guard self.array.count > 1, warpCount >= 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        let remainder = self.array.count % warpCount
        let quotient = self.array.count / warpCount
        
        let rowCount = (remainder == 0) ? quotient : (quotient + 1)
        
        var prev: ConstraintView?
        
        for (i,v) in self.array.enumerated() {
            
            let currentRow = i / warpCount
            let currentColumn = i % warpCount
            
            v.snp.makeConstraints({ (make) in
                guard let prev = prev else {//first row & first col
                    make.top.equalTo(tempSuperView).offset(edgeInset.top)
                    make.right.equalTo(tempSuperView).offset(-edgeInset.right)
                    return
                }
                make.width.height.equalTo(prev)
                if currentRow == rowCount - 1 {//last row
                    if currentRow != 0 && i - warpCount >= 0 {//just one row
                        make.top.equalTo(self.array[i-warpCount].snp.bottom).offset(fixedLineSpacing)
                    }
                    make.bottom.equalTo(tempSuperView).offset(-edgeInset.bottom)
                }
                
                if currentRow != 0 && currentRow != rowCount - 1 {//other row
                    make.top.equalTo(self.array[i-warpCount].snp.bottom).offset(fixedLineSpacing);
                }
                if currentColumn == warpCount - 1 {//last col
                    if currentColumn != 0 {//just one line
                        make.right.equalTo(prev.snp.left).offset(-fixedInteritemSpacing)
                    }
                    make.left.equalTo(tempSuperView).offset(edgeInset.left)
                }
                
                if currentColumn != 0 && currentColumn != warpCount - 1 {//other col
                    make.right.equalTo(prev.snp.left).offset(-fixedInteritemSpacing);
                }
                
                if currentRow == 0 {
                    make.top.equalTo(tempSuperView).offset(edgeInset.top);
                }
                
                if currentRow == rowCount - 1 {
                    make.right.equalTo(tempSuperView).offset(-edgeInset.right)
                }
            })
            prev = v
        }
    }
    ///distribute line with flexible width item spacing
    public func distributeViewsHorizontal(fixedSpacing: CGFloat, leadSpacing: CGFloat, tailSpacing: CGFloat, isReverse: Bool) {

        guard self.array.count > 1 else {
            if array.count == 1 {
                array[0].snp.makeConstraints { (make) in
                    make.left.equalToSuperview().offset(leadSpacing);
                    make.right.equalToSuperview().offset(-tailSpacing);
                }
            }
            return
        }

        let list = isReverse == false ? array : array.reversed()

        var prev: ConstraintView?
        for (_, v) in list.enumerated() {
            v.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()

                if isReverse == false {
                    if prev == nil {
                         make.left.equalToSuperview().offset(leadSpacing)
                     } else {
                         make.left.equalTo(prev!.snp.right).offset(fixedSpacing)
                     }
                } else {
                    if prev == nil {
                        make.right.equalToSuperview().offset(-tailSpacing)
                    } else {
                        make.right.equalTo(prev!.snp.left).offset(-fixedSpacing)
                    }
                }
            }
            prev = v
        }
    }
    
    public func distributeViewsVertical(top: CGFloat = 0, leading: CGFloat = 0, fixedSpacing: CGFloat, width: CGFloat? = nil, height: CGFloat, isAutoAdaptSuperview: Bool = false, insetsBottom: CGFloat = 0) {
        var prev: UIView? = nil
        for view in array {
            view.snp.makeConstraints { make in
                make.leading.equalTo(leading)
                if let width = width {
                    make.width.equalTo(width)
                } else {
                    make.centerX.equalToSuperview()
                }
                make.height.equalTo(height)
                guard let prev = prev else {
                    make.top.equalTo(top)
                    return
                }
                make.top.equalTo(prev.snp.bottom).offset(fixedSpacing)
            }
        }
        guard let prev = prev, isAutoAdaptSuperview else { return }
        prev.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-insetsBottom)
        }
    }
    
    internal let array: Array<ConstraintView>
    
    internal init(array: Array<ConstraintView>) {
        self.array = array
    }
    
}

public extension Array {
    var snp: ConstraintArrayDSL {
        return ConstraintArrayDSL(array: self as! Array<ConstraintView>)
    }
}

private extension ConstraintArrayDSL {
    func commonSuperviewOfViews() -> ConstraintView? {
        var commonSuperview : ConstraintView?
        var previousView : ConstraintView?
        
        for view in self.array {
            if previousView != nil {
                commonSuperview = view.closestCommonSuperview(commonSuperview)
            }else {
                commonSuperview = view
            }
            previousView = view
        }
        
        return commonSuperview
    }
}

private extension ConstraintView {
    func closestCommonSuperview(_ view : ConstraintView?) -> ConstraintView? {
        var closestCommonSuperview: ConstraintView?
        var secondViewSuperview: ConstraintView? = view
        while closestCommonSuperview == nil && secondViewSuperview != nil {
            var firstViewSuperview: ConstraintView? = self
            while closestCommonSuperview == nil && firstViewSuperview != nil {
                if secondViewSuperview == firstViewSuperview {
                    closestCommonSuperview = secondViewSuperview
                }
                firstViewSuperview = firstViewSuperview?.superview
            }
            secondViewSuperview = secondViewSuperview?.superview
        }
        return closestCommonSuperview
    }
}
