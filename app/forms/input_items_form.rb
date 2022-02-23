class InputItemsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :items

  INPUT_ITEM_COUNT = 5

  def initialize(attributes = {})
    super attributes
    self.items = INPUT_ITEM_COUNT.times.map { Item.new } unless self.items.present?
  end

  def items_attributes=(attributes)
    self.items = attributes.map { |_, v| Item.new(v) }
  end

  def save
    Item.transaction do
      self.items.each do |item|
        if item.register
          if item.invalid?
            item.errors.each do |attr, error|
              errors.add(attr, error)
            end
          end
          item.save!
        end
      end
    end
      return true
    rescue => e
      return false
  end
end
