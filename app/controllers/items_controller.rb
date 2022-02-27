class ItemsController < ApplicationController
  def index
    @items = Item.all
  end
  
  def new
    @form = InputItemsForm.new
  end

  def create
    @form = InputItemsForm.new(item_collection_params)

    if @form.save
      redirect_to root_path
    else
      render :new
    end
  end

  private

  def item_collection_params
    params.require(:input_items_form).permit(items_attributes: [:register, :code, :name, :price])
  end
end
