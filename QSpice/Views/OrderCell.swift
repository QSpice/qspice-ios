import UIKit

class OrderCell: UITableViewCell {

    static let reuseId = "OrderCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "09/07/18"
        label.font = Fonts.cStdMedium?.withSize(14.0)
        label.textColor = Colors.lightGrey
        
        return label
    }()
    
    let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Order"
        label.font = Fonts.cStdMedium?.withSize(16.0)
        return label
    }()
    
    let quantityLabel: UILabel = {
        let label = UILabel()
        label.text = "Quantity: 1"
        label.font = Fonts.cStdBook?.withSize(14.0)
        label.textColor = Colors.darkGrey
        return label
    }()
    
    let orderLabel: UILabel = {
        let label = UILabel()
        label.text = "1 tsp oregano\n2 tbsp paprika"
        label.font = Fonts.cStdBook?.withSize(14.0)
        label.textColor = Colors.lightGrey
        label.numberOfLines = 0
        return label
    }()
    
    func setupFromList(_ orderItems: [OrderItem]) {
        typeLabel.text = "Order"
        
        var text: String = ""
        
        for (i, item) in orderItems.enumerated() {
            text += "- \(Spice.spiceQuantity(from: item.ingredient.quantity)) \(item.ingredient.metric) \(item.ingredient.spice.name)"
            
            if i < orderItems.count - 1 {
                text += "\n"
            }
        }
        
        orderLabel.text = text
    }
    
    func setupFromOrder(_ order: Order) {
        quantityLabel.text = "Quantity: \(order.quantity)"
        
        var text: String = ""
        
        if order.recipe == nil {
            typeLabel.text = "Order"
        } else {
            typeLabel.text = "Recipe"
            text = "\(order.recipe!.name)\n"
        }
        
        let orderItems = order.orderItems?.allObjects as? [OrderItem] ?? []
        
        for (i, item) in orderItems.enumerated() {
            let metric = (Metric(rawValue: item.ingredient.metric) ?? .teaspoon).name
            text += "- \(Spice.spiceQuantity(from: item.ingredient.quantity).string) \(metric) \(item.ingredient.spice.name)"
            
            if i < orderItems.count - 1 {
                text += "\n"
            }
        }
        
        orderLabel.text = text
    }
    
    private func setupSubviews() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(orderLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(16)
        }
        
        typeLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.leading)
            make.top.equalTo(dateLabel.snp.bottom)
        }
        
        quantityLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(typeLabel.snp.top)
        }
        
        orderLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.leading)
            make.top.equalTo(typeLabel.snp.bottom)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}
