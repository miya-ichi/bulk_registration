class InputItemsForm
  # フォームオブジェクトでモデルと同じような動作を行うため
  include ActiveModel::Model
  include ActiveModel::Attributes

  # インスタンス変数itemsを定義
  # もしかしたらattribute :itemsでも良いかも？
  attr_accessor :items

  # 登録フォームの行数を定義
  INPUT_ITEM_COUNT = 5

  # このオブジェクトのインスタンスが作成されたときに実行される
  def initialize(attributes = {})
    # super attributesにより、includeしているActiveModel::Modelのinitializeメソッドを呼び出す
    # そのinitializeメソッドはセッターメソッドを呼び出すことになっているため、
    # 次で定義しているitems_attributes=(attributes)が呼び出され、itemsに値が格納される
    super attributes
    # super attributesの結果、値が格納された場合は以下の処理は実行されない
    # 値が格納されていない場合(すなわち、newアクションで新規登録フォームを表示する時)実行される
    # new.html.erbにてfields_forへ渡すために、表示したい行数分のインスタンスを作成
    self.items = INPUT_ITEM_COUNT.times.map { Item.new } unless self.items.present?
  end

  # ActiveModel::Modelのinitializeメソッドから呼び出される
  # フォームから送られてきたパラメータを１行分ずつ分けて配列に格納する。
  def items_attributes=(attributes)
    self.items = attributes.map { |_, v| Item.new(v) }
  end

  def save
    Item.transaction do
      # target_itemsにitem.registerがtrue(登録対象)の行の商品を格納する
      target_items = items.select { |item| item.register } 
      target_items.each do |item|
        item.errors.each { |attr, error| errors.add(attr, error) } if item.invalid?
        item.save
      end
      # 重複したエラーメッセージをなくしたい
      errors.uniq!
      # バリデーションエラーがあった場合、ロールバックするために例外を発生させる
      raise StandardError.new("Input Items Form Invalid") if errors.any?
    end
      # 登録が正常に終了した場合trueを返す
      return true
    rescue => e
      # 登録が失敗した場合はfalseを返す
      return false
  end
end
