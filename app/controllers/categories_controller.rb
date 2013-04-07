class CategoriesController < ApplicationController

  before_filter :get_user,        except: [:new, :edit]
  before_filter :user_categories, except: [:new, :edit]

  respond_to :html, :json

  has_mobile_fu

  def set_mobile_format
    is_device?("ipad") ? request.format = :html : super
  end

  def new
    @category = Category.new
  end

  def edit
    @category = Category.find(params[:id])

    respond_to do |format|
      format.js
    end
  end

  def update
    @category = @user_categories.find(params[:id])
    @categories = @user_categories.includes(:tasks).order('created_at ASC')

    if @category.update_attributes(params[:category])
      redirect_to username_category_path(@user.slug, @category.category_uid)
    else
      render 'edit'
    end
  end

  def show
    @categories = @user_categories.includes(:tasks).order('created_at ASC')
    @date = params[:date] ? Date.parse(params[:date]) : Date.today

    if !params.include?(:category_uid)
      @category = @user_categories.includes(:tasks).last
    else
      @category = @user_categories.includes(:tasks).find_by_category_uid(params[:category_uid])
    end

  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    @last = @user_categories.includes(:tasks).last
    @link = username_category_path(@user.slug, @last.category_uid)

    respond_to do |format|
      format.html{ redirect_to @link }
      format.js { render :js => "window.location.href = '#{@link}'" }
    end

  end

  def create
    @category = @user_categories.create(params[:category])
    @category.set_category_uid

    if @category.save
      redirect_to username_category_path(@user.slug, @category.category_uid)
    else
      render 'new'
    end
  end

  private

    def user_categories
      @user_categories ||= @user.categories
    end

end
