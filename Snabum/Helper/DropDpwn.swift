//
//  DropDpwn.swift
//  Snabum
//
//  Created by mac on 08/10/2025.
//

import UIKit

final class DropdownMenu: UIView {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var items: [String] = []
    private var onSelect: ((Int, String) -> Void)?
    private let cellHeight: CGFloat = 44
    private let maxHeight: CGFloat = 300
    private var contentWidth: CGFloat = 200

    // MARK: - Init
    init(items: [String], width: CGFloat = 200) {
        super.init(frame: .zero)
        self.items = items
        self.contentWidth = width
        setupViews()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        // overlay
        backgroundColor = UIColor.black.withAlphaComponent(0.15)
       

        // container for the list
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = true
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
        addSubview(tableView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        tap.cancelsTouchesInView = true
        self.superview?.addGestureRecognizer(tap)
    }

    // MARK: - Show / Dismiss
    /// Show the dropdown anchored to `anchorView`. `inView` is usually `self.view`.
    func show(from anchorView: UIView, inView parentView: UIView, onSelect: @escaping (Int, String) -> Void) {
        self.onSelect = onSelect
        self.frame = parentView.bounds
        parentView.addSubview(self)

        // Convert anchor frame to parent coords
        let anchorFrame = anchorView.convert(anchorView.bounds, to: parentView)

        // Compute table frame
        let width = contentWidth
        let height = min(CGFloat(items.count) * cellHeight, maxHeight)
        let x = max(10, anchorFrame.midX - width / 2)
        // Prefer showing below anchor; if not enough space, show above it.
        let spaceBelow = parentView.bounds.height - anchorFrame.maxY - parentView.safeAreaInsets.bottom
        let spaceAbove = anchorFrame.minY - parentView.safeAreaInsets.top
        let y: CGFloat
        if spaceBelow >= height + 8 {
            y = anchorFrame.maxY + 8
        } else if spaceAbove >= height + 8 {
            y = anchorFrame.minY - 8 - height
        } else {
            // fallback: fit into available space below or above
            let availableBelow = max(0, spaceBelow - 8)
            let availableAbove = max(0, spaceAbove - 8)
            if availableBelow >= availableAbove {
                let h = min(height, availableBelow)
                y = anchorFrame.maxY + 8
                tableView.frame = CGRect(x: x, y: y, width: width, height: h)
                animateIn()
                return
            } else {
                let h = min(height, availableAbove)
                y = anchorFrame.minY - 8 - h
                tableView.frame = CGRect(x: x, y: y, width: width, height: h)
                animateIn()
                return
            }
        }

        tableView.frame = CGRect(x: x, y: y, width: width, height: height)
        animateIn()
    }

    @objc private func dismissSelf() {
        animateOut { [weak self] in
            self?.removeFromSuperview()
        }
    }

    private func animateIn() {
        tableView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        tableView.alpha = 0
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.tableView.alpha = 1
            self.tableView.transform = .identity
        })
    }

    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.14, animations: {
            self.tableView.alpha = 0
            self.tableView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in completion() })
    }
}

// MARK: - UITableViewDataSource / Delegate
extension DropdownMenu: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { cellHeight }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        c.textLabel?.text = items[indexPath.row]
        c.textLabel?.font = UIFont.systemFont(ofSize: 15)
        c.selectionStyle = .none
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect?(indexPath.row, items[indexPath.row])
        dismissSelf()
    }
}
