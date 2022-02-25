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
    # ここの処理がちょっとよく理解できていません
    # ActiveModel::Modelのinitializeメソッドを呼び出して、
    # 受け取った属性を使用できるようにしている？？
    super attributes
    # 入力フォームを表示するために、Itemモデルのインスタンスを作成する
    self.items = INPUT_ITEM_COUNT.times.map { Item.new } unless self.items.present?
  end

  # ここも曖昧です・・・initializeメソッドから呼び出されている？
  # フォームから送られてきたパラメータを１行分ずつ分けて配列に入れる。
  def items_attributes=(attributes)
    self.items = attributes.map { |_, v| Item.new(v) }
  end

  def save
    # チェックした件数分登録するが、途中で例外が発生した場合にロールバックする
    # 登録したいデータがすべて正常である場合のみ登録できる
    Item.transaction do
      self.items.each do |item|
        # チェックした行のデータのみ登録
        if item.register
          # ビューでエラーメッセージを表示させたいので、
          # itemのインスタンスのエラーメッセージをフォームのエラーメッセージとして登録する
          if item.invalid?
            item.errors.each do |attr, error|
              errors.add(attr, error)
            end
          end
          # 例外を出したいのでsave!
          item.save!
        end
      end
    end
      # 登録が正常に終了した場合trueを返す
      return true
    rescue => e
      # 登録が失敗した場合はfalseを返す
      return false
  end
end
