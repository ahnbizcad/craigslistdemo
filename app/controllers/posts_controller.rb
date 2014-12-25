class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def home

  end

  def index
    @posts = Post.order("timestamp DESC")
    @posts = @posts.where(bedrooms: params["bedrooms"])   if params["bedrooms"].present?
    @posts = @posts.where(bathrooms: params["bathrooms"]) if params["bathrooms"].present?
    @posts = @posts.where("sqft >= ?", params["min_sqft"])  if params["min_sqft"].present?
    @posts = @posts.where("sqft <= ?", params["max_sqft"])  if params["max_sqft"].present?
    respond_with(@posts)
  end

  def show
    @images = @post.images
    respond_with(@post)
  end

  def new
    @post = Post.new
    respond_with(@post)
  end

  def edit
  end

  def create
    @post = Post.new(post_params)
    @post.save
    respond_with(@post)
  end

  def update
    @post.update(post_params)
    respond_with(@post)
  end

  def destroy
    @post.destroy
    respond_with(@post)
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:heading, :body, :price, :neighborhood, :timestamp)
    end
end
